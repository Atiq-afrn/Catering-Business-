/// Staff Payment record with receipt / screenshot attachment
class StaffPaymentModel {
  final String id;
  final String staffId;
  final String companyId;
  final double amount;
  final String paymentDate; // YYYY-MM-DD
  final String paymentMode; // 'upi', 'cash', 'bank_transfer'
  final String? receiptImagePath; // Local file path of screenshot/receipt
  final String notes;
  final String createdAt;

  StaffPaymentModel({
    required this.id,
    required this.staffId,
    required this.companyId,
    required this.amount,
    required this.paymentDate,
    this.paymentMode = 'upi',
    this.receiptImagePath,
    this.notes = '',
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'staff_id': staffId,
      'company_id': companyId,
      'amount': amount,
      'payment_date': paymentDate,
      'payment_mode': paymentMode,
      'receipt_image_path': receiptImagePath,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory StaffPaymentModel.fromMap(Map<String, dynamic> map) {
    return StaffPaymentModel(
      id: map['id']?.toString() ?? '',
      staffId: map['staff_id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: map['payment_date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
      paymentMode: map['payment_mode']?.toString() ?? 'upi',
      receiptImagePath: map['receipt_image_path']?.toString(),
      notes: map['notes']?.toString() ?? '',
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }
}
