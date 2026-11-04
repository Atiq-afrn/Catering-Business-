import 'dart:math';
import '../core/utils/unit_converter.dart';
import '../data/models/recipe_model.dart';
import '../data/models/material_list_model.dart';
import '../data/models/ingredient_model.dart';

/// Single source of truth calculation engine for Catering Recipes & Material Lists
/// Implements the exact formulas from Section 5 & 7 of the project specification.
class RecipeCalculationService {

  /// Calculate scaled ingredient requirements for a single recipe
  static List<MaterialListItem> calculateRecipeRequirements({
    required RecipeModel recipe,
    required double targetQuantity, // Target Guests OR Target Raw kg OR Target Cooked kg
    String mode = 'people', // 'people', 'raw_ingredient', 'finished_weight'
    Map<String, IngredientModel>? stockMap,
  }) {
    double scalingFactor = 1.0;

    if (mode == 'people') {
      final baseGuests = recipe.baseQuantity > 0 ? recipe.baseQuantity : 100.0;
      scalingFactor = targetQuantity / baseGuests;
    } else if (mode == 'raw_ingredient') {
      final baseRaw = recipe.baseQuantity > 0 ? recipe.baseQuantity : 1.0;
      scalingFactor = targetQuantity / baseRaw;
    } else if (mode == 'finished_weight') {
      // Finished weight scaling using cooking yield
      final baseYield = recipe.cookingYield > 0 ? recipe.cookingYield : (recipe.baseQuantity * 0.2);
      scalingFactor = targetQuantity / baseYield;
    }

    final List<MaterialListItem> items = [];

    for (final ing in recipe.ingredients) {
      // 1. Raw required ingredient = base ingredient quantity * scaling factor
      final rawCalculated = ing.quantity * scalingFactor;

      // 2. With allowance = calculated quantity * (1 + allowance percentage / 100)
      final withAllowance = rawCalculated * (1.0 + (ing.allowancePercent / 100.0));

      // Stock comparison if available
      final stockItem = stockMap != null ? stockMap[ing.ingredientId] : null;
      final availableStock = stockItem?.currentStock ?? 0.0;
      final rate = stockItem?.defaultPurchasePrice ?? 0.0;

      // Convert available stock to recipe unit if compatible
      double convertedStock = availableStock;
      if (stockItem != null && UnitConverter.areUnitsCompatible(stockItem.baseUnit, ing.unit)) {
        convertedStock = UnitConverter.convertQuantity(availableStock, stockItem.baseUnit, ing.unit);
      }

      // Purchase quantity = max(0, required quantity - available usable stock)
      final toPurchase = max(0.0, withAllowance - convertedStock);

      // Estimated cost
      final cost = toPurchase * rate;

      items.add(
        MaterialListItem(
          ingredientId: ing.ingredientId,
          ingredientNameEn: ing.ingredientNameEn,
          ingredientNameHi: ing.ingredientNameHi,
          ingredientNameGu: ing.ingredientNameGu,
          category: stockItem?.category ?? 'groceries',
          requiredQuantity: withAllowance,
          unit: ing.unit,
          availableStock: convertedStock,
          toPurchaseQuantity: toPurchase,
          estimatedRate: rate,
          estimatedCost: cost,
          sourceDish: recipe.dishNameEn,
        ),
      );
    }

    return items;
  }

  /// Consolidates multiple dishes for an entire Function / Event
  /// Merges repeated ingredients across dishes and converts compatible units
  static List<MaterialListItem> consolidateFunctionMaterialList({
    required List<RecipeModel> recipes,
    required List<double> targetGuestsPerRecipe,
    required Map<String, IngredientModel> stockMap,
  }) {
    // Map of IngredientId -> Accumulated MaterialListItem
    final Map<String, MaterialListItem> consolidatedMap = {};

    for (int i = 0; i < recipes.length; i++) {
      final recipe = recipes[i];
      final targetGuests = (i < targetGuestsPerRecipe.length) ? targetGuestsPerRecipe[i] : 100.0;

      final dishItems = calculateRecipeRequirements(
        recipe: recipe,
        targetQuantity: targetGuests,
        mode: 'people',
        stockMap: stockMap,
      );

      for (final item in dishItems) {
        if (!consolidatedMap.containsKey(item.ingredientId)) {
          consolidatedMap[item.ingredientId] = item;
        } else {
          // Merge with existing requirement
          final existing = consolidatedMap[item.ingredientId]!;
          double newRequiredQuantity = existing.requiredQuantity;

          if (UnitConverter.areUnitsCompatible(item.unit, existing.unit)) {
            final convertedQty = UnitConverter.convertQuantity(item.requiredQuantity, item.unit, existing.unit);
            newRequiredQuantity += convertedQty;
          } else {
            newRequiredQuantity += item.requiredQuantity;
          }

          final toPurchase = max(0.0, newRequiredQuantity - existing.availableStock);
          final cost = toPurchase * existing.estimatedRate;

          consolidatedMap[item.ingredientId] = MaterialListItem(
            ingredientId: existing.ingredientId,
            ingredientNameEn: existing.ingredientNameEn,
            ingredientNameHi: existing.ingredientNameHi,
            ingredientNameGu: existing.ingredientNameGu,
            category: existing.category,
            requiredQuantity: newRequiredQuantity,
            unit: existing.unit,
            availableStock: existing.availableStock,
            toPurchaseQuantity: toPurchase,
            estimatedRate: existing.estimatedRate,
            estimatedCost: cost,
            sourceDish: 'Multiple Dishes',
          );
        }
      }
    }

    final result = consolidatedMap.values.toList();
    result.sort((a, b) => a.ingredientNameEn.compareTo(b.ingredientNameEn));
    return result;
  }
}
