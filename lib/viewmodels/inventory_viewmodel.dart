import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/ingredient_model.dart';
import '../data/models/inventory_model.dart';
import '../data/repositories/catering_repository.dart';

class InventoryViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  bool _isLoading = false;
  List<IngredientModel> _ingredients = [];
  List<InventoryMovementModel> _movements = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _onlyLowStock = false;

  InventoryViewModel(this._repository);

  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get onlyLowStock => _onlyLowStock;
  List<InventoryMovementModel> get movements => _movements;

  List<IngredientModel> get filteredIngredients {
    return _ingredients.where((i) {
      final matchesCategory = _selectedCategory == 'all' || i.category == _selectedCategory;
      final matchesLowStock = !_onlyLowStock || (i.currentStock <= i.minThreshold && i.minThreshold > 0);
      final matchesSearch = _searchQuery.isEmpty ||
          i.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.nameHi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.nameGu.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesLowStock && matchesSearch;
    }).toList();
  }

  Future<void> loadInventory(String companyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _ingredients = await _repository.getIngredients(companyId);
      _movements = await _repository.getInventoryMovements(companyId);
    } catch (e) {
      debugPrint('Error loading inventory: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleLowStockFilter() {
    _onlyLowStock = !_onlyLowStock;
    notifyListeners();
  }

  Future<void> recordStockMovement({
    required String companyId,
    required IngredientModel ingredient,
    required String movementType,
    required double quantity,
    String? functionId,
    String notes = '',
  }) async {
    final movement = InventoryMovementModel(
      id: 'mov_${const Uuid().v4().substring(0, 8)}',
      companyId: companyId,
      ingredientId: ingredient.id,
      ingredientName: ingredient.nameEn,
      movementType: movementType,
      quantity: quantity,
      unit: ingredient.baseUnit,
      functionId: functionId,
      notes: notes,
      timestamp: DateTime.now().toIso8601String(),
    );

    await _repository.recordStockMovement(movement);
    await loadInventory(companyId);
  }

  Future<void> saveIngredient(IngredientModel ingredient) async {
    await _repository.saveIngredient(ingredient);
    await loadInventory(ingredient.companyId);
  }
}
