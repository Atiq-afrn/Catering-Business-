import 'dart:convert';

class FunctionDishModel {
  final String id;
  final String functionId;
  final String companyId;
  final String recipeId;
  final String dishName;
  final double targetGuests;
  final double targetBaseQuantity;
  final String notes;

  FunctionDishModel({
    required this.id,
    required this.functionId,
    required this.companyId,
    required this.recipeId,
    required this.dishName,
    required this.targetGuests,
    this.targetBaseQuantity = 0.0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'function_id': functionId,
      'company_id': companyId,
      'recipe_id': recipeId,
      'dish_name': dishName,
      'target_guests': targetGuests,
      'target_base_quantity': targetBaseQuantity,
      'notes': notes,
    };
  }

  factory FunctionDishModel.fromMap(Map<String, dynamic> map) {
    return FunctionDishModel(
      id: map['id']?.toString() ?? '',
      functionId: map['function_id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      recipeId: map['recipe_id']?.toString() ?? '',
      dishName: map['dish_name']?.toString() ?? '',
      targetGuests: (map['target_guests'] as num?)?.toDouble() ?? 0.0,
      targetBaseQuantity: (map['target_base_quantity'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString() ?? '',
    );
  }
}

class FunctionModel {
  final String id;
  final String companyId;
  final String? customerId;
  final String customerName;
  final String customerPhone;
  final String eventName;
  final String eventType; // wedding, birthday, corporate, engagement, religious, gathering
  final String eventDate; // YYYY-MM-DD
  final String eventTime; // e.g. 19:00
  final String venue;
  final int guestCount;
  final String serviceStyle; // buffet, table_service, live_counters
  final String status; // draft, quotation_pending, confirmed, prep_pending, purchasing, cooking, ready, completed, cancelled
  final double quotationAmount;
  final double advancePaid;
  final double balanceDue;
  final double totalEstimatedCost;
  final String notes;
  final List<FunctionDishModel> dishes;
  final String createdAt;
  final String updatedAt;
  final bool isSynced;

  FunctionModel({
    required this.id,
    required this.companyId,
    this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.eventName,
    required this.eventType,
    required this.eventDate,
    this.eventTime = '12:00 PM',
    required this.venue,
    required this.guestCount,
    this.serviceStyle = 'buffet',
    this.status = 'draft',
    this.quotationAmount = 0.0,
    this.advancePaid = 0.0,
    this.balanceDue = 0.0,
    this.totalEstimatedCost = 0.0,
    this.notes = '',
    this.dishes = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  FunctionModel copyWith({
    String? id,
    String? companyId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? eventName,
    String? eventType,
    String? eventDate,
    String? eventTime,
    String? venue,
    int? guestCount,
    String? serviceStyle,
    String? status,
    double? quotationAmount,
    double? advancePaid,
    double? balanceDue,
    double? totalEstimatedCost,
    String? notes,
    List<FunctionDishModel>? dishes,
    String? createdAt,
    String? updatedAt,
    bool? isSynced,
  }) {
    return FunctionModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      eventName: eventName ?? this.eventName,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      venue: venue ?? this.venue,
      guestCount: guestCount ?? this.guestCount,
      serviceStyle: serviceStyle ?? this.serviceStyle,
      status: status ?? this.status,
      quotationAmount: quotationAmount ?? this.quotationAmount,
      advancePaid: advancePaid ?? this.advancePaid,
      balanceDue: balanceDue ?? (this.quotationAmount - (advancePaid ?? this.advancePaid)),
      totalEstimatedCost: totalEstimatedCost ?? this.totalEstimatedCost,
      notes: notes ?? this.notes,
      dishes: dishes ?? this.dishes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'customer_id': customerId ?? '',
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'event_name': eventName,
      'event_type': eventType,
      'event_date': eventDate,
      'event_time': eventTime,
      'venue': venue,
      'guest_count': guestCount,
      'service_style': serviceStyle,
      'status': status,
      'quotation_amount': quotationAmount,
      'advance_paid': advancePaid,
      'balance_due': balanceDue,
      'total_estimated_cost': totalEstimatedCost,
      'notes': notes,
      'dishes_json': jsonEncode(dishes.map((e) => e.toMap()).toList()),
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory FunctionModel.fromMap(Map<String, dynamic> map, {List<FunctionDishModel>? dishesList}) {
    List<FunctionDishModel> parsedDishes = dishesList ?? [];
    if (parsedDishes.isEmpty && map['dishes_json'] != null) {
      try {
        final decoded = jsonDecode(map['dishes_json'].toString()) as List;
        parsedDishes = decoded.map((e) => FunctionDishModel.fromMap(Map<String, dynamic>.from(e))).toList();
      } catch (_) {}
    }

    final quote = (map['quotation_amount'] as num?)?.toDouble() ?? 0.0;
    final advance = (map['advance_paid'] as num?)?.toDouble() ?? 0.0;
    final balance = (map['balance_due'] as num?)?.toDouble() ?? (quote - advance);

    return FunctionModel(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      customerId: map['customer_id']?.toString().isNotEmpty == true ? map['customer_id'].toString() : null,
      customerName: map['customer_name']?.toString() ?? '',
      customerPhone: map['customer_phone']?.toString() ?? '',
      eventName: map['event_name']?.toString() ?? '',
      eventType: map['event_type']?.toString() ?? 'wedding',
      eventDate: map['event_date']?.toString() ?? '',
      eventTime: map['event_time']?.toString() ?? '12:00 PM',
      venue: map['venue']?.toString() ?? '',
      guestCount: (map['guest_count'] as num?)?.toInt() ?? 100,
      serviceStyle: map['service_style']?.toString() ?? 'buffet',
      status: map['status']?.toString() ?? 'draft',
      quotationAmount: quote,
      advancePaid: advance,
      balanceDue: balance,
      totalEstimatedCost: (map['total_estimated_cost'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes']?.toString() ?? '',
      dishes: parsedDishes,
      createdAt: map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
      isSynced: map['is_synced'] == 1 || map['is_synced'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'companyId': companyId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'eventName': eventName,
      'eventType': eventType,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'venue': venue,
      'guestCount': guestCount,
      'serviceStyle': serviceStyle,
      'status': status,
      'quotationAmount': quotationAmount,
      'advancePaid': advancePaid,
      'balanceDue': balanceDue,
      'totalEstimatedCost': totalEstimatedCost,
      'notes': notes,
      'dishes': dishes.map((e) => e.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
