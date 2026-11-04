import 'package:uuid/uuid.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';

class SeedData {
  static const _uuid = Uuid();

  /// Generates the complete catering ingredient catalogue from the user's reference list
  static List<IngredientModel> getInitialIngredients(String companyId) {
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> rawList = [
      {'en': 'Rice (Basmati/Chawal)', 'hi': 'चावल (बासमती)', 'gu': 'ચોખા (બાસમતી)', 'cat': 'grains', 'unit': 'kg', 'price': 90.0, 'stock': 50.0, 'min': 20.0},
      {'en': 'Rice Flour', 'hi': 'चावल का आटा', 'gu': 'ચોખાનો લોટ', 'cat': 'grains', 'unit': 'kg', 'price': 45.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Chana Dal', 'hi': 'चना दाल', 'gu': 'ચણા દાળ', 'cat': 'dal', 'unit': 'kg', 'price': 95.0, 'stock': 25.0, 'min': 10.0},
      {'en': 'Moong Dal', 'hi': 'मूंग दाल', 'gu': 'મગ દાળ', 'cat': 'dal', 'unit': 'kg', 'price': 110.0, 'stock': 20.0, 'min': 8.0},
      {'en': 'Toor / Arhar Dal', 'hi': 'तुअर दाल', 'gu': 'તુવેર દાળ', 'cat': 'dal', 'unit': 'kg', 'price': 140.0, 'stock': 30.0, 'min': 10.0},
      {'en': 'Urad Dal', 'hi': 'उड़द दाल', 'gu': 'અડદ દાળ', 'cat': 'dal', 'unit': 'kg', 'price': 120.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Masoor Dal', 'hi': 'मसूर दाल', 'gu': 'મસૂર દાળ', 'cat': 'dal', 'unit': 'kg', 'price': 85.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Wheat Flour (Atta)', 'hi': 'गेहूं का आटा', 'gu': 'ઘઉંનો લોટ', 'cat': 'grains', 'unit': 'kg', 'price': 38.0, 'stock': 60.0, 'min': 20.0},
      {'en': 'Maida', 'hi': 'मैदा', 'gu': 'મેંદો', 'cat': 'grains', 'unit': 'kg', 'price': 42.0, 'stock': 30.0, 'min': 10.0},
      {'en': 'Sooji / Rava', 'hi': 'सूजी / रवा', 'gu': 'સોજી / રવો', 'cat': 'grains', 'unit': 'kg', 'price': 46.0, 'stock': 20.0, 'min': 5.0},
      {'en': 'Sugar', 'hi': 'शक्कर / चीनी', 'gu': 'ખાંડ', 'cat': 'groceries', 'unit': 'kg', 'price': 42.0, 'stock': 50.0, 'min': 15.0},
      {'en': 'Salt', 'hi': 'नमक', 'gu': 'મીઠું', 'cat': 'spices', 'unit': 'kg', 'price': 22.0, 'stock': 25.0, 'min': 10.0},
      {'en': 'Ghee (Pure Desi)', 'hi': 'शुद्ध देशी घी', 'gu': 'શુદ્ધ દેશી ઘી', 'cat': 'dairy', 'unit': 'kg', 'price': 650.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Peanut Oil / Cooking Oil', 'hi': 'मूंगफली / मीठा तेल', 'gu': 'સીંગતેલ / તેલ', 'cat': 'groceries', 'unit': 'l', 'price': 160.0, 'stock': 40.0, 'min': 15.0},
      {'en': 'Peanuts', 'hi': 'मूंगफली दाना', 'gu': 'સીંગદાણા', 'cat': 'groceries', 'unit': 'kg', 'price': 120.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Papad / Badi', 'hi': 'पापड़ / बड़ी', 'gu': 'પાપડ / વડી', 'cat': 'groceries', 'unit': 'pcs', 'price': 2.5, 'stock': 500.0, 'min': 100.0},
      {'en': 'Paneer / Cheese', 'hi': 'पनीर / चीज़', 'gu': 'પનીર / ચીઝ', 'cat': 'dairy', 'unit': 'kg', 'price': 360.0, 'stock': 10.0, 'min': 5.0},
      {'en': 'Curd / Dahi', 'hi': 'दही', 'gu': 'દહીં', 'cat': 'dairy', 'unit': 'kg', 'price': 60.0, 'stock': 20.0, 'min': 5.0},
      {'en': 'Milk', 'hi': 'दूध', 'gu': 'દૂધ', 'cat': 'dairy', 'unit': 'l', 'price': 60.0, 'stock': 20.0, 'min': 10.0},
      {'en': 'Butter', 'hi': 'मक्खन', 'gu': 'માખણ', 'cat': 'dairy', 'unit': 'kg', 'price': 480.0, 'stock': 8.0, 'min': 3.0},
      {'en': 'Turmeric Powder (Haldi)', 'hi': 'हल्दी पाउडर', 'gu': 'હળદર પાવડર', 'cat': 'spices', 'unit': 'kg', 'price': 240.0, 'stock': 8.0, 'min': 2.0},
      {'en': 'Red Chili Powder', 'hi': 'लाल मिर्च पाउडर', 'gu': 'લાલ મરચું પાવડર', 'cat': 'spices', 'unit': 'kg', 'price': 320.0, 'stock': 10.0, 'min': 3.0},
      {'en': 'Coriander Powder (Dhaniya)', 'hi': 'धनिया पाउडर', 'gu': 'ધાણાજીરું પાવડર', 'cat': 'spices', 'unit': 'kg', 'price': 220.0, 'stock': 10.0, 'min': 3.0},
      {'en': 'Cumin Seeds (Jeera)', 'hi': 'जीरा', 'gu': 'જીરું', 'cat': 'spices', 'unit': 'kg', 'price': 380.0, 'stock': 6.0, 'min': 2.0},
      {'en': 'Mustard Seeds (Rai)', 'hi': 'राई / सरसों बीज', 'gu': 'રાઈ', 'cat': 'spices', 'unit': 'kg', 'price': 140.0, 'stock': 5.0, 'min': 2.0},
      {'en': 'Cloves (Long)', 'hi': 'लौंग', 'gu': 'લવિંગ', 'cat': 'spices', 'unit': 'g', 'price': 1.2, 'stock': 1000.0, 'min': 200.0},
      {'en': 'Cinnamon (Dalchini)', 'hi': 'दालचीनी', 'gu': 'તજ', 'cat': 'spices', 'unit': 'g', 'price': 0.8, 'stock': 1000.0, 'min': 200.0},
      {'en': 'Green Cardamom (Elaichi)', 'hi': 'इलायची (हरी)', 'gu': 'લીલી એલચી', 'cat': 'spices', 'unit': 'g', 'price': 2.5, 'stock': 500.0, 'min': 100.0},
      {'en': 'Black Cardamom (Badi Elaichi)', 'hi': 'बड़ी इलायची', 'gu': 'મોટી એલચી', 'cat': 'spices', 'unit': 'g', 'price': 1.8, 'stock': 500.0, 'min': 100.0},
      {'en': 'Black Pepper (Kali Mirch)', 'hi': 'काली मिर्च', 'gu': 'કાળા મરી', 'cat': 'spices', 'unit': 'g', 'price': 1.1, 'stock': 800.0, 'min': 200.0},
      {'en': 'Asafoetida (Hing)', 'hi': 'हींग', 'gu': 'હિંગ', 'cat': 'spices', 'unit': 'g', 'price': 2.0, 'stock': 400.0, 'min': 100.0},
      {'en': 'Fennel Seeds (Saunf)', 'hi': 'सौंफ', 'gu': 'વરિયાળી', 'cat': 'spices', 'unit': 'kg', 'price': 260.0, 'stock': 4.0, 'min': 1.0},
      {'en': 'Pomegranate Seeds (Anardana)', 'hi': 'अनारदाना', 'gu': 'દાડમના દાણા', 'cat': 'spices', 'unit': 'kg', 'price': 340.0, 'stock': 3.0, 'min': 1.0},
      {'en': 'Cashew (Kaju)', 'hi': 'काजू', 'gu': 'કાજુ', 'cat': 'dryfruits', 'unit': 'kg', 'price': 780.0, 'stock': 8.0, 'min': 3.0},
      {'en': 'Potato (Aloo)', 'hi': 'आलू', 'gu': 'બટાકા', 'cat': 'vegetables', 'unit': 'kg', 'price': 25.0, 'stock': 80.0, 'min': 20.0},
      {'en': 'Onion (Pyaz)', 'hi': 'प्याज', 'gu': 'ડુંગળી', 'cat': 'vegetables', 'unit': 'kg', 'price': 35.0, 'stock': 60.0, 'min': 20.0},
      {'en': 'Tomato', 'hi': 'टमाटर', 'gu': 'ટામેટા', 'cat': 'vegetables', 'unit': 'kg', 'price': 30.0, 'stock': 40.0, 'min': 15.0},
      {'en': 'Garlic (Lahsun)', 'hi': 'लहसुन', 'gu': 'લસણ', 'cat': 'vegetables', 'unit': 'kg', 'price': 180.0, 'stock': 12.0, 'min': 4.0},
      {'en': 'Ginger (Adrak)', 'hi': 'अदरक', 'gu': 'આદુ', 'cat': 'vegetables', 'unit': 'kg', 'price': 120.0, 'stock': 10.0, 'min': 3.0},
      {'en': 'Green Chili (Hari Mirch)', 'hi': 'हरी मिर्च', 'gu': 'લીલા મરચાં', 'cat': 'vegetables', 'unit': 'kg', 'price': 60.0, 'stock': 8.0, 'min': 2.0},
      {'en': 'Cauliflower (Gobhi)', 'hi': 'गोभी (फूल)', 'gu': 'ફ્લાવર', 'cat': 'vegetables', 'unit': 'kg', 'price': 40.0, 'stock': 20.0, 'min': 5.0},
      {'en': 'Green Peas (Matar)', 'hi': 'मटर (हरा)', 'gu': 'લીલા વટાણા', 'cat': 'vegetables', 'unit': 'kg', 'price': 70.0, 'stock': 25.0, 'min': 5.0},
      {'en': 'Spinach (Palak)', 'hi': 'पालक', 'gu': 'પાલક', 'cat': 'vegetables', 'unit': 'kg', 'price': 30.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Lady Finger (Bhindi)', 'hi': 'भिंडी', 'gu': 'ભીંડા', 'cat': 'vegetables', 'unit': 'kg', 'price': 50.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Bottle Gourd (Lauki)', 'hi': 'कद्दू / लौकी', 'gu': 'કોળું / દૂધી', 'cat': 'vegetables', 'unit': 'kg', 'price': 25.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Cucumber (Kheera)', 'hi': 'खीरा', 'gu': 'કાકડી', 'cat': 'vegetables', 'unit': 'kg', 'price': 30.0, 'stock': 15.0, 'min': 5.0},
      {'en': 'Fresh Mint (Pudina)', 'hi': 'पुदीना', 'gu': 'ફુદીનો', 'cat': 'vegetables', 'unit': 'kg', 'price': 60.0, 'stock': 5.0, 'min': 1.0},
      {'en': 'Coriander Leaves (Kothmir)', 'hi': 'धनिया पत्ती', 'gu': 'લીલી કોથમીર', 'cat': 'vegetables', 'unit': 'kg', 'price': 50.0, 'stock': 6.0, 'min': 2.0},
      {'en': 'Lemon (Nimbu)', 'hi': 'नींबू', 'gu': 'લીંબુ', 'cat': 'vegetables', 'unit': 'kg', 'price': 80.0, 'stock': 5.0, 'min': 2.0},
      {'en': 'Tea Leaves (Chai)', 'hi': 'चाय पत्ती', 'gu': 'ચા પત્તી', 'cat': 'groceries', 'unit': 'kg', 'price': 340.0, 'stock': 6.0, 'min': 2.0},
    ];

    return rawList.map((item) {
      return IngredientModel(
        id: 'ing_${_uuid.v4().substring(0, 8)}',
        companyId: companyId,
        nameEn: item['en'] as String,
        nameHi: item['hi'] as String,
        nameGu: item['gu'] as String,
        category: item['cat'] as String,
        baseUnit: item['unit'] as String,
        defaultPurchasePrice: (item['price'] as num).toDouble(),
        currentStock: (item['stock'] as num).toDouble(),
        minThreshold: (item['min'] as num).toDouble(),
        preferredSupplier: 'Mahalaxmi Trader',
        updatedAt: now,
      );
    }).toList();
  }

  /// Generates pre-populated Indian catering recipes mapped to the seeded ingredients
  static List<RecipeModel> getInitialRecipes(String companyId, List<IngredientModel> ingredients) {
    final now = DateTime.now().toIso8601String();

    IngredientModel findIng(String enPrefix) {
      return ingredients.firstWhere(
        (i) => i.nameEn.toLowerCase().contains(enPrefix.toLowerCase()),
        orElse: () => ingredients.first,
      );
    }

    final rice = findIng('Rice (Basmati');
    final ghee = findIng('Ghee');
    final oil = findIng('Oil');
    final paneer = findIng('Paneer');
    final potato = findIng('Potato');
    final onion = findIng('Onion');
    final tomato = findIng('Tomato');
    final garlic = findIng('Garlic');
    final ginger = findIng('Ginger');
    final chili = findIng('Chili');
    final peas = findIng('Peas');
    final chanaDal = findIng('Chana Dal');
    final cashew = findIng('Cashew');
    final salt = findIng('Salt');
    final turmeric = findIng('Turmeric');
    final redChili = findIng('Red Chili');
    final corianderPowder = findIng('Coriander Powder');
    final jeera = findIng('Cumin Seeds');
    final cloves = findIng('Cloves');
    final elaichi = findIng('Cardamom (Elaichi)');
    final dalchini = findIng('Cinnamon');
    final maida = findIng('Maida');
    final sugar = findIng('Sugar');
    final milk = findIng('Milk');
    final curd = findIng('Curd');
    final pudina = findIng('Mint');
    final corianderLeaves = findIng('Coriander Leaves');

    // 1. Shahi Veg Biryani (100 pax base)
    final r1Id = 'rec_${_uuid.v4().substring(0, 8)}';
    final biryani = RecipeModel(
      id: r1Id,
      companyId: companyId,
      dishNameEn: 'Shahi Dum Biryani',
      dishNameHi: 'शाही दम बिरयानी',
      dishNameGu: 'શાહી દમ બિરયાની',
      category: 'cat_rice',
      calculationBasis: 'per_person',
      baseQuantity: 100.0,
      baseUnit: 'pax',
      cookingYield: 24.0, // 24 kg finished biryani
      servingSize: 220.0, // 220 grams per person
      prepTimeMinutes: 90,
      notes: 'Cook rice 70% before dum layering with fried onions and saffron milk.',
      updatedAt: now,
      ingredients: [
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: rice.id, ingredientNameEn: rice.nameEn, ingredientNameHi: rice.nameHi, ingredientNameGu: rice.nameGu, quantity: 10.0, unit: 'kg', allowancePercent: 5.0),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: potato.id, ingredientNameEn: potato.nameEn, ingredientNameHi: potato.nameHi, ingredientNameGu: potato.nameGu, quantity: 3.5, unit: 'kg', allowancePercent: 5.0),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: peas.id, ingredientNameEn: peas.nameEn, ingredientNameHi: peas.nameHi, ingredientNameGu: peas.nameGu, quantity: 2.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: onion.id, ingredientNameEn: onion.nameEn, ingredientNameHi: onion.nameHi, ingredientNameGu: onion.nameGu, quantity: 3.0, unit: 'kg', allowancePercent: 10.0),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: ginger.id, ingredientNameEn: ginger.nameEn, ingredientNameHi: ginger.nameHi, ingredientNameGu: ginger.nameGu, quantity: 500.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: garlic.id, ingredientNameEn: garlic.nameEn, ingredientNameHi: garlic.nameHi, ingredientNameGu: garlic.nameGu, quantity: 500.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: chili.id, ingredientNameEn: chili.nameEn, ingredientNameHi: chili.nameHi, ingredientNameGu: chili.nameGu, quantity: 300.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: ghee.id, ingredientNameEn: ghee.nameEn, ingredientNameHi: ghee.nameHi, ingredientNameGu: ghee.nameGu, quantity: 1.5, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: curd.id, ingredientNameEn: curd.nameEn, ingredientNameHi: curd.nameHi, ingredientNameGu: curd.nameGu, quantity: 2.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: salt.id, ingredientNameEn: salt.nameEn, ingredientNameHi: salt.nameHi, ingredientNameGu: salt.nameGu, quantity: 400.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: cloves.id, ingredientNameEn: cloves.nameEn, ingredientNameHi: cloves.nameHi, ingredientNameGu: cloves.nameGu, quantity: 50.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: elaichi.id, ingredientNameEn: elaichi.nameEn, ingredientNameHi: elaichi.nameHi, ingredientNameGu: elaichi.nameGu, quantity: 50.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: dalchini.id, ingredientNameEn: dalchini.nameEn, ingredientNameHi: dalchini.nameHi, ingredientNameGu: dalchini.nameGu, quantity: 50.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: pudina.id, ingredientNameEn: pudina.nameEn, ingredientNameHi: pudina.nameHi, ingredientNameGu: pudina.nameGu, quantity: 500.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r1Id, companyId: companyId, ingredientId: corianderLeaves.id, ingredientNameEn: corianderLeaves.nameEn, ingredientNameHi: corianderLeaves.nameHi, ingredientNameGu: corianderLeaves.nameGu, quantity: 500.0, unit: 'g'),
      ],
    );

    // 2. Paneer Butter Masala (100 pax base)
    final r2Id = 'rec_${_uuid.v4().substring(0, 8)}';
    final paneerCurry = RecipeModel(
      id: r2Id,
      companyId: companyId,
      dishNameEn: 'Paneer Butter Masala',
      dishNameHi: 'पनीर बटर मसाला',
      dishNameGu: 'પનીર બટર મસાલા',
      category: 'cat_curry',
      calculationBasis: 'per_person',
      baseQuantity: 100.0,
      baseUnit: 'pax',
      cookingYield: 18.0,
      servingSize: 180.0,
      prepTimeMinutes: 75,
      notes: 'Rich cashew and tomato puree gravy simmered with fresh butter and kasuri methi.',
      updatedAt: now,
      ingredients: [
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: paneer.id, ingredientNameEn: paneer.nameEn, ingredientNameHi: paneer.nameHi, ingredientNameGu: paneer.nameGu, quantity: 8.0, unit: 'kg', allowancePercent: 5.0),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: tomato.id, ingredientNameEn: tomato.nameEn, ingredientNameHi: tomato.nameHi, ingredientNameGu: tomato.nameGu, quantity: 6.0, unit: 'kg', allowancePercent: 8.0),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: onion.id, ingredientNameEn: onion.nameEn, ingredientNameHi: onion.nameHi, ingredientNameGu: onion.nameGu, quantity: 4.0, unit: 'kg', allowancePercent: 10.0),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: cashew.id, ingredientNameEn: cashew.nameEn, ingredientNameHi: cashew.nameHi, ingredientNameGu: cashew.nameGu, quantity: 1.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: ghee.id, ingredientNameEn: ghee.nameEn, ingredientNameHi: ghee.nameHi, ingredientNameGu: ghee.nameGu, quantity: 800.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: ginger.id, ingredientNameEn: ginger.nameEn, ingredientNameHi: ginger.nameHi, ingredientNameGu: ginger.nameGu, quantity: 400.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: garlic.id, ingredientNameEn: garlic.nameEn, ingredientNameHi: garlic.nameHi, ingredientNameGu: garlic.nameGu, quantity: 400.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: redChili.id, ingredientNameEn: redChili.nameEn, ingredientNameHi: redChili.nameHi, ingredientNameGu: redChili.nameGu, quantity: 200.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: corianderPowder.id, ingredientNameEn: corianderPowder.nameEn, ingredientNameHi: corianderPowder.nameHi, ingredientNameGu: corianderPowder.nameGu, quantity: 200.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r2Id, companyId: companyId, ingredientId: salt.id, ingredientNameEn: salt.nameEn, ingredientNameHi: salt.nameHi, ingredientNameGu: salt.nameGu, quantity: 350.0, unit: 'g'),
      ],
    );

    // 3. Dal Tadka (100 pax base)
    final r3Id = 'rec_${_uuid.v4().substring(0, 8)}';
    final dalTadka = RecipeModel(
      id: r3Id,
      companyId: companyId,
      dishNameEn: 'Dal Tadka Special',
      dishNameHi: 'दाल तड़का स्पेशल',
      dishNameGu: 'દાળ તડકા સ્પેશિયલ',
      category: 'cat_dal',
      calculationBasis: 'per_person',
      baseQuantity: 100.0,
      baseUnit: 'pax',
      cookingYield: 16.0,
      servingSize: 150.0,
      prepTimeMinutes: 50,
      notes: 'Double tadka in pure desi ghee with cumin, garlic and dried red chilies.',
      updatedAt: now,
      ingredients: [
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: chanaDal.id, ingredientNameEn: chanaDal.nameEn, ingredientNameHi: chanaDal.nameHi, ingredientNameGu: chanaDal.nameGu, quantity: 5.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: onion.id, ingredientNameEn: onion.nameEn, ingredientNameHi: onion.nameHi, ingredientNameGu: onion.nameGu, quantity: 2.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: tomato.id, ingredientNameEn: tomato.nameEn, ingredientNameHi: tomato.nameHi, ingredientNameGu: tomato.nameGu, quantity: 2.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: garlic.id, ingredientNameEn: garlic.nameEn, ingredientNameHi: garlic.nameHi, ingredientNameGu: garlic.nameGu, quantity: 300.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: jeera.id, ingredientNameEn: jeera.nameEn, ingredientNameHi: jeera.nameHi, ingredientNameGu: jeera.nameGu, quantity: 150.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: ghee.id, ingredientNameEn: ghee.nameEn, ingredientNameHi: ghee.nameHi, ingredientNameGu: ghee.nameGu, quantity: 1.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: oil.id, ingredientNameEn: oil.nameEn, ingredientNameHi: oil.nameHi, ingredientNameGu: oil.nameGu, quantity: 500.0, unit: 'ml'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: salt.id, ingredientNameEn: salt.nameEn, ingredientNameHi: salt.nameHi, ingredientNameGu: salt.nameGu, quantity: 300.0, unit: 'g'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r3Id, companyId: companyId, ingredientId: turmeric.id, ingredientNameEn: turmeric.nameEn, ingredientNameHi: turmeric.nameHi, ingredientNameGu: turmeric.nameGu, quantity: 100.0, unit: 'g'),
      ],
    );

    // 4. Gulab Jamun (100 pax base - 200 pcs)
    final r4Id = 'rec_${_uuid.v4().substring(0, 8)}';
    final gulabJamun = RecipeModel(
      id: r4Id,
      companyId: companyId,
      dishNameEn: 'Gulab Jamun (Desi Ghee)',
      dishNameHi: 'गुलाब जामुन (देशी घी)',
      dishNameGu: 'ગુલાબ જાંબુ (દેશી ઘી)',
      category: 'cat_dessert',
      calculationBasis: 'per_person',
      baseQuantity: 100.0,
      baseUnit: 'pax',
      cookingYield: 12.0,
      servingSize: 100.0,
      prepTimeMinutes: 60,
      notes: 'Soft melt-in-mouth jamuns with green cardamom scented sugar syrup.',
      updatedAt: now,
      ingredients: [
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r4Id, companyId: companyId, ingredientId: milk.id, ingredientNameEn: milk.nameEn, ingredientNameHi: milk.nameHi, ingredientNameGu: milk.nameGu, quantity: 4.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r4Id, companyId: companyId, ingredientId: maida.id, ingredientNameEn: maida.nameEn, ingredientNameHi: maida.nameHi, ingredientNameGu: maida.nameGu, quantity: 2.5, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r4Id, companyId: companyId, ingredientId: sugar.id, ingredientNameEn: sugar.nameEn, ingredientNameHi: sugar.nameHi, ingredientNameGu: sugar.nameGu, quantity: 7.0, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r4Id, companyId: companyId, ingredientId: ghee.id, ingredientNameEn: ghee.nameEn, ingredientNameHi: ghee.nameHi, ingredientNameGu: ghee.nameGu, quantity: 2.5, unit: 'kg'),
        RecipeIngredientModel(id: _uuid.v4(), recipeId: r4Id, companyId: companyId, ingredientId: elaichi.id, ingredientNameEn: elaichi.nameEn, ingredientNameHi: elaichi.nameHi, ingredientNameGu: elaichi.nameGu, quantity: 100.0, unit: 'g'),
      ],
    );

    return [biryani, paneerCurry, dalTadka, gulabJamun];
  }
}
