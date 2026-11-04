/// Company / Catering Business Entity
/// Ready for Firebase Firestore (/companies/{companyId}) and local SQLite (companies table)
class CompanyModel {
  final String id; // Unique ID (e.g. comp_782910)
  final String name; // Catering Firm Name
  final String ownerName;
  final String phone; // Shop Mobile
  final String ownerPhone; // Owner Mobile
  final String email;
  final String address; // Shop Location
  final String? gstin;
  final String defaultLanguage; // 'en', 'hi', 'mr', 'gu'
  final String createdAt;
  final String updatedAt;
  final bool isSynced;
  final String password;

  CompanyModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.phone,
    this.ownerPhone = '',
    this.email = '',
    required this.address,
    this.gstin,
    this.defaultLanguage = 'en',
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.password = '123456',
  });

  CompanyModel copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? phone,
    String? ownerPhone,
    String? email,
    String? address,
    String? gstin,
    String? defaultLanguage,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
    String? password,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      password: password ?? this.password,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner_name': ownerName,
      'phone': phone,
      'owner_phone': ownerPhone.isNotEmpty ? ownerPhone : phone,
      'email': email,
      'address': address,
      'gstin': gstin ?? '',
      'default_language': defaultLanguage,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced ? 1 : 0,
      'password': password,
    };
  }

  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    final phone = map['phone']?.toString() ?? '';
    final ownerPhone = map['owner_phone']?.toString() ?? phone;
    return CompanyModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      ownerName: map['owner_name']?.toString() ?? '',
      phone: phone,
      ownerPhone: ownerPhone,
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      gstin: map['gstin']?.toString().isNotEmpty == true ? map['gstin'].toString() : null,
      defaultLanguage: map['default_language']?.toString() ?? 'en',
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
      password: map['password']?.toString().isNotEmpty == true ? map['password'].toString() : '123456',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'ownerName': ownerName,
      'phone': phone,
      'ownerPhone': ownerPhone,
      'email': email,
      'address': address,
      'gstin': gstin,
      'defaultLanguage': defaultLanguage,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'password': password,
    };
  }
}
