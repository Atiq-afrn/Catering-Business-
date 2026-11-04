import 'package:flutter/material.dart';
import '../data/models/function_model.dart';
import '../data/models/ingredient_model.dart';
import '../data/repositories/catering_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  bool _isLoading = false;

  List<FunctionModel> _upcomingFunctions = [];
  List<IngredientModel> _lowStockIngredients = [];
  int _activeEventsCount = 0;
  double _totalQuotedRevenue = 0.0;
  double _totalAdvanceReceived = 0.0;
  double _totalBalancePending = 0.0;

  DashboardViewModel(this._repository);

  bool get isLoading => _isLoading;
  List<FunctionModel> get upcomingFunctions => _upcomingFunctions;
  List<IngredientModel> get lowStockIngredients => _lowStockIngredients;
  int get activeEventsCount => _activeEventsCount;
  double get totalQuotedRevenue => _totalQuotedRevenue;
  double get totalAdvanceReceived => _totalAdvanceReceived;
  double get totalBalancePending => _totalBalancePending;

  Future<void> loadDashboard(String companyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final functions = await _repository.getFunctions(companyId);
      final ingredients = await _repository.getIngredients(companyId);

      _upcomingFunctions = functions
          .where((f) => f.status != 'completed' && f.status != 'cancelled')
          .toList();

      _activeEventsCount = _upcomingFunctions.length;

      _totalQuotedRevenue = 0.0;
      _totalAdvanceReceived = 0.0;
      _totalBalancePending = 0.0;

      for (var f in functions) {
        if (f.status != 'cancelled') {
          _totalQuotedRevenue += f.quotationAmount;
          _totalAdvanceReceived += f.advancePaid;
          _totalBalancePending += f.balanceDue;
        }
      }

      _lowStockIngredients = ingredients
          .where((i) => i.currentStock <= i.minThreshold && i.minThreshold > 0)
          .toList();
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
