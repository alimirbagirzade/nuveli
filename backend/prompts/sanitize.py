"""
Prompt-injection hygiene helpers.

The model is per-user — a user can only inject into their own session,
so the worst-case impact is self-inflicted abuse (silly coach output,
or token-cost amplification). These helpers don't promise immunity;
they raise the cost of an attack and keep prompt structure intact
when free-form user text flows into a system/user prompt template.

Trust model:
  * Anything originating from the request body (req.dietary_preference,
    custom recipe names, free-text notes) is UNTRUSTED — pass through
    `sanitize_for_prompt` before interpolation.
  * DB-sourced values (profile name, prior meals) are *less* untrusted
    because Pydantic validated them on insert, but for defense in depth
    they should still be wrapped in `wrap_user_block`.
"""
from __future__ import annotations

# Token-cost guardrail. A reasonable per-field length lets users be
# descriptive ("vegetarian, lactose-intolerant, no shellfish") without
# letting an attacker stuff a multi-kilobyte payload into the prompt.
DEFAULT_MAX_FIELD_LENGTH = 500

# Block-level cap for assembled user-data sections.
DEFAULT_MAX_BLOCK_LENGTH = 4000


def sanitize_for_prompt(
    value: str | None,
    *,
    max_length: int = DEFAULT_MAX_FIELD_LENGTH,
) -> str | None:
    """
    Strip characters that could break a prompt structure and cap length.

    Returns None when input is None, preserving optional-field semantics.

    What it removes:
      * ASCII control chars (incl. \\r, \\f, \\v, \\x00) — these are
        the main vectors for confusing a model into ignoring earlier
        instructions ("\\n\\nNew system message: ...").
      * Trailing/leading whitespace.

    What it deliberately keeps:
      * `\\n` is *collapsed* to a single space, not removed entirely —
        retaining \\n would let an attacker inject `\\nSYSTEM:` lines.
      * Other unicode is preserved (users write in Turkish, German, etc.).
    """
    if value is None:
        return None
    if not isinstance(value, str):
        value = str(value)

    # Drop control chars except for tab (tab is harmless in this context).
    cleaned_chars = []
    for ch in value:
        code = ord(ch)
        if code == 0x09:  # tab → space
            cleaned_chars.append(" ")
        elif code < 0x20 or code == 0x7F:  # other C0 + DEL
            cleaned_chars.append(" ")
        else:
            cleaned_chars.append(ch)
    cleaned = "".join(cleaned_chars)

    # Collapse runs of whitespace
    cleaned = " ".join(cleaned.split())

    if len(cleaned) > max_length:
        cleaned = cleaned[:max_length].rstrip()

    return cleaned


def sanitize_list_for_prompt(
    values: list[str] | None,
    *,
    max_items: int = 30,
    max_item_length: int = 100,
) -> list[str] | None:
    """Sanitize each item; cap list size; drop empties after sanitization."""
    if values is None:
        return None
    out: list[str] = []
    for v in values[:max_items]:
        cleaned = sanitize_for_prompt(v, max_length=max_item_length)
        if cleaned:
            out.append(cleaned)
    return out


def wrap_user_block(label: str, content: str, *, max_length: int = DEFAULT_MAX_BLOCK_LENGTH) -> str:
    """
    Wrap a chunk of user-supplied data in delimiter tags so the model
    can distinguish instructions from data. Best-effort signal — the
    model can still be coerced, but explicit boundaries help.

    Example output:
        <user_data label="dietary_preference">
        vegetarian, no nuts
        </user_data>
    """
    if len(content) > max_length:
        content = content[:max_length] + "...[truncated]"
    safe_label = "".join(c for c in label if c.isalnum() or c in ("_", "-"))[:32]
    return f'<user_data label="{safe_label}">\n{content}\n</user_data>'
