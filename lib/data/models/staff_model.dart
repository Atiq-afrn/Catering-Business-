/// Staff Member profile and wage tracker
class StaffModel {
  final String id;
  final String companyId;
  final String name;
  final String phone;
  final String role; // head_chef, asst_chef, helper, server, cleaner, supervisor
  final String joiningDate; // YYYY-MM-DD
  final String paymentType; // 'daily' or 'monthly'
  final double dailyWage;
  final double monthlyPay;
  final double hourlyRate;
  final bool isActive;
  final String notes;

  StaffModel({
    required this.id,
    required this.companyId,
    required this.name,
    required this.phone,
    required this.role,
    String? joiningDate,
    this.paymentType = 'daily',
    this.dailyWage = 800.0,
    this.monthlyPay = 0.0,
    this.hourlyRate = 100.0,
    this.isActive = true,
    this.notes = '',
  }) : joiningDate = joiningDate ?? DateTime.now().toIso8601String().substring(0, 10);

  StaffModel copyWith({
    String? id,
    String? companyId,
    String? name,
    String? phone,
    String? role,
    String? joiningDate,
    String? paymentType,
    double? dailyWage,
    double? monthlyPay,
    double? hourlyRate,
    bool? isActive,
    String? notes,
  }) {
    return StaffModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      joiningDate: joiningDate ?? this.joiningDate,
      paymentType: paymentType ?? this.paymentType,
      dailyWage: dailyWage ?? this.dailyWage,
      monthlyPay: monthlyPay ?? this.monthlyPay,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'phone': phone,
      'role': role,
      'joining_date': joiningDate,
      'payment_type': paymentType,
      'daily_wage': dailyWage,
      'monthly_pay': monthlyPay,
      'hourly_rate': hourlyRate,
      'is_active': isActive ? 1 : 0,
      'notes': notes,
    };
  }

  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      role: map['role']?.toString() ?? 'helper',
      joiningDate: map['joining_date']?.toString() ?? DateTime.now().toIso8601String().substring(0, 10),
      paymentType: map['payment_type']?.toString() ?? 'daily',
      dailyWage: (map['daily_wage'] as num?)?.toDouble() ?? 800.0,
      monthlyPay: (map['monthly_pay'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (map['hourly_rate'] as num?)?.toDouble() ?? 100.0,
      isActive: map['is_active'] == 1 || map['is_active'] == true,
      notes: map['notes']?.toString() ?? '',
    );
  }
}
