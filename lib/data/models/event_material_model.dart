/// Material item attached to a specific Event by eventId
class EventMaterialModel {
  final String id;
  final String eventId; // Linked to FunctionModel.id
  final String companyId;
  final String category; // e.g. spices, grains, vegetables, dairy, groceries, dryfruits
  final String itemName;
  final String itemNameHi;
  final String itemNameMr;
  final String itemNameGu;
  final double quantity;
  final String unit; // 'kg', 'g', 'pcs', 'l', 'packet'
  final String notes;
  final String createdAt;
  final String updatedAt;

  EventMaterialModel({
    required this.id,
    required this.eventId,
    required this.companyId,
    required this.category,
    required this.itemName,
    this.itemNameHi = '',
    this.itemNameMr = '',
    this.itemNameGu = '',
    required this.quantity,
    required this.unit,
    this.notes = '',
    String? createdAt,
    String? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now().toIso8601String(),
        updatedAt = updatedAt ?? DateTime.now().toIso8601String();

  String getLocalizedName(String langCode) {
    if (langCode == 'hi' && itemNameHi.isNotEmpty) return itemNameHi;
    if (langCode == 'mr' && itemNameMr.isNotEmpty) return itemNameMr;
    if (langCode == 'gu' && itemNameGu.isNotEmpty) return itemNameGu;
    return itemName;
  }

  EventMaterialModel copyWith({
    String? id,
    String? eventId,
    String? companyId,
    String? category,
    String? itemName,
    String? itemNameHi,
    String? itemNameMr,
    String? itemNameGu,
    double? quantity,
    String? unit,
    String? notes,
    String? createdAt,
    String? updatedAt,
  }) {
    return EventMaterialModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      companyId: companyId ?? this.companyId,
      category: category ?? this.category,
      itemName: itemName ?? this.itemName,
      itemNameHi: itemNameHi ?? this.itemNameHi,
      itemNameMr: itemNameMr ?? this.itemNameMr,
      itemNameGu: itemNameGu ?? this.itemNameGu,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'company_id': companyId,
      'category': category,
      'item_name': itemName,
      'item_name_hi': itemNameHi,
      'item_name_mr': itemNameMr,
      'item_name_gu': itemNameGu,
      'quantity': quantity,
      'unit': unit,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory EventMaterialModel.fromMap(Map<String, dynamic> map) {
    return EventMaterialModel(
      id: map['id']?.toString() ?? '',
      eventId: map['event_id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'spices',
      itemName: map['item_name']?.toString() ?? '',
      itemNameHi: map['item_name_hi']?.toString() ?? '',
      itemNameMr: map['item_name_mr']?.toString() ?? '',
      itemNameGu: map['item_name_gu']?.toString() ?? '',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'kg',
      notes: map['notes']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
