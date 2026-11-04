import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/company_model.dart';
import '../models/function_model.dart';
import '../models/staff_model.dart';
import '../models/staff_payment_model.dart';
import '../models/event_material_model.dart';
import '../models/expense_model.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('catering_operations.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Windows / Linux / macOS desktop initialization for SQLite
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (kIsWeb) {
      path = filePath;
    } else {
      final dbPath = await getApplicationDocumentsDirectory();
      path = p.join(dbPath.path, filePath);
    }

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE companies ADD COLUMN owner_phone TEXT;');
      } catch (_) {}
      try {
        await db.execute('ALTER TABLE staff ADD COLUMN joining_date TEXT;');
      } catch (_) {}

      await db.execute('''
        CREATE TABLE IF NOT EXISTS staff_payments (
          id TEXT PRIMARY KEY,
          staff_id TEXT NOT NULL,
          company_id TEXT NOT NULL,
          amount REAL NOT NULL,
          payment_date TEXT NOT NULL,
          payment_mode TEXT NOT NULL,
          receipt_image_path TEXT,
          notes TEXT,
          created_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_staff_payments_staff ON staff_payments (staff_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_staff_payments_company ON staff_payments (company_id)');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS event_materials (
          id TEXT PRIMARY KEY,
          event_id TEXT NOT NULL,
          company_id TEXT NOT NULL,
          category TEXT NOT NULL,
          item_name TEXT NOT NULL,
          item_name_hi TEXT,
          item_name_mr TEXT,
          item_name_gu TEXT,
          quantity REAL NOT NULL,
          unit TEXT NOT NULL,
          notes TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_event_materials_event ON event_materials (event_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_event_materials_company ON event_materials (company_id)');
    }

    if (oldVersion < 3) {
      try {
        await db.execute("ALTER TABLE staff ADD COLUMN payment_type TEXT NOT NULL DEFAULT 'daily';");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE staff ADD COLUMN monthly_pay REAL NOT NULL DEFAULT 0;");
      } catch (_) {}
    }

    if (oldVersion < 4) {
      try {
        await db.execute("ALTER TABLE companies ADD COLUMN password TEXT NOT NULL DEFAULT '123456';");
      } catch (_) {}
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Companies Table (Multi-tenant root)
    await db.execute('''
      CREATE TABLE companies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        owner_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        owner_phone TEXT,
        email TEXT NOT NULL,
        address TEXT NOT NULL,
        gstin TEXT,
        default_language TEXT NOT NULL DEFAULT 'en',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        password TEXT NOT NULL DEFAULT '123456'
      )
    ''');

    // 2. Ingredients Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE ingredients (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        name_en TEXT NOT NULL,
        name_hi TEXT NOT NULL,
        name_gu TEXT NOT NULL,
        category TEXT NOT NULL,
        base_unit TEXT NOT NULL,
        default_purchase_price REAL NOT NULL DEFAULT 0,
        current_stock REAL NOT NULL DEFAULT 0,
        min_threshold REAL NOT NULL DEFAULT 0,
        preferred_supplier TEXT,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_ingredients_company ON ingredients (company_id)');

    // 3. Recipes Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE recipes (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        dish_name_en TEXT NOT NULL,
        dish_name_hi TEXT NOT NULL,
        dish_name_gu TEXT NOT NULL,
        category TEXT NOT NULL,
        calculation_basis TEXT NOT NULL,
        base_quantity REAL NOT NULL,
        base_unit TEXT NOT NULL,
        cooking_yield REAL NOT NULL DEFAULT 0,
        serving_size REAL NOT NULL DEFAULT 150,
        prep_time_minutes INTEGER NOT NULL DEFAULT 60,
        notes TEXT,
        version INTEGER NOT NULL DEFAULT 1,
        ingredients_json TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_recipes_company ON recipes (company_id)');

    // 4. Functions / Events Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE functions (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        customer_id TEXT,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        event_name TEXT NOT NULL,
        event_type TEXT NOT NULL,
        event_date TEXT NOT NULL,
        event_time TEXT NOT NULL,
        venue TEXT NOT NULL,
        guest_count INTEGER NOT NULL,
        service_style TEXT NOT NULL,
        status TEXT NOT NULL,
        quotation_amount REAL NOT NULL DEFAULT 0,
        advance_paid REAL NOT NULL DEFAULT 0,
        balance_due REAL NOT NULL DEFAULT 0,
        total_estimated_cost REAL NOT NULL DEFAULT 0,
        notes TEXT,
        dishes_json TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_functions_company ON functions (company_id)');

    // 5. Inventory Movements (Multi-tenant Ledger)
    await db.execute('''
      CREATE TABLE inventory_movements (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        ingredient_id TEXT NOT NULL,
        ingredient_name TEXT NOT NULL,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        function_id TEXT,
        notes TEXT,
        timestamp TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute('CREATE INDEX idx_inventory_company ON inventory_movements (company_id)');

    // 6. Staff Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE staff (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        joining_date TEXT,
        payment_type TEXT NOT NULL DEFAULT 'daily',
        daily_wage REAL NOT NULL DEFAULT 800,
        monthly_pay REAL NOT NULL DEFAULT 0,
        hourly_rate REAL NOT NULL DEFAULT 100,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_staff_company ON staff (company_id)');

    // 7. Staff Payments Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE staff_payments (
        id TEXT PRIMARY KEY,
        staff_id TEXT NOT NULL,
        company_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_date TEXT NOT NULL,
        payment_mode TEXT NOT NULL,
        receipt_image_path TEXT,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_staff_payments_staff ON staff_payments (staff_id)');
    await db.execute('CREATE INDEX idx_staff_payments_company ON staff_payments (company_id)');

    // 8. Event Materials Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE event_materials (
        id TEXT PRIMARY KEY,
        event_id TEXT NOT NULL,
        company_id TEXT NOT NULL,
        category TEXT NOT NULL,
        item_name TEXT NOT NULL,
        item_name_hi TEXT,
        item_name_mr TEXT,
        item_name_gu TEXT,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await db.execute('CREATE INDEX idx_event_materials_event ON event_materials (event_id)');
    await db.execute('CREATE INDEX idx_event_materials_company ON event_materials (company_id)');

    // 9. Expenses Table (Multi-tenant)
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        company_id TEXT NOT NULL,
        function_id TEXT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_mode TEXT NOT NULL DEFAULT 'cash',
        paid_to TEXT,
        date TEXT NOT NULL,
        notes TEXT
      )
    ''');
    await db.execute('CREATE INDEX idx_expenses_company ON expenses (company_id)');

    // Seed Initial Default Company & Starter Dataset
    await _seedDefaultCompany(db);
  }

  Future<void> _seedDefaultCompany(Database db) async {
    final now = DateTime.now().toIso8601String();
    const defaultCompanyId = 'comp_royal_001';

    final defaultCompany = CompanyModel(
      id: defaultCompanyId,
      name: 'Royal Rasoi Caterers & Events',
      ownerName: 'Shri Nitin Patel',
      phone: '+91 93642 58881',
      ownerPhone: '+91 93642 58881',
      email: 'nitin.caterers@example.com',
      address: 'Near Shanti Sadan, Station Road, Ahmedabad',
      gstin: '24AAACR1234F1Z5',
      defaultLanguage: 'hi',
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('companies', defaultCompany.toMap());

    // Seed 50 authentic Indian catering ingredients from reference list
    final ingredients = SeedData.getInitialIngredients(defaultCompanyId);
    for (final ing in ingredients) {
      await db.insert('ingredients', ing.toMap());
    }

    // Seed master recipes
    final recipes = SeedData.getInitialRecipes(defaultCompanyId, ingredients);
    for (final rec in recipes) {
      await db.insert('recipes', rec.toMap());
    }

    // Seed sample upcoming and previous events
    final fn1 = FunctionModel(
      id: 'fn_20261025_001',
      companyId: defaultCompanyId,
      customerName: 'Rajeshbhai Shah',
      customerPhone: '+91 98250 11223',
      eventName: 'Shah Family Wedding Reception',
      eventType: 'wedding',
      eventDate: '2026-10-25', // Upcoming event
      eventTime: '07:30 PM',
      venue: 'Grand Bhagwati Banquet Hall, SG Highway',
      guestCount: 350,
      serviceStyle: 'buffet',
      status: 'confirmed',
      quotationAmount: 175000.0,
      advancePaid: 50000.0,
      balanceDue: 125000.0,
      totalEstimatedCost: 98000.0,
      notes: 'No garlic in 20 Jain plates. Cooking for 350 people.',
      dishes: [
        FunctionDishModel(
          id: 'fd_01',
          functionId: 'fn_20261025_001',
          companyId: defaultCompanyId,
          recipeId: recipes[0].id,
          dishName: recipes[0].dishNameEn,
          targetGuests: 350,
        ),
        FunctionDishModel(
          id: 'fd_02',
          functionId: 'fn_20261025_001',
          companyId: defaultCompanyId,
          recipeId: recipes[1].id,
          dishName: recipes[1].dishNameEn,
          targetGuests: 350,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final fn2 = FunctionModel(
      id: 'fn_20261028_002',
      companyId: defaultCompanyId,
      customerName: 'Amit Verma',
      customerPhone: '+91 94260 77889',
      eventName: 'Corporate Annual Gala Dinner',
      eventType: 'corporate',
      eventDate: '2026-10-28', // Upcoming event
      eventTime: '08:00 PM',
      venue: 'Radisson Blu Ballroom',
      guestCount: 200,
      serviceStyle: 'buffet',
      status: 'confirmed',
      quotationAmount: 95000.0,
      advancePaid: 35000.0,
      balanceDue: 60000.0,
      totalEstimatedCost: 52000.0,
      notes: 'Live tandoor and chaat counters. 200 people.',
      dishes: [
        FunctionDishModel(
          id: 'fd_04',
          functionId: 'fn_20261028_002',
          companyId: defaultCompanyId,
          recipeId: recipes[1].id,
          dishName: recipes[1].dishNameEn,
          targetGuests: 200,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    final fnPrevious = FunctionModel(
      id: 'fn_20261010_003',
      companyId: defaultCompanyId,
      customerName: 'Rajeshbhai Shah', // Same customer to showcase Customer History!
      customerPhone: '+91 98250 11223',
      eventName: 'Shah Family Sangeet Evening',
      eventType: 'wedding',
      eventDate: '2026-10-10', // Past event!
      eventTime: '07:00 PM',
      venue: 'Shivalik Garden Lawns',
      guestCount: 250,
      serviceStyle: 'buffet',
      status: 'completed',
      quotationAmount: 120000.0,
      advancePaid: 120000.0,
      balanceDue: 0.0,
      totalEstimatedCost: 70000.0,
      notes: 'Pre-wedding sangeet party. Completed successfully.',
      dishes: [],
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('functions', fn1.toMap());
    await db.insert('functions', fn2.toMap());
    await db.insert('functions', fnPrevious.toMap());

    // Seed sample material list for fn1 matching the user's reference handwritten sheet!
    final sampleMaterials = [
      EventMaterialModel(id: 'em_01', eventId: fn1.id, companyId: defaultCompanyId, category: 'grains', itemName: 'Rice (Chawal)', itemNameHi: 'चावल (चावल)', itemNameMr: 'तांदूळ (भात)', itemNameGu: 'ચોખા', quantity: 25.0, unit: 'kg'),
      EventMaterialModel(id: 'em_02', eventId: fn1.id, companyId: defaultCompanyId, category: 'grains', itemName: 'Rice Flour', itemNameHi: 'चावल का आटा', itemNameMr: 'तांदळाचे पीठ', itemNameGu: 'ચોખાનો લોટ', quantity: 5.0, unit: 'kg'),
      EventMaterialModel(id: 'em_03', eventId: fn1.id, companyId: defaultCompanyId, category: 'dal', itemName: 'Chana Dal', itemNameHi: 'चना दाल', itemNameMr: 'हरभरा डाळ', itemNameGu: 'ચણા દાળ', quantity: 10.0, unit: 'kg'),
      EventMaterialModel(id: 'em_04', eventId: fn1.id, companyId: defaultCompanyId, category: 'dal', itemName: 'Toor Dal', itemNameHi: 'तुअर दाल', itemNameMr: 'तूर डाळ', itemNameGu: 'તુવેર દાળ', quantity: 8.0, unit: 'kg'),
      EventMaterialModel(id: 'em_05', eventId: fn1.id, companyId: defaultCompanyId, category: 'spices', itemName: 'Cloves (Long)', itemNameHi: 'लौंग', itemNameMr: 'लवंग', itemNameGu: 'લવિંગ', quantity: 100.0, unit: 'g'),
      EventMaterialModel(id: 'em_06', eventId: fn1.id, companyId: defaultCompanyId, category: 'spices', itemName: 'Cinnamon (Dalchini)', itemNameHi: 'दालचीनी', itemNameMr: 'दालचिनी', itemNameGu: 'તજ', quantity: 100.0, unit: 'g'),
      EventMaterialModel(id: 'em_07', eventId: fn1.id, companyId: defaultCompanyId, category: 'spices', itemName: 'Cardamom (Elaichi)', itemNameHi: 'इलायची', itemNameMr: 'वेलची', itemNameGu: 'એલચી', quantity: 100.0, unit: 'g'),
      EventMaterialModel(id: 'em_08', eventId: fn1.id, companyId: defaultCompanyId, category: 'spices', itemName: 'Salt', itemNameHi: 'नमक', itemNameMr: 'मीठ', itemNameGu: 'મીઠું', quantity: 500.0, unit: 'g'),
      EventMaterialModel(id: 'em_09', eventId: fn1.id, companyId: defaultCompanyId, category: 'spices', itemName: 'Mustard Seeds (Rai)', itemNameHi: 'राई / सरसों बीज', itemNameMr: 'मोहरी', itemNameGu: 'રાઈ', quantity: 500.0, unit: 'g'),
      EventMaterialModel(id: 'em_10', eventId: fn1.id, companyId: defaultCompanyId, category: 'spices', itemName: 'Pomegranate Seeds (Anardana)', itemNameHi: 'अनारदाना', itemNameMr: 'डाळिंब दाणे', itemNameGu: 'દાડમના દાણા', quantity: 1.0, unit: 'kg'),
      EventMaterialModel(id: 'em_11', eventId: fn1.id, companyId: defaultCompanyId, category: 'vegetables', itemName: 'Onion', itemNameHi: 'प्याज', itemNameMr: 'कांदा', itemNameGu: 'ડુંગળી', quantity: 30.0, unit: 'kg'),
      EventMaterialModel(id: 'em_12', eventId: fn1.id, companyId: defaultCompanyId, category: 'vegetables', itemName: 'Potato', itemNameHi: 'आलू', itemNameMr: 'बटाटे', itemNameGu: 'બટાકા', quantity: 40.0, unit: 'kg'),
      EventMaterialModel(id: 'em_13', eventId: fn1.id, companyId: defaultCompanyId, category: 'vegetables', itemName: 'Tomato', itemNameHi: 'टमाटर', itemNameMr: 'टोमॅटो', itemNameGu: 'ટામેટા', quantity: 15.0, unit: 'kg'),
      EventMaterialModel(id: 'em_14', eventId: fn1.id, companyId: defaultCompanyId, category: 'vegetables', itemName: 'Ginger', itemNameHi: 'अदरक', itemNameMr: 'आले', itemNameGu: 'આદુ', quantity: 1.5, unit: 'kg'),
      EventMaterialModel(id: 'em_15', eventId: fn1.id, companyId: defaultCompanyId, category: 'vegetables', itemName: 'Garlic', itemNameHi: 'लहसुन', itemNameMr: 'लसूण', itemNameGu: 'લસણ', quantity: 2.0, unit: 'kg'),
      EventMaterialModel(id: 'em_16', eventId: fn1.id, companyId: defaultCompanyId, category: 'dairy', itemName: 'Paneer / Cheese', itemNameHi: 'पनीर / चीज़', itemNameMr: 'पनीर', itemNameGu: 'પનીર', quantity: 12.0, unit: 'kg'),
      EventMaterialModel(id: 'em_17', eventId: fn1.id, companyId: defaultCompanyId, category: 'dairy', itemName: 'Curd (Dahi)', itemNameHi: 'दही', itemNameMr: 'दही', itemNameGu: 'દહીં', quantity: 10.0, unit: 'kg'),
      EventMaterialModel(id: 'em_18', eventId: fn1.id, companyId: defaultCompanyId, category: 'dryfruits', itemName: 'Cashew (Kaju)', itemNameHi: 'काजू (कटे हुए)', itemNameMr: 'काजू', itemNameGu: 'કાજુ', quantity: 1.0, unit: 'kg'),
      EventMaterialModel(id: 'em_19', eventId: fn1.id, companyId: defaultCompanyId, category: 'groceries', itemName: 'Papad / Badi', itemNameHi: 'पापड़ / बड़ी', itemNameMr: 'पापड', itemNameGu: 'પાપડ', quantity: 350.0, unit: 'pcs'),
    ];

    for (final mat in sampleMaterials) {
      await db.insert('event_materials', mat.toMap());
    }

    // Seed staff members with joining dates
    final staffList = [
      StaffModel(id: 'st_01', companyId: defaultCompanyId, name: 'Maharaj Ramesh Sharma', phone: '+919898012345', role: 'head_chef', joiningDate: '2024-03-15', dailyWage: 1800.0, hourlyRate: 200.0, notes: 'Specialist in Gujarati & Marwari catering'),
      StaffModel(id: 'st_02', companyId: defaultCompanyId, name: 'Suresh Kumar', phone: '+919898054321', role: 'asst_chef', joiningDate: '2024-08-01', dailyWage: 1200.0, hourlyRate: 150.0, notes: 'Curries, gravies and tandoor setup'),
      StaffModel(id: 'st_03', companyId: defaultCompanyId, name: 'Kalu Bhai', phone: '+919723011223', role: 'helper', joiningDate: '2025-01-10', dailyWage: 800.0, hourlyRate: 100.0, notes: 'Vegetable cutting & kitchen prep helper'),
      StaffModel(id: 'st_04', companyId: defaultCompanyId, name: 'Dinesh Yadav', phone: '+919723044556', role: 'server', joiningDate: '2025-05-20', dailyWage: 700.0, hourlyRate: 90.0, notes: 'Buffet line server'),
      StaffModel(id: 'st_05', companyId: defaultCompanyId, name: 'Praveen Bhai', phone: '+919723099887', role: 'supervisor', joiningDate: '2024-01-05', dailyWage: 1500.0, hourlyRate: 180.0, notes: 'Event floor manager'),
    ];
    for (final staff in staffList) {
      await db.insert('staff', staff.toMap());
    }

    // Seed sample staff payments
    final samplePayments = [
      StaffPaymentModel(id: 'pay_01', staffId: 'st_01', companyId: defaultCompanyId, amount: 5400.0, paymentDate: '2026-10-18', paymentMode: 'upi', notes: 'Advance for upcoming wedding assignments'),
      StaffPaymentModel(id: 'pay_02', staffId: 'st_02', companyId: defaultCompanyId, amount: 3600.0, paymentDate: '2026-10-12', paymentMode: 'cash', notes: 'Weekly wage settlement'),
      StaffPaymentModel(id: 'pay_03', staffId: 'st_03', companyId: defaultCompanyId, amount: 2400.0, paymentDate: '2026-10-15', paymentMode: 'upi', notes: 'Festival advance payment'),
    ];
    for (final pay in samplePayments) {
      await db.insert('staff_payments', pay.toMap());
    }

    // Seed initial expenses
    final exp1 = ExpenseModel(
      id: 'exp_01',
      companyId: defaultCompanyId,
      functionId: 'fn_20261025_001',
      category: 'fuel_transport',
      amount: 4500.0,
      paymentMode: 'cash',
      paidTo: 'Commercial Gas Agency',
      date: '2026-10-21',
      notes: '3 Commercial 19kg LPG Cylinders',
    );
    await db.insert('expenses', exp1.toMap());
  }

  // Multi-Company registration helper
  Future<void> registerNewCompany(CompanyModel company) async {
    final db = await database;
    await db.insert('companies', company.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

    // Automatically seed standard ingredient catalogue and default recipes
    final ingredients = SeedData.getInitialIngredients(company.id);
    for (final ing in ingredients) {
      await db.insert('ingredients', ing.toMap());
    }

    final recipes = SeedData.getInitialRecipes(company.id, ingredients);
    for (final rec in recipes) {
      await db.insert('recipes', rec.toMap());
    }
  }
}
