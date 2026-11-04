import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/models/function_model.dart';
import '../data/models/event_material_model.dart';
import '../data/models/recipe_model.dart';
import '../data/models/ingredient_model.dart';
import '../data/models/material_list_model.dart';
import '../data/repositories/catering_repository.dart';
import '../services/recipe_calculation_service.dart';

class FunctionsViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  bool _isLoading = false;
  List<FunctionModel> _allFunctions = [];
  String _selectedStatusFilter = 'all';
  String _searchQuery = '';
  final Map<String, List<EventMaterialModel>> _materialsCache = {};
  Set<String> _eventIdsWithMaterials = {};

  FunctionsViewModel(this._repository);

  bool get isLoading => _isLoading;
  String get selectedStatusFilter => _selectedStatusFilter;
  String get searchQuery => _searchQuery;
  List<FunctionModel> get allFunctions => _allFunctions;

  String get _todayDateStr => DateTime.now().toIso8601String().substring(0, 10);

  /// Strict Upcoming Bookings: only events where eventDate >= today
  List<FunctionModel> get upcomingFunctions {
    final today = _todayDateStr;
    return _allFunctions.where((f) {
      final isUpcoming = f.eventDate.compareTo(today) >= 0 && f.status != 'completed';
      final matchesStatus = _selectedStatusFilter == 'all' || f.status == _selectedStatusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          f.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.customerPhone.contains(_searchQuery) ||
          f.venue.toLowerCase().contains(_searchQuery.toLowerCase());
      return isUpcoming && matchesStatus && matchesSearch;
    }).toList();
  }

  /// Strict Previous Bookings: events where eventDate < today OR status == completed
  List<FunctionModel> get previousFunctions {
    final today = _todayDateStr;
    return _allFunctions.where((f) {
      final isPast = f.eventDate.compareTo(today) < 0 || f.status == 'completed';
      final matchesSearch = _searchQuery.isEmpty ||
          f.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.customerPhone.contains(_searchQuery) ||
          f.venue.toLowerCase().contains(_searchQuery.toLowerCase());
      return isPast && matchesSearch;
    }).toList();
  }

  /// All filtered functions (for backwards compatibility)
  List<FunctionModel> get filteredFunctions {
    return _allFunctions.where((f) {
      final matchesStatus = _selectedStatusFilter == 'all' || f.status == _selectedStatusFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          f.eventName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          f.venue.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();
  }

  Future<void> loadFunctions(String companyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allFunctions = await _repository.getFunctions(companyId);
      final ids = await _repository.getEventIdsWithMaterials(companyId);
      _eventIdsWithMaterials = ids.toSet();
    } catch (e) {
      debugPrint('Error loading functions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String status) {
    _selectedStatusFilter = status;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> updateStatus(String companyId, String functionId, String newStatus) async {
    await _repository.updateFunctionStatus(companyId, functionId, newStatus);
    await loadFunctions(companyId);
  }

  Future<void> saveFunction(FunctionModel function) async {
    await _repository.saveFunction(function);
    await loadFunctions(function.companyId);
  }

  Future<void> deleteFunction(String companyId, String functionId) async {
    await _repository.deleteFunction(companyId, functionId);
    _materialsCache.remove(functionId);
    _eventIdsWithMaterials.remove(functionId);
    await loadFunctions(companyId);
  }

  /// Customer History: Fetch all functions for this customer phone
  Future<List<FunctionModel>> getCustomerHistory(String companyId, String customerPhone) async {
    return await _repository.getCustomerFunctions(companyId, customerPhone);
  }

  /// Event Materials: Load materials attached to this event
  Future<List<EventMaterialModel>> getEventMaterials(String companyId, String eventId) async {
    if (_materialsCache.containsKey(eventId)) {
      return _materialsCache[eventId]!;
    }
    final materials = await _repository.getEventMaterials(companyId, eventId);
    _materialsCache[eventId] = materials;
    return materials;
  }

  /// Save or Update materials for this event
  Future<void> saveEventMaterials(String companyId, String eventId, List<EventMaterialModel> materials) async {
    await _repository.saveEventMaterials(companyId, eventId, materials);
    if (materials.isNotEmpty) {
      _eventIdsWithMaterials.add(eventId);
      _materialsCache[eventId] = materials;
    } else {
      _eventIdsWithMaterials.remove(eventId);
      _materialsCache.remove(eventId);
    }
    notifyListeners();
  }

  /// Check whether an event has a material list saved
  Future<bool> hasEventMaterials(String companyId, String eventId) async {
    if (_eventIdsWithMaterials.contains(eventId)) return true;
    final list = await getEventMaterials(companyId, eventId);
    return list.isNotEmpty;
  }

  /// Synchronous check if cache or DB already has materials for this event
  bool hasCachedMaterials(String eventId) {
    return _eventIdsWithMaterials.contains(eventId) ||
        (_materialsCache.containsKey(eventId) && _materialsCache[eventId]!.isNotEmpty);
  }

  /// Duplicate a function as template
  Future<void> duplicateAsTemplate(FunctionModel oldFunction, String newDate) async {
    final newId = 'fn_${const Uuid().v4().substring(0, 8)}';
    final now = DateTime.now().toIso8601String();

    final duplicated = oldFunction.copyWith(
      id: newId,
      eventName: '${oldFunction.eventName} (Copy)',
      eventDate: newDate,
      status: 'draft',
      advancePaid: 0.0,
      balanceDue: oldFunction.quotationAmount,
      createdAt: now,
      updatedAt: now,
      isSynced: false,
    );

    await saveFunction(duplicated);
  }

  /// Generate consolidated material list from selected recipes (helper for auto-filling)
  Future<List<MaterialListItem>> generateFunctionMaterialList(FunctionModel function) async {
    final companyId = function.companyId;
    final allRecipes = await _repository.getRecipes(companyId);
    final List<IngredientModel> allIngredients = await _repository.getIngredients(companyId);
    final Map<String, IngredientModel> stockMap = {for (var i in allIngredients) i.id: i};

    final List<RecipeModel> functionRecipes = [];
    final List<double> guestCounts = [];

    for (final dish in function.dishes) {
      final recipe = allRecipes.firstWhere(
        (r) => r.id == dish.recipeId,
        orElse: () => RecipeModel(
          id: dish.recipeId,
          companyId: companyId,
          dishNameEn: dish.dishName,
          dishNameHi: dish.dishName,
          dishNameGu: dish.dishName,
          category: 'other',
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      functionRecipes.add(recipe);
      guestCounts.add(dish.targetGuests > 0 ? dish.targetGuests : function.guestCount.toDouble());
    }

    return RecipeCalculationService.consolidateFunctionMaterialList(
      recipes: functionRecipes,
      targetGuestsPerRecipe: guestCounts,
      stockMap: stockMap,
    );
  }
}
