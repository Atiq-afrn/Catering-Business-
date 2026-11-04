/// Shared Ingredient Model with Trilingual names (English, Hindi, Gujarati)
/// Ready for Firebase Firestore (/companies/{companyId}/ingredients/{ingredientId})
class IngredientModel {
  final String id;
  final String companyId;
  final String nameEn;
  final String nameHi;
  final String nameGu;
  final String category; // spices, grains, vegetables, dairy, oil, dryfruits, etc.
  final String baseUnit; // kg, g, l, ml, pcs, pkt
  final double defaultPurchasePrice;
  final double currentStock;
  final double minThreshold;
  final String? preferredSupplier;
  final String updatedAt;
  final bool isSynced;

  IngredientModel({
    required this.id,
    required this.companyId,
    required this.nameEn,
    required this.nameHi,
    required this.nameGu,
    required this.category,
    required this.baseUnit,
    this.defaultPurchasePrice = 0.0,
    this.currentStock = 0.0,
    this.minThreshold = 0.0,
    this.preferredSupplier,
    required this.updatedAt,
    this.isSynced = false,
  });

  /// Get name in current language
  String getName(String langCode) {
    if (langCode == 'hi' && nameHi.isNotEmpty) return nameHi;
    if (langCode == 'gu' && nameGu.isNotEmpty) return nameGu;
    return nameEn;
  }

  IngredientModel copyWith({
    String? id,
    String? companyId,
    String? nameEn,
    String? nameHi,
    String? nameGu,
    String? category,
    String? baseUnit,
    double? defaultPurchasePrice,
    double? currentStock,
    double? minThreshold,
    String? preferredSupplier,
    String? updatedAt,
    bool? isSynced,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      nameEn: nameEn ?? this.nameEn,
      nameHi: nameHi ?? this.nameHi,
      nameGu: nameGu ?? this.nameGu,
      category: category ?? this.category,
      baseUnit: baseUnit ?? this.baseUnit,
      defaultPurchasePrice: defaultPurchasePrice ?? this.defaultPurchasePrice,
      currentStock: currentStock ?? this.currentStock,
      minThreshold: minThreshold ?? this.minThreshold,
      preferredSupplier: preferredSupplier ?? this.preferredSupplier,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'name_en': nameEn,
      'name_hi': nameHi,
      'name_gu': nameGu,
      'category': category,
      'base_unit': baseUnit,
      'default_purchase_price': defaultPurchasePrice,
      'current_stock': currentStock,
      'min_threshold': minThreshold,
      'preferred_supplier': preferredSupplier ?? '',
      'updated_at': updatedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      nameEn: map['name_en']?.toString() ?? '',
      nameHi: map['name_hi']?.toString() ?? '',
      nameGu: map['name_gu']?.toString() ?? '',
      category: map['category']?.toString() ?? 'other',
      baseUnit: map['base_unit']?.toString() ?? 'kg',
      defaultPurchasePrice: (map['default_purchase_price'] as num?)?.toDouble() ?? 0.0,
      currentStock: (map['current_stock'] as num?)?.toDouble() ?? 0.0,
      minThreshold: (map['min_threshold'] as num?)?.toDouble() ?? 0.0,
      preferredSupplier: map['preferred_supplier']?.toString().isNotEmpty == true
          ? map['preferred_supplier'].toString()
          : null,
      updatedAt: map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'companyId': companyId,
      'nameEn': nameEn,
      'nameHi': nameHi,
      'nameGu': nameGu,
      'category': category,
      'baseUnit': baseUnit,
      'defaultPurchasePrice': defaultPurchasePrice,
      'currentStock': currentStock,
      'minThreshold': minThreshold,
      'preferredSupplier': preferredSupplier,
      'updatedAt': updatedAt,
    };
  }
}
