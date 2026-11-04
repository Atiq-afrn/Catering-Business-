import 'package:flutter/material.dart';
import '../data/models/recipe_model.dart';
import '../data/models/ingredient_model.dart';
import '../data/models/material_list_model.dart';
import '../data/repositories/catering_repository.dart';
import '../services/recipe_calculation_service.dart';

class RecipesViewModel extends ChangeNotifier {
  final ICateringRepository _repository;
  bool _isLoading = false;
  List<RecipeModel> _recipes = [];
  List<IngredientModel> _availableIngredients = [];
  String _selectedCategory = 'all';
  String _searchQuery = '';

  // Calculator State
  RecipeModel? _selectedRecipeForCalc;
  double _calculatorTargetQuantity = 100.0;
  String _calculatorMode = 'people'; // 'people', 'raw_ingredient', 'finished_weight'
  List<MaterialListItem> _calculatedItems = [];

  RecipesViewModel(this._repository);

  bool get isLoading => _isLoading;
  List<IngredientModel> get availableIngredients => _availableIngredients;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  RecipeModel? get selectedRecipeForCalc => _selectedRecipeForCalc;
  double get calculatorTargetQuantity => _calculatorTargetQuantity;
  String get calculatorMode => _calculatorMode;
  List<MaterialListItem> get calculatedItems => _calculatedItems;

  List<RecipeModel> get filteredRecipes {
    return _recipes.where((r) {
      final matchesCat = _selectedCategory == 'all' || r.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          r.dishNameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.dishNameHi.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.dishNameGu.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();
  }

  Future<void> loadRecipes(String companyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _repository.getRecipes(companyId);
      _availableIngredients = await _repository.getIngredients(companyId);

      if (_recipes.isNotEmpty && _selectedRecipeForCalc == null) {
        setRecipeForCalculator(_recipes.first);
      }
    } catch (e) {
      debugPrint('Error loading recipes: $e');
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

  void setRecipeForCalculator(RecipeModel recipe) {
    _selectedRecipeForCalc = recipe;
    _calculatorTargetQuantity = recipe.baseQuantity > 0 ? recipe.baseQuantity : 100.0;
    _calculatorMode = recipe.calculationBasis;
    recalculate();
  }

  void updateCalculatorTarget(double quantity) {
    _calculatorTargetQuantity = quantity;
    recalculate();
  }

  void updateCalculatorMode(String mode) {
    _calculatorMode = mode;
    recalculate();
  }

  void recalculate() {
    if (_selectedRecipeForCalc == null) return;

    final stockMap = {for (var i in _availableIngredients) i.id: i};

    _calculatedItems = RecipeCalculationService.calculateRecipeRequirements(
      recipe: _selectedRecipeForCalc!,
      targetQuantity: _calculatorTargetQuantity,
      mode: _calculatorMode,
      stockMap: stockMap,
    );
    notifyListeners();
  }

  Future<void> saveRecipe(RecipeModel recipe) async {
    await _repository.saveRecipe(recipe);
    await loadRecipes(recipe.companyId);
  }

  Future<void> deleteRecipe(String companyId, String recipeId) async {
    await _repository.deleteRecipe(companyId, recipeId);
    await loadRecipes(companyId);
  }
}
