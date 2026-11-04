import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/expense_model.dart';
import '../data/repositories/catering_repository.dart';
import '../data/firebase/firebase_migration_service.dart';

class CostingViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  late final FirebaseMigrationService _migrationService;

  bool _isLoading = false;
  List<ExpenseModel> _expenses = [];
  String? _firestoreJsonExport;

  CostingViewModel(this._repository) {
    _migrationService = FirebaseMigrationService(_repository);
  }

  bool get isLoading => _isLoading;
  List<ExpenseModel> get expenses => _expenses;
  String? get firestoreJsonExport => _firestoreJsonExport;

  double get totalExpenses => _expenses.fold(0.0, (sum, e) => sum + e.amount);

  Future<void> loadExpenses(String companyId, {String? functionId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _repository.getExpenses(companyId, functionId: functionId);
    } catch (e) {
      debugPrint('Error loading expenses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required String companyId,
    String? functionId,
    required String category,
    required double amount,
    required String paymentMode,
    required String paidTo,
    required String date,
    String notes = '',
  }) async {
    final exp = ExpenseModel(
      id: 'exp_${const Uuid().v4().substring(0, 8)}',
      companyId: companyId,
      functionId: functionId,
      category: category,
      amount: amount,
      paymentMode: paymentMode,
      paidTo: paidTo.trim(),
      date: date,
      notes: notes.trim(),
    );

    await _repository.saveExpense(exp);
    await loadExpenses(companyId, functionId: functionId);
  }

  /// Generates the company's entire Firebase Firestore export document package
  Future<String> exportCompanyFirestoreBundle(String companyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _firestoreJsonExport = await _migrationService.exportCompanyJsonString(companyId);
      return _firestoreJsonExport!;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
