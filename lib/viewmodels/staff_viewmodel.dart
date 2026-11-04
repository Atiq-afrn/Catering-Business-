import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/staff_model.dart';
import '../data/models/staff_payment_model.dart';
import '../data/repositories/catering_repository.dart';

class StaffViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  bool _isLoading = false;
  List<StaffModel> _staffList = [];
  String _selectedRoleFilter = 'all';
  String _searchQuery = '';
  int _monthlyEventsCount = 0;
  final Map<String, List<StaffPaymentModel>> _paymentsCache = {};

  StaffViewModel(this._repository);

  bool get isLoading => _isLoading;
  String get selectedRoleFilter => _selectedRoleFilter;
  String get searchQuery => _searchQuery;
  int get monthlyEventsCount => _monthlyEventsCount;

  List<StaffModel> get filteredStaff {
    return _staffList.where((s) {
      final matchesRole = _selectedRoleFilter == 'all' || s.role == _selectedRoleFilter;
      if (!matchesRole) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery;
      return s.name.toLowerCase().contains(q) ||
          s.phone.contains(q) ||
          s.role.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> loadStaff(String companyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _staffList = await _repository.getStaffList(companyId);
      final now = DateTime.now();
      _monthlyEventsCount = await _repository.getMonthlyEventsCount(companyId, now.year, now.month);
    } catch (e) {
      debugPrint('Error loading staff: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setRoleFilter(String role) {
    _selectedRoleFilter = role;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q.toLowerCase().trim();
    notifyListeners();
  }

  Future<void> addStaff({
    required String companyId,
    required String name,
    required String phone,
    required String role,
    required String joiningDate,
    String paymentType = 'daily',
    double dailyWage = 800.0,
    double monthlyPay = 0.0,
    double hourlyRate = 100.0,
    String notes = '',
  }) async {
    final staff = StaffModel(
      id: 'st_${const Uuid().v4().substring(0, 8)}',
      companyId: companyId,
      name: name.trim(),
      phone: phone.trim(),
      role: role,
      joiningDate: joiningDate,
      paymentType: paymentType,
      dailyWage: dailyWage,
      monthlyPay: monthlyPay,
      hourlyRate: hourlyRate,
      notes: notes.trim(),
    );

    await _repository.saveStaff(staff);
    await loadStaff(companyId);
  }

  Future<void> updateStaff(StaffModel staff) async {
    await _repository.saveStaff(staff);
    await loadStaff(staff.companyId);
  }

  Future<void> deleteStaff(String companyId, String staffId) async {
    await _repository.deleteStaff(companyId, staffId);
    _paymentsCache.remove(staffId);
    await loadStaff(companyId);
  }

  /// Load payments for a specific staff member
  Future<List<StaffPaymentModel>> getStaffPayments(String companyId, String staffId) async {
    final payments = await _repository.getStaffPayments(companyId, staffId);
    _paymentsCache[staffId] = payments;
    notifyListeners();
    return payments;
  }

  List<StaffPaymentModel> getCachedPayments(String staffId) {
    return _paymentsCache[staffId] ?? [];
  }

  /// Add a new payment sent to staff with optional receipt image
  Future<void> addStaffPayment({
    required String companyId,
    required String staffId,
    required double amount,
    required String paymentDate,
    String paymentMode = 'upi',
    String? receiptImagePath,
    String notes = '',
  }) async {
    final payment = StaffPaymentModel(
      id: 'pay_${const Uuid().v4().substring(0, 8)}',
      staffId: staffId,
      companyId: companyId,
      amount: amount,
      paymentDate: paymentDate,
      paymentMode: paymentMode,
      receiptImagePath: receiptImagePath,
      notes: notes.trim(),
    );

    await _repository.saveStaffPayment(payment);
    await getStaffPayments(companyId, staffId);
  }

  Future<void> deleteStaffPayment(String companyId, String staffId, String paymentId) async {
    await _repository.deleteStaffPayment(paymentId);
    await getStaffPayments(companyId, staffId);
  }
}
