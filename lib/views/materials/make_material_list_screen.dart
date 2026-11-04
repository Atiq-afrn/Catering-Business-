import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/function_model.dart';
import '../../data/models/event_material_model.dart';
import '../../services/pdf_generator_service.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';

class CatalogueItem {
  final String key;
  final String category;
  final String en;
  final String hi;
  final String mr;
  final String gu;
  final String defaultUnit;
  final double defaultQty;

  const CatalogueItem({
    required this.key,
    required this.category,
    required this.en,
    required this.hi,
    required this.mr,
    required this.gu,
    required this.defaultUnit,
    this.defaultQty = 1.0,
  });

  String getName(String langCode) {
    if (langCode == 'hi' && hi.isNotEmpty) return hi;
    if (langCode == 'mr' && mr.isNotEmpty) return mr;
    if (langCode == 'gu' && gu.isNotEmpty) return gu;
    return en;
  }
}

class MakeMaterialListScreen extends StatefulWidget {
  final String? initialEventId;

  const MakeMaterialListScreen({super.key, this.initialEventId});

  @override
  State<MakeMaterialListScreen> createState() => _MakeMaterialListScreenState();
}

class _MakeMaterialListScreenState extends State<MakeMaterialListScreen> {
  static const _navy = Color(0xFF203A5F);
  static const _pageBackground = Color(0xFFF5F7FA);
  static const _ink = Color(0xFF182230);
  static const _muted = Color(0xFF64748B);
  static const _line = Color(0xFFE2E8F0);
  static const _emerald = Color(0xFF059669);

  String? _selectedEventId;
  String _selectedCategoryKey = 'spices';
  bool _showAddedOnly = false;
  bool _showAllDishes = false;
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<EventMaterialModel> _materialItems = [];
  bool _isLoading = true;

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (RegExp(r'^[a-zA-Z]').hasMatch(word)) {
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }
      return word;
    }).join(' ');
  }

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'label': 'All', 'hi': 'सभी', 'mr': 'सर्व', 'gu': 'બધા', 'icon': Icons.apps_rounded},
    {'key': 'spices', 'label': 'Spices', 'hi': 'मसाले', 'mr': 'मसाले', 'gu': 'મસાલા', 'icon': Icons.local_fire_department_rounded},
    {'key': 'grains', 'label': 'Grains', 'hi': 'अनाज व आटा', 'mr': 'धान्य व पीठ', 'gu': 'અનાજ-લોટ', 'icon': Icons.grain_rounded},
    {'key': 'dal', 'label': 'Dals', 'hi': 'दालें', 'mr': 'डाळी', 'gu': 'દાળ-કઠોળ', 'icon': Icons.eco_rounded},
    {'key': 'dairy', 'label': 'Dairy & Oil', 'hi': 'दूध, घी व तेल', 'mr': 'दुग्ध, तूप व तेल', 'gu': 'ડેરી અને તેલ', 'icon': Icons.water_drop_rounded},
    {'key': 'vegetables', 'label': 'Vegetables', 'hi': 'सब्जियां', 'mr': 'भाज्या', 'gu': 'શાકભાજી', 'icon': Icons.agriculture_rounded},
    {'key': 'dryfruits', 'label': 'Dry Fruits', 'hi': 'मेवे', 'mr': 'सुका मेवा', 'gu': 'ડ્રાયફ્રુટ્સ', 'icon': Icons.forest_rounded},
    {'key': 'groceries', 'label': 'Groceries', 'hi': 'किराना', 'mr': 'किराणा', 'gu': 'કરિયાણું', 'icon': Icons.shopping_bag_rounded},
    {'key': 'other', 'label': 'Other', 'hi': 'अन्य', 'mr': 'इतर', 'gu': 'અન્ય', 'icon': Icons.more_horiz_rounded},
  ];

  static const List<CatalogueItem> _catalogue = [
    // 1. Spices (मसाले) - Comprehensive & Cleanly Organized
    CatalogueItem(key: 'turmeric', category: 'spices', en: 'Turmeric (Haldi)', hi: 'हल्दी पाउडर', mr: 'हळद', gu: 'હળદર', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'red_chili', category: 'spices', en: 'Red Chili Powder', hi: 'लाल मिर्च पाउडर', mr: 'लाल तिखट', gu: 'લાલ મરચું', defaultUnit: 'kg', defaultQty: 1),
    CatalogueItem(key: 'kashmiri_chili', category: 'spices', en: 'Kashmiri Chili Powder', hi: 'कश्मीरी लाल मिर्च', mr: 'काश्मिरी तिखट', gu: 'કાશ્મીરી મરચું', defaultUnit: 'kg', defaultQty: 1),
    CatalogueItem(key: 'cumin', category: 'spices', en: 'Cumin Seeds (Jeera)', hi: 'जीरा', mr: 'जिरे', gu: 'જીરું', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'mustard', category: 'spices', en: 'Mustard Seeds (Rai)', hi: 'राई / सरसों बीज', mr: 'मोहरी', gu: 'રાઈ', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'coriander_pow', category: 'spices', en: 'Coriander Powder (Dhaniya)', hi: 'धनिया पाउडर', mr: 'धने पूड', gu: 'ધાણાજીરું', defaultUnit: 'kg', defaultQty: 1),
    CatalogueItem(key: 'garam_masala', category: 'spices', en: 'Garam Masala', hi: 'गरम मसाला', mr: 'गरम मसाला', gu: 'ગરમ મસાલો', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'chaat_masala', category: 'spices', en: 'Chaat Masala', hi: 'चाट मसाला', mr: 'चाट मसाला', gu: 'ચાટ મસાલો', defaultUnit: 'g', defaultQty: 250),
    CatalogueItem(key: 'amchur', category: 'spices', en: 'Amchur (Dry Mango)', hi: 'अमचूर पाउडर', mr: 'आमचूर', gu: 'આમચૂર પાવડર', defaultUnit: 'g', defaultQty: 250),
    CatalogueItem(key: 'kitchen_king', category: 'spices', en: 'Kitchen King Masala', hi: 'किचन किंग मसाला', mr: 'किचन किंग', gu: 'કિચન કિંગ મસાલો', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'biryani_masala', category: 'spices', en: 'Biryani / Pulao Masala', hi: 'बिरयानी मसाला', mr: 'बिर्याणी मसाला', gu: 'બિરયાની મસાલો', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'pav_bhaji_masala', category: 'spices', en: 'Pav Bhaji Masala', hi: 'पाव भाजी मसाला', mr: 'पाव भाजी मसाला', gu: 'પાવભાજી મસાલો', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'sambhar_masala', category: 'spices', en: 'Sambhar Masala', hi: 'सांभर मसाला', mr: 'सांबार मसाला', gu: 'સાંભાર મસાલો', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'chhole_masala', category: 'spices', en: 'Chhole / Chana Masala', hi: 'छोले मसाला', mr: 'छोले मसाला', gu: 'ચણા મસાલો', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'cloves', category: 'spices', en: 'Cloves (Laung)', hi: 'लौंग', mr: 'लवंग', gu: 'લવિંગ', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'cinnamon', category: 'spices', en: 'Cinnamon (Dalchini)', hi: 'दालचीनी', mr: 'दालचिनी', gu: 'તજ', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'cardamom', category: 'spices', en: 'Green Cardamom (Elaichi)', hi: 'हरी इलायची', mr: 'वेलची', gu: 'એલચી', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'black_cardamom', category: 'spices', en: 'Black Cardamom (Badi Elaichi)', hi: 'बड़ी इलायची', mr: 'मसाला वेलची', gu: 'મોટી એલચી', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'black_pepper', category: 'spices', en: 'Black Pepper (Kali Mirch)', hi: 'काली मिर्च', mr: 'काळी मिरी', gu: 'કાળા મરી', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'bay_leaf', category: 'spices', en: 'Bay Leaf (Tejpatta)', hi: 'तेजपत्ता', mr: 'तमालपत्र', gu: 'તમાલપત્ર', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'hing', category: 'spices', en: 'Asafoetida (Hing)', hi: 'हींग', mr: 'हिंग', gu: 'હિંગ', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'salt', category: 'spices', en: 'Salt (Namak)', hi: 'सफेद नमक', mr: 'मीठ', gu: 'મીઠું', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'black_salt', category: 'spices', en: 'Black Salt (Kala Namak)', hi: 'काला नमक', mr: 'काळे मीठ', gu: 'સંચળ', defaultUnit: 'g', defaultQty: 250),
    CatalogueItem(key: 'kasuri_methi', category: 'spices', en: 'Kasuri Methi', hi: 'कस्तूरी मेथी', mr: 'कसुरी मेथी', gu: 'કસુરી મેથી', defaultUnit: 'g', defaultQty: 250),
    CatalogueItem(key: 'fennel', category: 'spices', en: 'Fennel Seeds (Saunf)', hi: 'सौंफ', mr: 'बडीशेप', gu: 'વરિયાળી', defaultUnit: 'g', defaultQty: 250),
    CatalogueItem(key: 'star_anise', category: 'spices', en: 'Star Anise (Chakraphool)', hi: 'चक्रफूल', mr: 'दगडफूल', gu: 'બાદિયાં', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'nutmeg', category: 'spices', en: 'Nutmeg & Javitri (Jaiphal)', hi: 'जायफल व जावित्री', mr: 'जायफळ', gu: 'જાયફળ', defaultUnit: 'g', defaultQty: 50),
    CatalogueItem(key: 'ajwain', category: 'spices', en: 'Carom Seeds (Ajwain)', hi: 'अजवाइन', mr: 'ओवा', gu: 'અજમો', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'methi_seeds', category: 'spices', en: 'Fenugreek Seeds (Dana Methi)', hi: 'दाना मेथी', mr: 'मेथी दाणे', gu: 'મેથી દાણા', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'kalonji', category: 'spices', en: 'Nigella Seeds (Kalonji)', hi: 'कलौंजी', mr: 'कलोंजी', gu: 'કલોંજી', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'saffron_spice', category: 'spices', en: 'Saffron (Kesar)', hi: 'केसर', mr: 'केशर', gu: 'કેસર', defaultUnit: 'g', defaultQty: 10),

    // 2. Grains & Flour (अनाज व आटा)
    CatalogueItem(key: 'basmati_rice', category: 'grains', en: 'Basmati Rice', hi: 'बासमती चावल', mr: 'बासमती तांदूळ', gu: 'બાસમતી ચોખા', defaultUnit: 'kg', defaultQty: 25),
    CatalogueItem(key: 'kolam_rice', category: 'grains', en: 'Kolam Rice', hi: 'कोलम चावल', mr: 'कोलम तांदूळ', gu: 'કોલમ ચોખા', defaultUnit: 'kg', defaultQty: 25),
    CatalogueItem(key: 'tukda_rice', category: 'grains', en: 'Broken Rice (Tukda)', hi: 'तुकड़ा चावल', mr: 'तुकडा तांदूळ', gu: 'તૂકડા ચોખા', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'wheat_atta', category: 'grains', en: 'Wheat Flour (Atta)', hi: 'गेहूं का आटा', mr: 'गव्हाचे पीठ', gu: 'ઘઉંનો લોટ', defaultUnit: 'kg', defaultQty: 30),
    CatalogueItem(key: 'maida', category: 'grains', en: 'Maida (Refined Flour)', hi: 'मैदा', mr: 'मैदा', gu: 'મેંદો', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'sooji', category: 'grains', en: 'Sooji / Rava', hi: 'सूजी / रवा', mr: 'रवा', gu: 'સોજી / રવો', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'besan', category: 'grains', en: 'Besan (Gram Flour)', hi: 'चना बेसन', mr: 'बेसन', gu: 'ચણાનો લોટ', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'poha', category: 'grains', en: 'Poha (Flattened Rice)', hi: 'पोहा', mr: 'पोहे', gu: 'પૌંઆ', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'rice_flour', category: 'grains', en: 'Rice Flour', hi: 'चावल का आटा', mr: 'तांदळाचे पीठ', gu: 'ચોખાનો લોટ', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'corn_flour', category: 'grains', en: 'Corn Flour / Starch', hi: 'कॉर्न फ्लोर', mr: 'कॉर्न फ्लोअर', gu: 'કોર્ન ફ્લોર', defaultUnit: 'kg', defaultQty: 2),

    // 3. Dals & Pulses (दालें)
    CatalogueItem(key: 'toor_dal', category: 'dal', en: 'Toor Dal (Arhar)', hi: 'तुअर दाल', mr: 'तूर डाळ', gu: 'તુવેર દાળ', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'chana_dal', category: 'dal', en: 'Chana Dal', hi: 'चना दाल', mr: 'हरभरा डाळ', gu: 'ચણા દાળ', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'moong_dal', category: 'dal', en: 'Moong Dal (Yellow)', hi: 'धुली मूंग दाल', mr: 'मुगाची डाळ', gu: 'મગ દાળ', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'moong_chilka', category: 'dal', en: 'Moong Chilka Dal', hi: 'छिलका मूंग', mr: 'हिरवी मूग डाळ', gu: 'ફોતરાવાળી મગ દાળ', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'urad_dal', category: 'dal', en: 'Urad Dal (White)', hi: 'उड़द दाल', mr: 'उडीद डाळ', gu: 'અડદ દાળ', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'masoor_dal', category: 'dal', en: 'Masoor Dal', hi: 'मसूर दाल', mr: 'मसूर डाळ', gu: 'મસૂર દાળ', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'kabuli_chana', category: 'dal', en: 'Kabuli Chana (Chole)', hi: 'सफेद छोले / काबुली चना', mr: 'काबुली चणे', gu: 'કાબુલી ચણા', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'kala_chana', category: 'dal', en: 'Kala Chana', hi: 'काला चना', mr: 'काळे हरभरे', gu: 'દેશી ચણા', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'green_peas_dry', category: 'dal', en: 'Dried Green Peas', hi: 'सूखे हरे मटर', mr: 'सुके वाटाणे', gu: 'સૂકા વટાણા', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'rajma', category: 'dal', en: 'Rajma (Kidney Beans)', hi: 'राजमा', mr: 'राजमा', gu: 'રાજમા', defaultUnit: 'kg', defaultQty: 5),

    // 4. Dairy & Oils (दूध, घी व तेल)
    CatalogueItem(key: 'paneer', category: 'dairy', en: 'Fresh Paneer', hi: 'ताजा पनीर', mr: 'ताजे पनीर', gu: 'તાજું પનીર', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'ghee', category: 'dairy', en: 'Pure Desi Ghee', hi: 'शुद्ध देशी घी', mr: 'शुद्ध साजूक तूप', gu: 'શુદ્ધ ઘી', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'vanaspati', category: 'dairy', en: 'Vanaspati Ghee', hi: 'डालडा / वनस्पति घी', mr: 'डालडा', gu: 'વનસ્પતિ ઘી', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'curd', category: 'dairy', en: 'Curd / Dahi', hi: 'दही', mr: 'दही', gu: 'દહીં', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'milk', category: 'dairy', en: 'Fresh Milk', hi: 'ताजा दूध', mr: 'दूध', gu: 'દૂધ', defaultUnit: 'l', defaultQty: 20),
    CatalogueItem(key: 'fresh_cream', category: 'dairy', en: 'Fresh Cream / Malai', hi: 'मलाई / क्रीम', mr: 'क्रीम', gu: 'મલાઈ', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'cooking_oil', category: 'dairy', en: 'Cooking Oil', hi: 'मीठा तेल (रिफाइंड/मूंगफली)', mr: 'गोडेतेल / शेंगदाणा तेल', gu: 'સીંગતેલ / તેલ', defaultUnit: 'l', defaultQty: 15),
    CatalogueItem(key: 'mustard_oil', category: 'dairy', en: 'Mustard Oil (Sarson)', hi: 'सरसों का तेल', mr: 'मोहरी तेल', gu: 'સરસવનું તેલ', defaultUnit: 'l', defaultQty: 5),
    CatalogueItem(key: 'butter', category: 'dairy', en: 'Butter', hi: 'मक्खन / बटर', mr: 'लोणी / बटर', gu: 'માખણ', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'khoya', category: 'dairy', en: 'Khoya / Mawa', hi: 'मावा / खोया', mr: 'खवा', gu: 'માવો', defaultUnit: 'kg', defaultQty: 5),

    // 5. Vegetables (सब्जियां)
    CatalogueItem(key: 'potato', category: 'vegetables', en: 'Potato (Aloo)', hi: 'आलू', mr: 'बटाटे', gu: 'બટાકા', defaultUnit: 'kg', defaultQty: 30),
    CatalogueItem(key: 'onion', category: 'vegetables', en: 'Onion (Pyaz)', hi: 'प्याज', mr: 'कांदा', gu: 'ડુંગળી', defaultUnit: 'kg', defaultQty: 25),
    CatalogueItem(key: 'tomato', category: 'vegetables', en: 'Tomato', hi: 'टमाटर', mr: 'टोमॅटो', gu: 'ટામેટા', defaultUnit: 'kg', defaultQty: 15),
    CatalogueItem(key: 'ginger', category: 'vegetables', en: 'Ginger (Adrak)', hi: 'अदरक', mr: 'आले', gu: 'આદુ', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'garlic', category: 'vegetables', en: 'Garlic (Lahsun)', hi: 'लहसुन', mr: 'लसूण', gu: 'લસણ', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'green_chili_veg', category: 'vegetables', en: 'Green Chili (Hari Mirch)', hi: 'हरी मिर्च', mr: 'हिरवी मिरची', gu: 'લીલા મરચાં', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'coriander_leaves', category: 'vegetables', en: 'Coriander Leaves (Dhaniya)', hi: 'हरा धनिया', mr: 'कोथिंबीर', gu: 'કોથમીર', defaultUnit: 'kg', defaultQty: 3),
    CatalogueItem(key: 'mint_leaves', category: 'vegetables', en: 'Mint Leaves (Pudina)', hi: 'पुदीना', mr: 'पुदिना', gu: 'ફુદીનો', defaultUnit: 'kg', defaultQty: 1),
    CatalogueItem(key: 'cauliflower', category: 'vegetables', en: 'Cauliflower (Phoolgobhi)', hi: 'फूलगोभी', mr: 'फ्लॉवर', gu: 'ફુલાવર', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'cabbage', category: 'vegetables', en: 'Cabbage (Pattagobhi)', hi: 'पत्तागोभी', mr: 'कोबी', gu: 'કોબીજ', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'fresh_matar', category: 'vegetables', en: 'Fresh Green Peas (Matar)', hi: 'ताजा हरा मटर', mr: 'ताजे मटार', gu: 'તાજા વટાણા', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'lemon', category: 'vegetables', en: 'Lemon (Nimbu)', hi: 'नींबू', mr: 'लिंबू', gu: 'લીંબુ', defaultUnit: 'pcs', defaultQty: 50),
    CatalogueItem(key: 'capsicum', category: 'vegetables', en: 'Capsicum (Shimla Mirch)', hi: 'शिमला मिर्च', mr: 'ढोबळी मिरची', gu: 'કેપ્સિકમ', defaultUnit: 'kg', defaultQty: 5),

    // 6. Dry Fruits (मेवे)
    CatalogueItem(key: 'cashew', category: 'dryfruits', en: 'Cashew (Kaju)', hi: 'काजू', mr: 'काजू', gu: 'કાજુ', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'almond', category: 'dryfruits', en: 'Almonds (Badam)', hi: 'बादाम', mr: 'बदाम', gu: 'બદામ', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'raisins', category: 'dryfruits', en: 'Raisins (Kishmish)', hi: 'किशमिश', mr: 'बेदाणे', gu: 'કિસમિસ', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'pista', category: 'dryfruits', en: 'Pistachio (Pista)', hi: 'पिस्ता', mr: 'पिसता', gu: 'પિસ્તા', defaultUnit: 'g', defaultQty: 500),
    CatalogueItem(key: 'charoli', category: 'dryfruits', en: 'Charoli / Chironji', hi: 'चारोली', mr: 'चारोळी', gu: 'ચારોળી', defaultUnit: 'g', defaultQty: 250),
    CatalogueItem(key: 'dry_coconut', category: 'dryfruits', en: 'Dry Coconut (Khopra)', hi: 'सूखा नारियल / गोला', mr: 'सुके खोबरे', gu: 'સૂકું ટોપરું', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'fresh_coconut', category: 'dryfruits', en: 'Fresh Coconut', hi: 'पानी वाला नारियल', mr: 'ओला नारळ', gu: 'તાજું નાળિયેર', defaultUnit: 'pcs', defaultQty: 10),

    // 7. Groceries (किराना)
    CatalogueItem(key: 'sugar', category: 'groceries', en: 'Sugar (Shakkar)', hi: 'चीनी', mr: 'साखर', gu: 'ખાંડ', defaultUnit: 'kg', defaultQty: 25),
    CatalogueItem(key: 'jaggery', category: 'groceries', en: 'Jaggery (Gud)', hi: 'गुड़', mr: 'गूळ', gu: 'ગોળ', defaultUnit: 'kg', defaultQty: 10),
    CatalogueItem(key: 'papad', category: 'groceries', en: 'Papad', hi: 'पापड़', mr: 'पापड', gu: 'પાપડ', defaultUnit: 'kg', defaultQty: 5),
    CatalogueItem(key: 'tamarind', category: 'groceries', en: 'Tamarind (Imli)', hi: 'इमली', mr: 'चिंच', gu: 'આંબલી', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'tea', category: 'groceries', en: 'Tea Leaves (Chai)', hi: 'चाय पत्ती', mr: 'चहा पावडर', gu: 'ચા પત્તી', defaultUnit: 'kg', defaultQty: 2),
    CatalogueItem(key: 'food_color', category: 'groceries', en: 'Food Color (Yellow/Orange)', hi: 'खाने का रंग', mr: 'खाण्याचा रंग', gu: 'ફૂડ કલર', defaultUnit: 'g', defaultQty: 100),
    CatalogueItem(key: 'rose_water', category: 'groceries', en: 'Rose Water / Kewra', hi: 'गुलाब जल / केवड़ा', mr: 'गुलाब पाणी', gu: 'ગુલાબ જળ', defaultUnit: 'l', defaultQty: 1),
    CatalogueItem(key: 'saffron', category: 'groceries', en: 'Saffron (Kesar)', hi: 'केसर', mr: 'केशर', gu: 'કેસર', defaultUnit: 'g', defaultQty: 10),
    CatalogueItem(key: 'baking_soda', category: 'groceries', en: 'Baking Soda', hi: 'मीठा सोडा', mr: 'खाण्याचा सोडा', gu: 'ખાવાનો સોડા', defaultUnit: 'g', defaultQty: 250),

    // 8. Other Supplies (इतर)
    CatalogueItem(key: 'napkins', category: 'other', en: 'Paper Napkins / Tissue', hi: 'टिश्यू पेपर', mr: 'नॅपकिन्स', gu: 'ટિશ્યુ પેપર', defaultUnit: 'packet', defaultQty: 10),
    CatalogueItem(key: 'plates', category: 'other', en: 'Disposable Dining Plates', hi: 'डिस्पोजल थालियां', mr: 'डिस्पोजेबल प्लेट्स', gu: 'ડિસ્પોઝેબલ ડીશ', defaultUnit: 'pcs', defaultQty: 300),
    CatalogueItem(key: 'cups', category: 'other', en: 'Paper Cups (Water/Tea)', hi: 'कागदी कप', mr: 'पेपर कप', gu: 'પેપર કપ', defaultUnit: 'pcs', defaultQty: 500),
    CatalogueItem(key: 'water_jars', category: 'other', en: 'Drinking Water Jars (20L)', hi: 'पानी के जार (20L)', mr: 'पाण्याचे जार', gu: 'પાણીના જગ', defaultUnit: 'pcs', defaultQty: 10),
    CatalogueItem(key: 'foil_roll', category: 'other', en: 'Aluminum Foil Roll', hi: 'सिल्वर फॉइल', mr: 'फॉइल रोल', gu: 'સિલ્વર ફોઇલ', defaultUnit: 'packet', defaultQty: 5),
    CatalogueItem(key: 'garbage_bags', category: 'other', en: 'Garbage Bags', hi: 'कचरा बैग', mr: 'कचरा पिशव्या', gu: 'કચરા બેગ', defaultUnit: 'packet', defaultQty: 5),
  ];

  @override
  void initState() {
    super.initState();
    _selectedEventId = widget.initialEventId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLoad());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _initLoad() async {
    final authVM = context.read<AuthCompanyViewModel>();
    final fnVM = context.read<FunctionsViewModel>();
    final compId = authVM.activeCompany?.id;

    if (compId != null) {
      if (fnVM.allFunctions.isEmpty) {
        await fnVM.loadFunctions(compId);
      }
      if (_selectedEventId == null && fnVM.upcomingFunctions.isNotEmpty) {
        _selectedEventId = fnVM.upcomingFunctions.first.id;
      }

      if (_selectedEventId != null) {
        await _loadExistingMaterials(_selectedEventId!);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadExistingMaterials(String eventId) async {
    final compId = context.read<AuthCompanyViewModel>().activeCompany?.id;
    if (compId == null) return;

    final existing = await context.read<FunctionsViewModel>().getEventMaterials(compId, eventId);
    if (mounted) {
      setState(() {
        _materialItems.clear();
        _materialItems.addAll(existing);
      });
    }
  }

  EventMaterialModel? _findExistingItem(String itemName) {
    try {
      return _materialItems.firstWhere(
            (m) =>
        m.itemName.toLowerCase() == itemName.toLowerCase() ||
            m.itemNameHi.toLowerCase() == itemName.toLowerCase() ||
            m.itemNameMr.toLowerCase() == itemName.toLowerCase() ||
            m.itemNameGu.toLowerCase() == itemName.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Compact, clean AlertDialog for selecting quantity and adding/updating spices and materials.
  /// Replaced the complex bottom sheet as requested by the user.
  void _openQuantityPickerDialog(CatalogueItem catItem) {
    final existing = _findExistingItem(catItem.en);
    final authVM = context.read<AuthCompanyViewModel>();
    final langCode = authVM.currentLanguage;
    final displayName = catItem.getName(langCode);

    double currentQty = existing != null ? existing.quantity : catItem.defaultQty;
    String currentUnit = existing != null ? existing.unit : catItem.defaultUnit;

    final qtyCtrl = TextEditingController(
      text: currentQty == currentQty.roundToDouble() ? currentQty.toInt().toString() : currentQty.toString(),
    );

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void updateQty(double delta) {
              final parsed = double.tryParse(qtyCtrl.text) ?? 1.0;
              final next = (parsed + delta).clamp(0.1, 9999.0);
              setDialogState(() {
                qtyCtrl.text = next == next.roundToDouble() ? next.toInt().toString() : next.toStringAsFixed(1);
              });
            }

            void setQty(double val) {
              setDialogState(() {
                qtyCtrl.text = val == val.roundToDouble() ? val.toInt().toString() : val.toString();
              });
            }

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              titlePadding: const EdgeInsets.fromLTRB(18, 16, 14, 0),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _toTitleCase(displayName),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _ink,
                          ),
                        ),
                        if (displayName != catItem.en)
                          Text(
                            _toTitleCase(catItem.en),
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _toTitleCase(catItem.category),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _navy),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.close_rounded, size: 20, color: _muted),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 18),
                      Text(
                        _toTitleCase(context.tr('quantity')),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _muted),
                      ),
                      const SizedBox(height: 8),

                      // Stepper & Unit Selector Row
                      Row(
                        children: [
                          // Minus button
                          Material(
                            color: _pageBackground,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => updateQty(-1.0),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _line),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.remove, color: _navy, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Editable textfield
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 44,
                              child: TextField(
                                controller: qtyCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: _navy,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                                  filled: true,
                                  fillColor: _navy.withValues(alpha: 0.04),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: _navy, width: 1),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: _line),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: _navy, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Plus button
                          Material(
                            color: _pageBackground,
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => updateQty(1.0),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _line),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add, color: _navy, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Unit Dropdown
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 44,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _line),
                                color: _pageBackground,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currentUnit,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'kg', child: Text('kg', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                                    DropdownMenuItem(value: 'g', child: Text('g', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                                    DropdownMenuItem(value: 'l', child: Text('L', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                                    DropdownMenuItem(value: 'pcs', child: Text('pcs', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                                    DropdownMenuItem(value: 'packet', child: Text('pkt', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => currentUnit = v);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Quick preset buttons
                      Text(
                        'Quick Shortcuts:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: (currentUnit == 'g'
                              ? [50.0, 100.0, 200.0, 250.0, 500.0, 1000.0]
                              : currentUnit == 'pcs'
                              ? [10.0, 25.0, 50.0, 100.0, 200.0, 500.0]
                              : currentUnit == 'l'
                              ? [0.5, 1.0, 2.0, 5.0, 10.0, 15.0]
                              : [0.5, 1.0, 2.0, 5.0, 10.0, 25.0, 50.0])
                              .map((val) {
                            final valStr = val == val.roundToDouble() ? val.toInt().toString() : val.toString();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: InkWell(
                                onTap: () => setQty(val),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _pageBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _line),
                                  ),
                                  child: Text(
                                    '$valStr $currentUnit',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _ink),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              actions: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (existing != null) ...[
                      // Quick delete button - full-width outlined button prevents any horizontal overflow
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red.shade700,
                          side: BorderSide(color: Colors.red.shade300),
                          minimumSize: const Size(double.infinity, 38),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        icon: const Icon(Icons.delete_outline_rounded, size: 17),
                        label: Text(
                          _toTitleCase(context.tr('remove_item')),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          setState(() {
                            _materialItems.removeWhere((m) => m.itemName.toLowerCase() == catItem.en.toLowerCase());
                          });
                          Navigator.pop(dialogCtx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed ${_toTitleCase(displayName)} from list'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.red.shade700,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        // Cancel
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _muted,
                              side: const BorderSide(color: _line),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            onPressed: () => Navigator.pop(dialogCtx),
                            child: Text(
                              _toTitleCase(context.tr('cancel')),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Add / Update Button
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _navy,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: Icon(existing != null ? Icons.check_circle_outline : Icons.add_rounded, size: 17),
                            label: Text(
                              _toTitleCase(existing != null ? context.tr('update_qty') : context.tr('add_to_list')),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              final finalQty = double.tryParse(qtyCtrl.text) ?? 1.0;
                              if (finalQty <= 0) return;

                              final item = EventMaterialModel(
                                id: existing?.id ?? 'em_${const Uuid().v4().substring(0, 8)}',
                                eventId: _selectedEventId ?? 'unknown',
                                companyId: authVM.activeCompany?.id ?? '',
                                category: catItem.category,
                                itemName: catItem.en,
                                itemNameHi: catItem.hi,
                                itemNameMr: catItem.mr,
                                itemNameGu: catItem.gu,
                                quantity: finalQty,
                                unit: currentUnit,
                              );

                              setState(() {
                                _materialItems.removeWhere((m) => m.itemName.toLowerCase() == catItem.en.toLowerCase());
                                _materialItems.add(item);
                              });

                              Navigator.pop(dialogCtx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${_toTitleCase(displayName)} ($finalQty $currentUnit) updated!'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: _emerald,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openCustomItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    String selectedCat = _selectedCategoryKey == 'all' ? 'spices' : _selectedCategoryKey;
    String selectedUnit = 'kg';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            _toTitleCase(context.tr('custom_item')),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
          ),
          content: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: _toTitleCase(context.tr('item_name')),
                    hint: 'e.g. Saffron / पिस्ता / केसर',
                    controller: nameCtrl,
                    prefixIcon: Icons.fastfood_outlined,
                  ),
                  const SizedBox(height: 12),
                  // Category Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _toTitleCase(context.tr('category')),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _line),
                          color: _pageBackground,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedCat,
                            isExpanded: true,
                            items: _categories.where((c) => c['key'] != 'all').map((c) {
                              return DropdownMenuItem<String>(
                                value: c['key'] as String,
                                child: Text(
                                  _toTitleCase(c['label'] as String),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _ink),
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setDialogState(() => selectedCat = v);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: _toTitleCase(context.tr('quantity')),
                          controller: qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: Icons.scale_rounded,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _toTitleCase(context.tr('unit')),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: _line),
                                color: _pageBackground,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedUnit,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'kg', child: Text('kg', style: TextStyle(fontWeight: FontWeight.w600))),
                                    DropdownMenuItem(value: 'g', child: Text('g', style: TextStyle(fontWeight: FontWeight.w600))),
                                    DropdownMenuItem(value: 'pcs', child: Text('pcs', style: TextStyle(fontWeight: FontWeight.w600))),
                                    DropdownMenuItem(value: 'l', child: Text('L', style: TextStyle(fontWeight: FontWeight.w600))),
                                    DropdownMenuItem(value: 'packet', child: Text('pkt', style: TextStyle(fontWeight: FontWeight.w600))),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => selectedUnit = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _muted,
                      side: const BorderSide(color: _line),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Text(
                      _toTitleCase(context.tr('cancel')),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;
                      if (name.isEmpty || qty <= 0) return;

                      final authVM = context.read<AuthCompanyViewModel>();
                      final item = EventMaterialModel(
                        id: 'em_${const Uuid().v4().substring(0, 8)}',
                        eventId: _selectedEventId ?? 'unknown',
                        companyId: authVM.activeCompany?.id ?? '',
                        category: selectedCat,
                        itemName: name,
                        itemNameHi: name,
                        itemNameMr: name,
                        itemNameGu: name,
                        quantity: qty,
                        unit: selectedUnit,
                      );

                      setState(() => _materialItems.add(item));
                      Navigator.pop(dialogCtx);
                    },
                    child: Text(
                      _toTitleCase(context.tr('add_item_to_list')),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveList() async {
    if (_selectedEventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event first')),
      );
      return;
    }

    if (_materialItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one material/spice to the list')),
      );
      return;
    }

    final comp = context.read<AuthCompanyViewModel>().activeCompany;
    if (comp != null) {
      await context.read<FunctionsViewModel>().saveEventMaterials(comp.id, _selectedEventId!, _materialItems);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('material_list_saved')),
          backgroundColor: AppTheme.accentEmerald,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _showReviewAndPdfSheet() {
    final comp = context.read<AuthCompanyViewModel>().activeCompany;
    final fnVM = context.read<FunctionsViewModel>();
    final langCode = context.read<AuthCompanyViewModel>().currentLanguage;

    final event = fnVM.allFunctions.firstWhere(
          (f) => f.id == _selectedEventId,
      orElse: () => FunctionModel(
        id: _selectedEventId ?? 'fn_preview',
        companyId: comp?.id ?? '',
        customerName: 'Client',
        customerPhone: '',
        eventName: 'Catering Event',
        eventType: 'wedding',
        eventDate: DateTime.now().toIso8601String().substring(0, 10),
        venue: '',
        guestCount: 200,
        createdAt: '',
        updatedAt: '',
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bCtx, setListState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _toTitleCase(context.tr('preview_list')),
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_materialItems.length} Items Listed for ${_toTitleCase(event.eventName)}',
                            style: const TextStyle(fontSize: 12, color: _muted),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: _muted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Preview Header Card (3D clean card)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _pageBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _line),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _toTitleCase(comp?.name ?? 'Catering Firm'),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: _navy),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${_toTitleCase(event.eventName)} • ${event.guestCount} Guests',
                                    style: const TextStyle(fontSize: 11.5, color: _muted),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _line),
                              ),
                              child: Text(
                                _formatDate(event.eventDate),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: _navy),
                              ),
                            ),
                          ],
                        ),
                        if (event.dishes.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _line),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.soup_kitchen_rounded, size: 14, color: _navy),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Dishes (${event.dishes.length}): ${event.dishes.map((d) => _toTitleCase(d.dishName)).join(", ")}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _ink),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Open Native PDF Preview & WhatsApp Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                          label: Text(
                            _toTitleCase(context.tr('open_preview_pdf')),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            if (comp != null) {
                              PdfGeneratorService.printOrPreviewMaterialPdf(
                                company: comp,
                                function: event,
                                materials: _materialItems,
                                langCode: langCode,
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 11),
                          ),
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: Text(
                            _toTitleCase(context.tr('share_whatsapp')),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () {
                            if (comp != null) {
                              PdfGeneratorService.shareMaterialPdf(
                                company: comp,
                                function: event,
                                materials: _materialItems,
                                langCode: langCode,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Items List with Delete
                  Expanded(
                    child: _materialItems.isEmpty
                        ? const Center(child: Text('No items added yet.'))
                        : ListView.separated(
                      itemCount: _materialItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: _line),
                      itemBuilder: (_, i) {
                        final item = _materialItems[i];
                        final qtyStr = item.quantity == item.quantity.roundToDouble()
                            ? item.quantity.toInt().toString()
                            : item.quantity.toString();
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: _navy.withValues(alpha: 0.08),
                            child: Text('${i + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _navy)),
                          ),
                          title: Text(
                            _toTitleCase(item.getLocalizedName(langCode)),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                          ),
                          subtitle: Text(
                            _toTitleCase(item.category),
                            style: const TextStyle(fontSize: 10.5, color: _muted),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _navy.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$qtyStr ${item.unit}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _navy),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                onPressed: () {
                                  setListState(() {
                                    _materialItems.removeAt(i);
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Save Material List Button
                  CustomButton(
                    text: _toTitleCase(context.tr('save_material_list')),
                    icon: Icons.check_circle_rounded,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _saveList();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  List<CatalogueItem> _getFilteredCatalogue(String langCode) {
    final query = _searchQuery.trim().toLowerCase();

    return _catalogue.where((c) {
      // 1. Search Query filter
      if (query.isNotEmpty) {
        final matchEn = c.en.toLowerCase().contains(query);
        final matchHi = c.hi.toLowerCase().contains(query);
        final matchMr = c.mr.toLowerCase().contains(query);
        final matchGu = c.gu.toLowerCase().contains(query);
        final matchCat = c.category.toLowerCase().contains(query);
        if (!matchEn && !matchHi && !matchMr && !matchGu && !matchCat) {
          return false;
        }
      }

      // 2. Category filter
      if (_selectedCategoryKey != 'all' && query.isEmpty) {
        if (c.category != _selectedCategoryKey) return false;
      }

      // 3. Added only filter
      if (_showAddedOnly) {
        final existing = _findExistingItem(c.en);
        if (existing == null) return false;
      }

      return true;
    }).toList();
  }

  Widget _buildCookingMenuHeader(FunctionModel event) {
    final dishCount = event.dishes.length;
    final pax = event.guestCount;
    const initialShowCount = 4;
    final hasOverflowDishes = dishCount > initialShowCount;
    final displayedDishes = _showAllDishes ? event.dishes : event.dishes.take(initialShowCount).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Dishes to cook + Single Guest count (Clean & Non-redundant)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.soup_kitchen_rounded, color: _navy, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dishCount == 0 ? 'Menu Items' : 'Dishes To Cook ($dishCount)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$pax Guests',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasOverflowDishes)
                  InkWell(
                    onTap: () => setState(() => _showAllDishes = !_showAllDishes),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: _navy.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _navy.withValues(alpha: 0.15)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showAllDishes
                                ? 'Show Less'
                                : 'Show More (+${dishCount - initialShowCount})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _navy,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            _showAllDishes
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: _navy,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Dishes list display
            if (event.dishes.isEmpty)
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: _muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'No specific recipes pre-selected for this event. Cooking for $pax guests total.',
                      style: const TextStyle(fontSize: 11.5, color: _muted),
                    ),
                  ),
                ],
              )
            else if (_showAllDishes)
              // Up to 100 items displayed on same screen inside a scrollable constrained container
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: event.dishes.map((dish) => _buildDishChip(dish, pax)).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.center,
                    child: InkWell(
                      onTap: () => setState(() => _showAllDishes = false),
                      borderRadius: BorderRadius.circular(6),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Show Less',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _navy,
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.keyboard_arrow_up_rounded, size: 15, color: _navy),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              // Collapsed preview: first 4 items + inline "+X More" badge
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  ...displayedDishes.map((dish) => _buildDishChip(dish, pax)),
                  if (hasOverflowDishes)
                    InkWell(
                      onTap: () => setState(() => _showAllDishes = true),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: _navy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _navy.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+${dishCount - initialShowCount} More',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _navy,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: _navy),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishChip(FunctionDishModel dish, int eventPax) {
    final dishPax = dish.targetGuests > 0 ? dish.targetGuests.toInt() : eventPax;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_rounded, size: 12, color: _navy),
          const SizedBox(width: 5),
          Text(
            _toTitleCase(dish.dishName),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          if (dish.targetGuests > 0 && dish.targetGuests != eventPax) ...[
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: _navy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$dishPax pax',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fnVM = context.watch<FunctionsViewModel>();
    final authVM = context.watch<AuthCompanyViewModel>();
    final langCode = authVM.currentLanguage;
    final allEvents = fnVM.allFunctions.isNotEmpty ? fnVM.allFunctions : fnVM.upcomingFunctions;
    final selectedEvent = allEvents.cast<FunctionModel?>().firstWhere(
      (e) => e?.id == _selectedEventId,
      orElse: () => allEvents.isNotEmpty ? allEvents.first : null,
    );

    final filteredItems = _getFilteredCatalogue(langCode);

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedEvent != null && selectedEvent.customerName.trim().isNotEmpty
                  ? _toTitleCase(selectedEvent.customerName)
                  : (selectedEvent != null ? _toTitleCase(selectedEvent.eventName) : _toTitleCase(context.tr('make_list'))),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
                color: _ink,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (selectedEvent != null)
              Text(
                '${_toTitleCase(selectedEvent.eventName)} • ${selectedEvent.guestCount} Guests',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: _navy, size: 23),
            tooltip: _toTitleCase(context.tr('custom_item')),
            onPressed: _openCustomItemDialog,
          ),
          if (_materialItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: _showReviewAndPdfSheet,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: _navy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _navy.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_rounded, size: 14, color: _navy),
                      const SizedBox(width: 4),
                      Text(
                        '${_materialItems.length}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: _navy),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Items count badge / Preview button
              InkWell(
                onTap: _showReviewAndPdfSheet,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.playlist_add_check_rounded, size: 18, color: _navy),
                      const SizedBox(width: 6),
                      Text(
                        '${_materialItems.length}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _navy),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Save / Review Button
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shadowColor: _navy.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: Text(
                    _materialItems.isEmpty
                        ? 'Select Items'
                        : 'Review & PDF (${_materialItems.length} Items)',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                  onPressed: _materialItems.isEmpty ? null : _showReviewAndPdfSheet,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 3D Event Selector Card
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _line, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedEventId,
                  isExpanded: true,
                  isDense: true,
                  hint: Text(
                    'Select catering event…',
                    style: TextStyle(fontSize: 13, color: _muted),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _navy, size: 20),
                  items: allEvents.map((e) {
                    final hasMat = fnVM.hasCachedMaterials(e.id);
                    return DropdownMenuItem(
                      value: e.id,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_toTitleCase(e.eventName)}  •  ${_formatDate(e.eventDate)}  •  ${e.guestCount} Guests',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _ink),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasMat) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _navy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'PDF Ready',
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: _navy),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedEventId = val);
                      _loadExistingMaterials(val);
                    }
                  },
                ),
              ),
            ),
          ),

          // 2. Cooking Menu & Guests Count (Scalable 3D Card)
          if (selectedEvent != null) _buildCookingMenuHeader(selectedEvent),

          // 3. 3D Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _line, width: 1.1),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _ink),
                decoration: InputDecoration(
                  hintText: _toTitleCase(context.tr('search_materials')),
                  hintStyle: const TextStyle(fontSize: 12.5, color: _muted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: _muted),
                  prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: const Icon(Icons.close_rounded, size: 16, color: _muted),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                ),
              ),
            ),
          ),

          // 4. 3D Category Pills
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _categories.length + 1, // +1 for "Added Only" pill
              itemBuilder: (ctx, i) {
                // Special Pill: "Added Only"
                if (i == _categories.length) {
                  final isSelected = _showAddedOnly;
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: InkWell(
                      onTap: () => setState(() => _showAddedOnly = !_showAddedOnly),
                      borderRadius: BorderRadius.circular(17),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? _emerald : Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: isSelected ? _emerald : _line,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? _emerald.withValues(alpha: 0.25)
                                  : const Color(0xFF0F172A).withValues(alpha: 0.04),
                              blurRadius: isSelected ? 6 : 4,
                              offset: Offset(0, isSelected ? 2.5 : 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 13,
                              color: isSelected ? Colors.white : _emerald,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _toTitleCase(context.tr('show_added_only')),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : _ink,
                              ),
                            ),
                            if (_materialItems.isNotEmpty) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : _emerald.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_materialItems.length}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : _emerald,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final cat = _categories[i];
                final catKey = cat['key'] as String;
                final isSelected = !_showAddedOnly && _selectedCategoryKey == catKey;
                final label = cat[langCode] ?? cat['label'];
                final countInCat = catKey == 'all'
                    ? _materialItems.length
                    : _materialItems.where((m) => m.category == catKey).length;

                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _showAddedOnly = false;
                        _selectedCategoryKey = catKey;
                      });
                    },
                    borderRadius: BorderRadius.circular(17),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? _navy : Colors.white,
                        borderRadius: BorderRadius.circular(17),
                        border: Border.all(
                          color: isSelected ? _navy : _line,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? _navy.withValues(alpha: 0.25)
                                : const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: isSelected ? 6 : 4,
                            offset: Offset(0, isSelected ? 2.5 : 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 13,
                            color: isSelected ? Colors.white : _muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _toTitleCase(label),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: isSelected ? Colors.white : _ink,
                            ),
                          ),
                          if (countInCat > 0) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white.withValues(alpha: 0.25) : _navy.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$countInCat',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : _navy,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 5. 3D Catalogue Material Cards
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: _muted),
                  const SizedBox(height: 8),
                  Text(
                    _showAddedOnly ? 'No Items Added Yet' : 'No Matching Items Found',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _muted),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: _openCustomItemDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(_toTitleCase(context.tr('custom_item')), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 16),
              itemCount: filteredItems.length,
              itemBuilder: (ctx, i) {
                final catItem = filteredItems[i];
                final existing = _findExistingItem(catItem.en);
                final isAdded = existing != null;
                final displayName = catItem.getName(langCode);
                final capitalizedDisplayName = _toTitleCase(displayName);
                final capitalizedEnglish = _toTitleCase(catItem.en);

                final qtyStr = isAdded
                    ? (existing.quantity == existing.quantity.roundToDouble()
                    ? existing.quantity.toInt().toString()
                    : existing.quantity.toString())
                    : (catItem.defaultQty == catItem.defaultQty.roundToDouble()
                    ? catItem.defaultQty.toInt().toString()
                    : catItem.defaultQty.toString());
                final unitStr = isAdded ? existing.unit : catItem.defaultUnit;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isAdded ? _navy.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: isAdded ? _navy : _line,
                      width: isAdded ? 1.5 : 1.0,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openQuantityPickerDialog(catItem),
                      borderRadius: BorderRadius.circular(13),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        child: Row(
                          children: [
                            // Leading Status Checkmark
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isAdded ? _navy : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isAdded ? _navy : const Color(0xFFCBD5E1),
                                  width: 1.4,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: isAdded
                                  ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Material Names & Selected Tag
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          capitalizedDisplayName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: isAdded ? FontWeight.w700 : FontWeight.w600,
                                            color: isAdded ? _navy : _ink,
                                            height: 1.25,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (isAdded) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _navy.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: const Text(
                                            'Selected',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: _navy,
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (displayName != catItem.en)
                                    Text(
                                      capitalizedEnglish,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isAdded ? _navy.withValues(alpha: 0.65) : _muted,
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Trailing Quantity Chip
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isAdded ? _navy : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isAdded ? _navy : _line,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$qtyStr $unitStr',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isAdded ? Colors.white : _ink,
                                    ),
                                  ),
                                  if (isAdded) ...[
                                    const SizedBox(width: 5),
                                    const Icon(Icons.edit_rounded, size: 12, color: Colors.white70),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}