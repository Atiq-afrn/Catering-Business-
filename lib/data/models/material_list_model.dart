/// Material list item representing an ingredient requirement for a dish or full function
class MaterialListItem {
  final String ingredientId;
  final String ingredientNameEn;
  final String ingredientNameHi;
  final String ingredientNameGu;
  final String category;
  final double requiredQuantity;
  final String unit;
  final double availableStock;
  final double toPurchaseQuantity;
  final double estimatedRate;
  final double estimatedCost;
  final String sourceDish; // e.g. "Veg Biryani", or "Consolidated"

  MaterialListItem({
    required this.ingredientId,
    required this.ingredientNameEn,
    this.ingredientNameHi = '',
    this.ingredientNameGu = '',
    required this.category,
    required this.requiredQuantity,
    required this.unit,
    this.availableStock = 0.0,
    required this.toPurchaseQuantity,
    this.estimatedRate = 0.0,
    required this.estimatedCost,
    this.sourceDish = 'Consolidated',
  });

  String getName(String langCode) {
    if (langCode == 'hi' && ingredientNameHi.isNotEmpty) return ingredientNameHi;
    if (langCode == 'gu' && ingredientNameGu.isNotEmpty) return ingredientNameGu;
    return ingredientNameEn;
  }

  Map<String, dynamic> toMap() {
    return {
      'ingredient_id': ingredientId,
      'ingredient_name_en': ingredientNameEn,
      'ingredient_name_hi': ingredientNameHi,
      'ingredient_name_gu': ingredientNameGu,
      'category': category,
      'required_quantity': requiredQuantity,
      'unit': unit,
      'available_stock': availableStock,
      'to_purchase_quantity': toPurchaseQuantity,
      'estimated_rate': estimatedRate,
      'estimated_cost': estimatedCost,
      'source_dish': sourceDish,
    };
  }

  factory MaterialListItem.fromMap(Map<String, dynamic> map) {
    return MaterialListItem(
      ingredientId: map['ingredient_id']?.toString() ?? '',
      ingredientNameEn: map['ingredient_name_en']?.toString() ?? '',
      ingredientNameHi: map['ingredient_name_hi']?.toString() ?? '',
      ingredientNameGu: map['ingredient_name_gu']?.toString() ?? '',
      category: map['category']?.toString() ?? 'other',
      requiredQuantity: (map['required_quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'kg',
      availableStock: (map['available_stock'] as num?)?.toDouble() ?? 0.0,
      toPurchaseQuantity: (map['to_purchase_quantity'] as num?)?.toDouble() ?? 0.0,
      estimatedRate: (map['estimated_rate'] as num?)?.toDouble() ?? 0.0,
      estimatedCost: (map['estimated_cost'] as num?)?.toDouble() ?? 0.0,
      sourceDish: map['source_dish']?.toString() ?? 'Consolidated',
    );
  }
}
