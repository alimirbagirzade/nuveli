"""
Meal planner & recipe Pydantic models.
"""
from pydantic import BaseModel, Field, model_validator
from datetime import datetime, date
from typing import Optional, Literal
from uuid import UUID
from models.meal import MealType


# --- Recipes ---

class RecipeIngredient(BaseModel):
    name: str
    amount: float
    unit: str  # "g", "ml", "piece", "cup", "tbsp"


class RecipeCreate(BaseModel):
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    servings: int = Field(1, ge=1, le=20)
    calories_per_serving: int = Field(..., ge=0)
    protein_g: float = Field(0, ge=0)
    carbs_g: float = Field(0, ge=0)
    fat_g: float = Field(0, ge=0)
    prep_time_min: Optional[int] = None
    cook_time_min: Optional[int] = None
    ingredients: list[RecipeIngredient] = Field(default_factory=list)
    instructions: Optional[list[str]] = None
    tags: Optional[list[str]] = None
    is_public: bool = False

    @model_validator(mode="before")
    @classmethod
    def _adapt_db_drift(cls, data):
        """Prod `recipes` stores the per-serving calories in a column named
        `calories` (not `calories_per_serving`) — map it so DB rows validate
        and the API keeps its `calories_per_serving` contract. Also drop
        ingredient entries that aren't well-formed objects so one bad seed
        row can't 500 the whole recipe list."""
        if isinstance(data, dict):
            if data.get("calories_per_serving") is None and "calories" in data:
                data = {**data, "calories_per_serving": data.get("calories")}
            ings = data.get("ingredients")
            if isinstance(ings, list):
                data = {
                    **data,
                    "ingredients": [
                        i for i in ings
                        if isinstance(i, dict) and i.get("name") is not None
                    ],
                }
        return data


class RecipeResponse(RecipeCreate):
    id: UUID
    user_id: Optional[UUID] = None  # null = public/system recipe
    created_at: datetime


# --- Meal Plans ---

class MealPlanCreate(BaseModel):
    plan_date: date
    meal_type: MealType
    recipe_id: Optional[UUID] = None
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    custom_protein_g: Optional[float] = None
    custom_carbs_g: Optional[float] = None
    custom_fat_g: Optional[float] = None
    servings: float = Field(1.0, gt=0)
    note: Optional[str] = None


class MealPlanUpdate(BaseModel):
    recipe_id: Optional[UUID] = None
    custom_name: Optional[str] = None
    servings: Optional[float] = None
    note: Optional[str] = None


class MealPlanResponse(BaseModel):
    id: UUID
    user_id: UUID
    plan_date: date
    meal_type: MealType
    recipe_id: Optional[UUID] = None
    recipe: Optional[RecipeResponse] = None
    custom_name: Optional[str] = None
    custom_calories: Optional[int] = None
    servings: float = 1.0
    note: Optional[str] = None
    total_calories: int = 0
    total_protein_g: float = 0
    total_carbs_g: float = 0
    total_fat_g: float = 0
    created_at: datetime


class DailyPlanTotal(BaseModel):
    plan_date: date
    total_calories: int
    total_protein_g: float
    total_carbs_g: float
    total_fat_g: float
    meal_count: int


class WeeklyPlanResponse(BaseModel):
    week_start: date
    week_end: date
    days: list[DailyPlanTotal]
    total_calories: int
    plans: list[MealPlanResponse]


# --- Grocery summary ---

class GroceryItem(BaseModel):
    name: str
    total_amount: float
    unit: str
    used_in_recipes: int = 1


class GrocerySummaryResponse(BaseModel):
    week_start: date
    week_end: date
    items: list[GroceryItem]
    recipe_count: int


# --- AI plan generation ---

class GeneratePlanRequest(BaseModel):
    week_start: date
    days: int = Field(7, ge=1, le=14)
    meals_per_day: int = Field(4, ge=2, le=6)
    target_calories: Optional[int] = Field(None, ge=800, le=6000)
    # Free-form fields flow into the OpenAI prompt. Caps below limit
    # token-cost abuse and the surface area for prompt-injection payloads.
    # Runtime sanitization (control-char strip, delimiter wrap) happens
    # in the router before the prompt is built.
    dietary_preference: Optional[str] = Field(None, max_length=200)
    avoid_ingredients: Optional[list[str]] = Field(None, max_length=30)
    note: Optional[str] = Field(None, max_length=500)


class GeneratePlanResponse(BaseModel):
    plans_created: int
    week_start: date
    week_end: date
