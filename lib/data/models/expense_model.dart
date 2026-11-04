/// Event and General Business Expense
class ExpenseModel {
  final String id;
  final String companyId;
  final String? functionId;
  final String category; // ingredients, labour, fuel, transport, equipment, disposables, other
  final double amount;
  final String paymentMode; // cash, upi, bank_transfer, credit
  final String paidTo;
  final String date;
  final String notes;

  ExpenseModel({
    required this.id,
    required this.companyId,
    this.functionId,
    required this.category,
    required this.amount,
    this.paymentMode = 'cash',
    this.paidTo = '',
    required this.date,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'function_id': functionId ?? '',
      'category': category,
      'amount': amount,
      'payment_mode': paymentMode,
      'paid_to': paidTo,
      'date': date,
      'notes': notes,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      functionId: map['function_id']?.toString().isNotEmpty == true ? map['function_id'].toString() : null,
      category: map['category']?.toString() ?? 'other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMode: map['payment_mode']?.toString() ?? 'cash',
      paidTo: map['paid_to']?.toString() ?? '',
      date: map['date']?.toString() ?? DateTime.now().toIso8601String(),
      notes: map['notes']?.toString() ?? '',
    );
  }
}
