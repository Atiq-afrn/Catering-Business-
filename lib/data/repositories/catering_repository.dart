import 'package:sqflite/sqflite.dart';
import '../local/database_helper.dart';
import '../models/company_model.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../models/function_model.dart';
import '../models/inventory_model.dart';
import '../models/staff_model.dart';
import '../models/staff_payment_model.dart';
import '../models/event_material_model.dart';
import '../models/expense_model.dart';

abstract class ICateringRepository {
  // Company & Multi-tenant operations
  Future<List<CompanyModel>> getCompanies();
  Future<CompanyModel?> getCompanyById(String companyId);
  Future<void> saveCompany(CompanyModel company);

  // Ingredients (Company scoped)
  Future<List<IngredientModel>> getIngredients(String companyId);
  Future<void> saveIngredient(IngredientModel ingredient);
  Future<void> updateIngredientStock(String companyId, String ingredientId, double newStock);

  // Recipes (Company scoped)
  Future<List<RecipeModel>> getRecipes(String companyId);
  Future<RecipeModel?> getRecipeById(String companyId, String recipeId);
  Future<void> saveRecipe(RecipeModel recipe);
  Future<void> deleteRecipe(String companyId, String recipeId);

  // Functions / Events (Company scoped)
  Future<List<FunctionModel>> getFunctions(String companyId);
  Future<FunctionModel?> getFunctionById(String companyId, String functionId);
  Future<void> saveFunction(FunctionModel function);
  Future<void> updateFunctionStatus(String companyId, String functionId, String newStatus);
  Future<void> deleteFunction(String companyId, String functionId);
  Future<List<FunctionModel>> getCustomerFunctions(String companyId, String customerPhone);
  Future<int> getMonthlyEventsCount(String companyId, int year, int month);

  // Event Materials (Event scoped)
  Future<List<EventMaterialModel>> getEventMaterials(String companyId, String eventId);
  Future<void> saveEventMaterials(String companyId, String eventId, List<EventMaterialModel> materials);
  Future<void> deleteEventMaterial(String id);
  Future<List<String>> getEventIdsWithMaterials(String companyId);

  // Inventory & Ledger (Company scoped)
  Future<List<InventoryMovementModel>> getInventoryMovements(String companyId, {String? ingredientId});
  Future<void> recordStockMovement(InventoryMovementModel movement);

  // Staff (Company scoped)
  Future<List<StaffModel>> getStaffList(String companyId);
  Future<StaffModel?> getStaffById(String companyId, String staffId);
  Future<void> saveStaff(StaffModel staff);
  Future<void> deleteStaff(String companyId, String staffId);

  // Staff Payments (Staff scoped)
  Future<List<StaffPaymentModel>> getStaffPayments(String companyId, String staffId);
  Future<void> saveStaffPayment(StaffPaymentModel payment);
  Future<void> deleteStaffPayment(String id);

  // Expenses (Company scoped)
  Future<List<ExpenseModel>> getExpenses(String companyId, {String? functionId});
  Future<void> saveExpense(ExpenseModel expense);
}

class CateringRepository implements ICateringRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<CompanyModel>> getCompanies() async {
    final db = await _dbHelper.database;
    final res = await db.query('companies', orderBy: 'name ASC');
    return res.map((m) => CompanyModel.fromMap(m)).toList();
  }

  @override
  Future<CompanyModel?> getCompanyById(String companyId) async {
    final db = await _dbHelper.database;
    final res = await db.query('companies', where: 'id = ?', whereArgs: [companyId]);
    if (res.isNotEmpty) return CompanyModel.fromMap(res.first);
    return null;
  }

  @override
  Future<void> saveCompany(CompanyModel company) async {
    final db = await _dbHelper.database;
    await db.insert('companies', company.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<List<IngredientModel>> getIngredients(String companyId) async {
    final db = await _dbHelper.database;
    final res = await db.query('ingredients', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'name_en ASC');
    return res.map((m) => IngredientModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveIngredient(IngredientModel ingredient) async {
    final db = await _dbHelper.database;
    await db.insert('ingredients', ingredient.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateIngredientStock(String companyId, String ingredientId, double newStock) async {
    final db = await _dbHelper.database;
    await db.update(
      'ingredients',
      {'current_stock': newStock, 'updated_at': DateTime.now().toIso8601String()},
      where: 'company_id = ? AND id = ?',
      whereArgs: [companyId, ingredientId],
    );
  }

  @override
  Future<List<RecipeModel>> getRecipes(String companyId) async {
    final db = await _dbHelper.database;
    final res = await db.query('recipes', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'dish_name_en ASC');
    return res.map((m) => RecipeModel.fromMap(m)).toList();
  }

  @override
  Future<RecipeModel?> getRecipeById(String companyId, String recipeId) async {
    final db = await _dbHelper.database;
    final res = await db.query('recipes', where: 'company_id = ? AND id = ?', whereArgs: [companyId, recipeId]);
    if (res.isNotEmpty) return RecipeModel.fromMap(res.first);
    return null;
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    final db = await _dbHelper.database;
    await db.insert('recipes', recipe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteRecipe(String companyId, String recipeId) async {
    final db = await _dbHelper.database;
    await db.delete('recipes', where: 'company_id = ? AND id = ?', whereArgs: [companyId, recipeId]);
  }

  @override
  Future<List<FunctionModel>> getFunctions(String companyId) async {
    final db = await _dbHelper.database;
    final res = await db.query('functions', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'event_date ASC');
    return res.map((m) => FunctionModel.fromMap(m)).toList();
  }

  @override
  Future<FunctionModel?> getFunctionById(String companyId, String functionId) async {
    final db = await _dbHelper.database;
    final res = await db.query('functions', where: 'company_id = ? AND id = ?', whereArgs: [companyId, functionId]);
    if (res.isNotEmpty) return FunctionModel.fromMap(res.first);
    return null;
  }

  @override
  Future<void> saveFunction(FunctionModel function) async {
    final db = await _dbHelper.database;
    await db.insert('functions', function.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> updateFunctionStatus(String companyId, String functionId, String newStatus) async {
    final db = await _dbHelper.database;
    await db.update(
      'functions',
      {'status': newStatus, 'updated_at': DateTime.now().toIso8601String()},
      where: 'company_id = ? AND id = ?',
      whereArgs: [companyId, functionId],
    );
  }

  @override
  Future<void> deleteFunction(String companyId, String functionId) async {
    final db = await _dbHelper.database;
    await db.delete('functions', where: 'company_id = ? AND id = ?', whereArgs: [companyId, functionId]);
    // Also delete associated event materials
    await db.delete('event_materials', where: 'company_id = ? AND event_id = ?', whereArgs: [companyId, functionId]);
  }

  @override
  Future<List<FunctionModel>> getCustomerFunctions(String companyId, String customerPhone) async {
    final db = await _dbHelper.database;
    final cleaned = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final res = await db.query(
      'functions',
      where: 'company_id = ? AND (customer_phone LIKE ? OR customer_phone = ?)',
      whereArgs: [companyId, '%$cleaned%', customerPhone],
      orderBy: 'event_date DESC',
    );
    return res.map((m) => FunctionModel.fromMap(m)).toList();
  }

  @override
  Future<int> getMonthlyEventsCount(String companyId, int year, int month) async {
    final db = await _dbHelper.database;
    final monthStr = month < 10 ? '0$month' : '$month';
    final prefix = '$year-$monthStr';
    final res = await db.rawQuery(
      'SELECT COUNT(*) as count FROM functions WHERE company_id = ? AND event_date LIKE ?',
      [companyId, '$prefix%'],
    );
    if (res.isNotEmpty) {
      return (res.first['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  @override
  Future<List<EventMaterialModel>> getEventMaterials(String companyId, String eventId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'event_materials',
      where: 'company_id = ? AND event_id = ?',
      whereArgs: [companyId, eventId],
      orderBy: 'category ASC, item_name ASC',
    );
    return res.map((m) => EventMaterialModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveEventMaterials(String companyId, String eventId, List<EventMaterialModel> materials) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      // Clear previous materials for this event
      await txn.delete('event_materials', where: 'company_id = ? AND event_id = ?', whereArgs: [companyId, eventId]);
      // Insert new/updated materials
      for (final m in materials) {
        await txn.insert('event_materials', m.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  @override
  Future<void> deleteEventMaterial(String id) async {
    final db = await _dbHelper.database;
    await db.delete('event_materials', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<String>> getEventIdsWithMaterials(String companyId) async {
    final db = await _dbHelper.database;
    final res = await db.rawQuery(
      'SELECT DISTINCT event_id FROM event_materials WHERE company_id = ?',
      [companyId],
    );
    return res.map((r) => r['event_id'].toString()).toList();
  }

  @override
  Future<List<InventoryMovementModel>> getInventoryMovements(String companyId, {String? ingredientId}) async {
    final db = await _dbHelper.database;
    String whereClause = 'company_id = ?';
    List<dynamic> whereArgs = [companyId];

    if (ingredientId != null) {
      whereClause += ' AND ingredient_id = ?';
      whereArgs.add(ingredientId);
    }

    final res = await db.query('inventory_movements', where: whereClause, whereArgs: whereArgs, orderBy: 'timestamp DESC');
    return res.map((m) => InventoryMovementModel.fromMap(m)).toList();
  }

  @override
  Future<void> recordStockMovement(InventoryMovementModel movement) async {
    final db = await _dbHelper.database;
    await db.insert('inventory_movements', movement.toMap());

    // Automatically update current stock in ingredients table
    final ingRes = await db.query('ingredients', where: 'company_id = ? AND id = ?', whereArgs: [movement.companyId, movement.ingredientId]);
    if (ingRes.isNotEmpty) {
      final currentStock = (ingRes.first['current_stock'] as num).toDouble();
      double updatedStock = currentStock;

      if (movement.movementType == 'received') {
        updatedStock += movement.quantity;
      } else if (movement.movementType == 'consumed' || movement.movementType == 'wasted') {
        updatedStock = (currentStock - movement.quantity).clamp(0.0, double.infinity);
      } else if (movement.movementType == 'adjustment') {
        updatedStock = movement.quantity;
      }

      await updateIngredientStock(movement.companyId, movement.ingredientId, updatedStock);
    }
  }

  @override
  Future<List<StaffModel>> getStaffList(String companyId) async {
    final db = await _dbHelper.database;
    final res = await db.query('staff', where: 'company_id = ?', whereArgs: [companyId], orderBy: 'name ASC');
    return res.map((m) => StaffModel.fromMap(m)).toList();
  }

  @override
  Future<StaffModel?> getStaffById(String companyId, String staffId) async {
    final db = await _dbHelper.database;
    final res = await db.query('staff', where: 'company_id = ? AND id = ?', whereArgs: [companyId, staffId]);
    if (res.isNotEmpty) return StaffModel.fromMap(res.first);
    return null;
  }

  @override
  Future<void> saveStaff(StaffModel staff) async {
    final db = await _dbHelper.database;
    await db.insert('staff', staff.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteStaff(String companyId, String staffId) async {
    final db = await _dbHelper.database;
    await db.delete('staff', where: 'company_id = ? AND id = ?', whereArgs: [companyId, staffId]);
    await db.delete('staff_payments', where: 'company_id = ? AND staff_id = ?', whereArgs: [companyId, staffId]);
  }

  @override
  Future<List<StaffPaymentModel>> getStaffPayments(String companyId, String staffId) async {
    final db = await _dbHelper.database;
    final res = await db.query(
      'staff_payments',
      where: 'company_id = ? AND staff_id = ?',
      whereArgs: [companyId, staffId],
      orderBy: 'payment_date DESC',
    );
    return res.map((m) => StaffPaymentModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveStaffPayment(StaffPaymentModel payment) async {
    final db = await _dbHelper.database;
    await db.insert('staff_payments', payment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> deleteStaffPayment(String id) async {
    final db = await _dbHelper.database;
    await db.delete('staff_payments', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<ExpenseModel>> getExpenses(String companyId, {String? functionId}) async {
    final db = await _dbHelper.database;
    String whereClause = 'company_id = ?';
    List<dynamic> whereArgs = [companyId];

    if (functionId != null) {
      whereClause += ' AND function_id = ?';
      whereArgs.add(functionId);
    }

    final res = await db.query('expenses', where: whereClause, whereArgs: whereArgs, orderBy: 'date DESC');
    return res.map((m) => ExpenseModel.fromMap(m)).toList();
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    final db = await _dbHelper.database;
    await db.insert('expenses', expense.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
