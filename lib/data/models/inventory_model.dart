/// Represents inventory stock ledger entries (received, consumed, reserved, wasted, adjustment)
class InventoryMovementModel {
  final String id;
  final String companyId;
  final String ingredientId;
  final String ingredientName;
  final String movementType; // 'received', 'consumed', 'reserved', 'wasted', 'adjustment'
  final double quantity;
  final String unit;
  final String? functionId;
  final String notes;
  final String timestamp;
  final bool isSynced;

  InventoryMovementModel({
    required this.id,
    required this.companyId,
    required this.ingredientId,
    required this.ingredientName,
    required this.movementType,
    required this.quantity,
    required this.unit,
    this.functionId,
    this.notes = '',
    required this.timestamp,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'ingredient_id': ingredientId,
      'ingredient_name': ingredientName,
      'movement_type': movementType,
      'quantity': quantity,
      'unit': unit,
      'function_id': functionId ?? '',
      'notes': notes,
      'timestamp': timestamp,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory InventoryMovementModel.fromMap(Map<String, dynamic> map) {
    return InventoryMovementModel(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      ingredientId: map['ingredient_id']?.toString() ?? '',
      ingredientName: map['ingredient_name']?.toString() ?? '',
      movementType: map['movement_type']?.toString() ?? 'received',
      quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'kg',
      functionId: map['function_id']?.toString().isNotEmpty == true ? map['function_id'].toString() : null,
      notes: map['notes']?.toString() ?? '',
      timestamp: map['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }
}
