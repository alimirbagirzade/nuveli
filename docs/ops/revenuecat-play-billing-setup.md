# RevenueCat + Play Billing setup — completing the paywall

> **Why this doc exists:** the Coach "Upgrade to regenerate" button opens the
> paywall, which shows **"No subscription packages available"**. That is *not*
> a code bug — the paywall, purchase flow, and error handling are all shipped
> and correct. The packages are empty because the **store/RevenueCat config is
> not done yet**. This is the checklist to finish it.

## Root cause (verified 2026-05-24)

`app/.env` had **`RC_GOOGLE_KEY` empty** → `RevenueCatService` never initializes
→ `Purchases.getOfferings().current` is `null` → `offeringsProvider` returns
`PremiumOffering.empty` → paywall renders the error. Even with the key set, the
iOS **simulator can never show packages** (no StoreKit products); and a real
Android device only returns Play products from a **signed build on a Play
testing track**.

So three independent things must all be true:

1. RC SDK key present in the build (`RC_GOOGLE_KEY` / `RC_APPLE_KEY`).
2. A RevenueCat **Offering** marked *current*, with packages mapped to store products.
3. The matching subscription products **exist + active** in Play Console (and App
   Store Connect for iOS later), and the app is installed from a **Play testing
   track** (Internal Testing is enough).

---

## A. RevenueCat dashboard

1. **Project → API keys.** Copy the **Google Play** public SDK key (`goog_…`)
   and the **App Store** key (`appl_…`, for later). Put them in
   `app/.env.production`:
   ```
   RC_GOOGLE_KEY=goog_xxxxxxxxxxxxxxxx
   RC_APPLE_KEY=appl_xxxxxxxxxxxxxxxx   # iOS later
   ```
2. **Entitlements.** Create an entitlement with identifier **`premium`** (exact —
   this is `RevenueCatService.entitlementId`).
3. **Products.** Add the products you create in step B (monthly + annual).
4. **Offerings.** Create one offering, mark it **Current**. Add two packages:
   - **Monthly** (RC package type `$rc_monthly`)
   - **Annual** (RC package type `$rc_annual`)
   Attach the store products to each. The app maps these via
   `PremiumPackageType.monthly` / `.annual` (`offerings_provider.dart`); the
   "Save X%" badge is computed from monthly×12 vs annual price, so both must exist.

## B. Google Play Console

1. **Monetize → Products → Subscriptions.** Create the two subscriptions
   (e.g. `nuveli_premium_monthly`, `nuveli_premium_annual`) with base plans +
   prices. **Activate** them (inactive products are not returned).
2. **RevenueCat ↔ Play link.** In Play Console: create a service account, grant
   it Finance/Billing access, and connect it in RevenueCat (Project settings →
   Play Store credentials). RC needs this to validate purchases.
3. **App must be uploaded.** Play Billing only returns products for a package
   name that exists on a track. Upload a signed build to **Internal Testing**
   (see APK/AAB build below) and add your Google account as a tester.

## C. Build with the key

`.env.production` is created (gitignored). Fill `RC_GOOGLE_KEY`, then:

```bash
cd app
# Release APK for USB sideload (UI/flow test; Play Billing limited off-track):
flutter build apk --release --dart-define-from-file=.env.production

# Or an AAB for Play Internal Testing (the ONLY place Play Billing fully works):
flutter build appbundle --release --dart-define-from-file=.env.production
```

## D. Verify

- Install from the Internal Testing track on a real Android device (not emulator).
- Open Coach → "Upgrade to regenerate" → paywall should now list Monthly +
  Annual with localized prices.
- A sandbox/test purchase should flip `is_premium` (RC entitlement → backend via
  the RC webhook / `getCustomerInfo`).

## What is already done (no code work needed)

- Paywall UI, package cards, purchase + restore flow, error/empty/loading states.
- `RevenueCatService` init guarded on `_initialized`; empty offerings handled.
- Premium gating (`PremiumGateService`) for AI coach regenerate, meal-planner
  AI generate, beyond-one-week, etc.

## Known limits

- **iOS:** paused (no Apple Developer enrollment). `RC_APPLE_KEY` + App Store
  Connect products are deferred; the iOS simulator can never show packages.
- Until A+B+C are done, treat the paywall error as **expected** during device QA
  and skip purchase testing.
