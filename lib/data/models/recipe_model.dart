import 'dart:convert';

/// Represents a single ingredient inside a Recipe
class RecipeIngredientModel {
  final String id;
  final String recipeId;
  final String companyId;
  final String ingredientId; // Shared Ingredient ID
  final String ingredientNameEn;
  final String ingredientNameHi;
  final String ingredientNameGu;
  final double quantity; // Base quantity in recipe
  final String unit; // kg, g, l, ml, pcs, etc.
  final double allowancePercent; // Wastage / safety buffer %
  final String notes;

  RecipeIngredientModel({
    required this.id,
    required this.recipeId,
    required this.companyId,
    required this.ingredientId,
    required this.ingredientNameEn,
    this.ingredientNameHi = '',
    this.ingredientNameGu = '',
    required this.quantity,
    required this.unit,
    this.allowancePercent = 0.0,
    this.notes = '',
  });

  String getName(String langCode) {
    if (langCode == 'hi' && ingredientNameHi.isNotEmpty) return ingredientNameHi;
    if (langCode == 'gu' && ingredientNameGu.isNotEmpty) return ingredientNameGu;
    return ingredientNameEn;
  }

  RecipeIngredientModel copyWith({
    String? id,
    String? recipeId,
    String? companyId,
    String? ingredientId,
    String? ingredientNameEn,
    String? ingredientNameHi,
    String? ingredientNameGu,
    double? quantity,
    String? unit,
    double? allowancePercent,
    String? notes,
  }) {
    return RecipeIngredientModel(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      companyId: companyId ?? this.companyId,
      ingredientId: ingredientId ?? this.ingredientId,
      ingredientNameEn: ingredientNameEn ?? this.ingredientNameEn,
      ingredientNameHi: ingredientNameHi ?? this.ingredientNameHi,
      ingredientNameGu: ingredientNameGu ?? this.ingredientNameGu,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      allowancePercent: allowancePercent ?? this.allowancePercent,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipe_id': recipeId,
      'company_id': companyId,
      'ingredient_id': ingredientId,
      'ingredient_name_en': ingredientNameEn,
      'ingredient_name_hi': ingredientNameHi,
      'ingredient_name_gu': ingredientNameGu,
      'quantity': quantity,
      'unit': unit,
      'allowance_percent': allowancePercent,
      'notes': notes,
    };
  }

  factory RecipeIngredientModel.fromMap(Map<String, dynamic> map) {
    return RecipeIngredientModel(
      id: map['id']?.toString() ?? '',
      recipeId: map['recipe_id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      ingredientId: map['ingredient_id']?.toString() ?? '',
      ingredientNameEn: map['ingredient_name_en']?.toString() ?? '',
      ingredientNameHi: map['ingredient_name_hi']?.toString() ?? '',
      ingredientNameGu: map['ingredient_name_gu']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'g',
      allowancePercent: (map['allowance_percent'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => toMap();
}

/// Recipe Model for Dish Management & Dynamic Calculation
class RecipeModel {
  final String id;
  final String companyId;
  final String dishNameEn;
  final String dishNameHi;
  final String dishNameGu;
  final String category;
  final String calculationBasis; // 'per_person', 'per_raw_ingredient', 'per_finished_weight'
  final double baseQuantity; // e.g. 100 pax, or 1 kg raw base
  final String baseUnit; // pax, kg, L
  final double cookingYield; // Expected finished output (e.g. 2.4 kg)
  final double servingSize; // Expected portion per person (e.g. 180 g)
  final int prepTimeMinutes;
  final String notes;
  final int version;
  final List<RecipeIngredientModel> ingredients;
  final String updatedAt;
  final bool isSynced;

  RecipeModel({
    required this.id,
    required this.companyId,
    required this.dishNameEn,
    required this.dishNameHi,
    required this.dishNameGu,
    required this.category,
    this.calculationBasis = 'per_person',
    this.baseQuantity = 100.0,
    this.baseUnit = 'pax',
    this.cookingYield = 0.0,
    this.servingSize = 150.0,
    this.prepTimeMinutes = 60,
    this.notes = '',
    this.version = 1,
    this.ingredients = const [],
    required this.updatedAt,
    this.isSynced = false,
  });

  String getDishName(String langCode) {
    if (langCode == 'hi' && dishNameHi.isNotEmpty) return dishNameHi;
    if (langCode == 'gu' && dishNameGu.isNotEmpty) return dishNameGu;
    return dishNameEn;
  }

  RecipeModel copyWith({
    String? id,
    String? companyId,
    String? dishNameEn,
    String? dishNameHi,
    String? dishNameGu,
    String? category,
    String? calculationBasis,
    double? baseQuantity,
    String? baseUnit,
    double? cookingYield,
    double? servingSize,
    int? prepTimeMinutes,
    String? notes,
    int? version,
    List<RecipeIngredientModel>? ingredients,
    String? updatedAt,
    bool? isSynced,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      dishNameEn: dishNameEn ?? this.dishNameEn,
      dishNameHi: dishNameHi ?? this.dishNameHi,
      dishNameGu: dishNameGu ?? this.dishNameGu,
      category: category ?? this.category,
      calculationBasis: calculationBasis ?? this.calculationBasis,
      baseQuantity: baseQuantity ?? this.baseQuantity,
      baseUnit: baseUnit ?? this.baseUnit,
      cookingYield: cookingYield ?? this.cookingYield,
      servingSize: servingSize ?? this.servingSize,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      notes: notes ?? this.notes,
      version: version ?? this.version,
      ingredients: ingredients ?? this.ingredients,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'dish_name_en': dishNameEn,
      'dish_name_hi': dishNameHi,
      'dish_name_gu': dishNameGu,
      'category': category,
      'calculation_basis': calculationBasis,
      'base_quantity': baseQuantity,
      'base_unit': baseUnit,
      'cooking_yield': cookingYield,
      'serving_size': servingSize,
      'prep_time_minutes': prepTimeMinutes,
      'notes': notes,
      'version': version,
      'ingredients_json': jsonEncode(ingredients.map((e) => e.toMap()).toList()),
      'updated_at': updatedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map, {List<RecipeIngredientModel>? ingredientsList}) {
    List<RecipeIngredientModel> parsedIngredients = ingredientsList ?? [];
    if (parsedIngredients.isEmpty && map['ingredients_json'] != null) {
      try {
        final decoded = jsonDecode(map['ingredients_json'].toString()) as List;
        parsedIngredients = decoded.map((e) => RecipeIngredientModel.fromMap(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    return RecipeModel(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      dishNameEn: map['dish_name_en']?.toString() ?? '',
      dishNameHi: map['dish_name_hi']?.toString() ?? '',
      dishNameGu: map['dish_name_gu']?.toString() ?? '',
      category: map['category']?.toString() ?? 'other',
      calculationBasis: map['calculation_basis']?.toString() ?? 'per_person',
      baseQuantity: (map['base_quantity'] as num?)?.toDouble() ?? 100.0,
      baseUnit: map['base_unit']?.toString() ?? 'pax',
      cookingYield: (map['cooking_yield'] as num?)?.toDouble() ?? 0.0,
      servingSize: (map['serving_size'] as num?)?.toDouble() ?? 150.0,
      prepTimeMinutes: (map['prep_time_minutes'] as num?)?.toInt() ?? 60,
      notes: map['notes']?.toString() ?? '',
      version: (map['version'] as num?)?.toInt() ?? 1,
      ingredients: parsedIngredients,
      updatedAt: map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'companyId': companyId,
      'dishNameEn': dishNameEn,
      'dishNameHi': dishNameHi,
      'dishNameGu': dishNameGu,
      'category': category,
      'calculationBasis': calculationBasis,
      'baseQuantity': baseQuantity,
      'baseUnit': baseUnit,
      'cookingYield': cookingYield,
      'servingSize': servingSize,
      'prepTimeMinutes': prepTimeMinutes,
      'notes': notes,
      'version': version,
      'ingredients': ingredients.map((e) => e.toFirestore()).toList(),
      'updatedAt': updatedAt,
    };
  }
}
