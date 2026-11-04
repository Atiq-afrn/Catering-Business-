import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/function_model.dart';
import '../../data/models/recipe_model.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/functions_viewmodel.dart';
import '../../viewmodels/recipes_viewmodel.dart';

class CreateFunctionScreen extends StatefulWidget {
  const CreateFunctionScreen({super.key});

  @override
  State<CreateFunctionScreen> createState() => _CreateFunctionScreenState();
}

class _CreateFunctionScreenState extends State<CreateFunctionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _venueCtrl = TextEditingController(); // Optional address
  final _guestsCtrl = TextEditingController(text: '200'); // People to cook for
  final _quotationCtrl = TextEditingController(text: '100000');
  final _advanceCtrl = TextEditingController(text: '30000');
  final _notesCtrl = TextEditingController();

  String _selectedEventType = 'wedding';
  final String _selectedServiceStyle = 'buffet';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 30);
  final List<RecipeModel> _selectedDishes = [];

  final List<Map<String, dynamic>> _eventTypes = [
    {'key': 'wedding', 'label': 'Wedding (Vivah)', 'icon': Icons.favorite_rounded},
    {'key': 'birthday', 'label': 'Birthday Party', 'icon': Icons.cake_rounded},
    {'key': 'engagement', 'label': 'Engagement (Sagai)', 'icon': Icons.diamond_rounded},
    {'key': 'reception', 'label': 'Reception', 'icon': Icons.celebration_rounded},
    {'key': 'religious', 'label': 'Religious / Pooja', 'icon': Icons.auto_awesome_rounded},
    {'key': 'gathering', 'label': 'Social Gathering / Party', 'icon': Icons.groups_rounded},
    {'key': 'corporate', 'label': 'Corporate Event', 'icon': Icons.business_center_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final compId = context.read<AuthCompanyViewModel>().activeCompany?.id;
      if (compId != null) {
        context.read<RecipesViewModel>().loadRecipes(compId);
      }
    });
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _phoneCtrl.dispose();
    _venueCtrl.dispose();
    _guestsCtrl.dispose();
    _quotationCtrl.dispose();
    _advanceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _getEventTypeName(String key) {
    final found = _eventTypes.firstWhere(
      (e) => e['key'] == key,
      orElse: () => {'key': key, 'label': key.toUpperCase(), 'icon': Icons.event_rounded},
    );
    return found['label'] as String;
  }

  /// Dialog to add a custom dish that is not currently in the recipe catalogue.
  /// Saves the dish to the database and adds it to the active selection.
  void _openAddCustomDishDialog(BuildContext context, {String initialName = '', VoidCallback? onSaved}) {
    final nameCtrl = TextEditingController(text: initialName);
    String selectedCategory = 'main_course';

    final categories = [
      {'key': 'starters', 'label': 'Starters / Snacks'},
      {'key': 'main_course', 'label': 'Main Course (Sabji/Paneer)'},
      {'key': 'rice_bread', 'label': 'Rice & Breads (Roti/Pulao)'},
      {'key': 'sweets', 'label': 'Sweets & Desserts (Mithai)'},
      {'key': 'dal_soup', 'label': 'Dals & Soups'},
      {'key': 'beverages', 'label': 'Beverages & Drinks'},
      {'key': 'other', 'label': 'Other Items'},
    ];

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Add Custom Dish / Item',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          ),
          content: SizedBox(
            width: 320,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    label: 'Dish / Item Name',
                    hint: 'e.g. Kaju Curry, Gulab Jamun, Dal Tadka',
                    controller: nameCtrl,
                    prefixIcon: Icons.restaurant_menu_rounded,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Category',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        items: categories.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['key']!,
                            child: Text(c['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedCategory = v);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppTheme.textSecondary),
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: AppTheme.primaryDark.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final compId = context.read<AuthCompanyViewModel>().activeCompany?.id ?? '';
                final newRecipe = RecipeModel(
                  id: 'dish_${DateTime.now().millisecondsSinceEpoch}',
                  companyId: compId,
                  dishNameEn: name,
                  dishNameHi: name,
                  dishNameGu: name,
                  category: selectedCategory,
                  updatedAt: DateTime.now().toIso8601String(),
                );

                await context.read<RecipesViewModel>().saveRecipe(newRecipe);

                if (mounted) {
                  setState(() {
                    _selectedDishes.removeWhere((d) => d.id == newRecipe.id);
                    _selectedDishes.add(newRecipe);
                  });
                }

                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                onSaved?.call();
              },
              child: const Text('Add Dish', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _openDishPicker(BuildContext context) {
    final langCode = context.read<AuthCompanyViewModel>().currentLanguage;
    final searchCtrl = TextEditingController();
    String query = '';

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final allRecipes = context.watch<RecipesViewModel>().filteredRecipes;

            final filtered = allRecipes.where((r) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();
              return r.getDishName(langCode).toLowerCase().contains(q) ||
                  r.dishNameEn.toLowerCase().contains(q) ||
                  r.category.toLowerCase().contains(q);
            }).toList();

            final mediaQuery = MediaQuery.of(ctx);
            final availableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
            final dialogContentHeight = (availableHeight * 0.62).clamp(260.0, 520.0);

            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              actionsPadding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.restaurant_menu_rounded, color: AppTheme.primaryNavy, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Select Menu Items',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.pop(dialogCtx),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                height: dialogContentHeight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                  // Search field & Add Custom Button
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: TextField(
                            controller: searchCtrl,
                            onChanged: (v) => setDialogState(() => query = v),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            decoration: InputDecoration(
                              hintText: 'Search dish name (e.g. Paneer, Dal)...',
                              hintStyle: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
                              prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
                              suffixIcon: query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        searchCtrl.clear();
                                        setDialogState(() => query = '');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                              filled: true,
                              fillColor: AppTheme.surfaceBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.borderLight),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: AppTheme.borderLight),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Prominent Add Custom Dish button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryDark,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppTheme.primaryDark.withValues(alpha: 0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text(
                          'Add New',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          _openAddCustomDishDialog(
                            context,
                            initialName: query.trim(),
                            onSaved: () {
                              setDialogState(() {});
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dish List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.restaurant_outlined, size: 36, color: AppTheme.textSecondary),
                                  const SizedBox(height: 8),
                                  Text(
                                    query.isEmpty ? 'No dishes available.' : 'No dish found matching "$query"',
                                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryDark,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shadowColor: AppTheme.primaryDark.withValues(alpha: 0.35),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(Icons.add_rounded, size: 18),
                                    label: Text(
                                      query.isNotEmpty ? 'Add "$query" to Menu' : 'Add Custom Dish',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                    ),
                                    onPressed: () {
                                      _openAddCustomDishDialog(
                                        context,
                                        initialName: query.trim(),
                                        onSaved: () {
                                          setDialogState(() {});
                                          setState(() {});
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (c, i) {
                              final rec = filtered[i];
                              final isAdded = _selectedDishes.any((d) => d.id == rec.id);

                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                leading: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isAdded ? AppTheme.accentEmerald.withAlpha(20) : AppTheme.surfaceBackground,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    isAdded ? Icons.check_circle_rounded : Icons.restaurant_rounded,
                                    color: isAdded ? AppTheme.accentEmerald : AppTheme.textSecondary,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  rec.getDishName(langCode),
                                  style: TextStyle(
                                    fontWeight: isAdded ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13.5,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                subtitle: Text(
                                  rec.category.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(fontSize: 10.5, color: AppTheme.textSecondary),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAdded ? AppTheme.accentEmerald : AppTheme.primaryNavy.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isAdded ? AppTheme.accentEmerald : AppTheme.primaryNavy.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    isAdded ? 'Added' : '+ Add',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isAdded ? Colors.white : AppTheme.primaryNavy,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  setDialogState(() {
                                    if (isAdded) {
                                      _selectedDishes.removeWhere((d) => d.id == rec.id);
                                    } else {
                                      _selectedDishes.add(rec);
                                    }
                                  });
                                  setState(() {});
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Done (${_selectedDishes.length} items selected)',
                  variant: ButtonVariant.primary,
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.pop(dialogCtx),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthCompanyViewModel>();
    final activeComp = authVM.activeCompany;
    final langCode = authVM.currentLanguage;

    // Formatted date showing Day, Full Month Name, and Year (e.g. 24 October 2026)
    final formattedDate = DateFormat('dd MMMM yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(
          context.tr('new_booking'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Event Information Card (No redundant Event Name input)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.event_note_rounded, size: 18, color: AppTheme.primaryNavy),
                        SizedBox(width: 8),
                        Text(
                          'Event Information',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Event Type Dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('event_type'),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedEventType,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryNavy),
                              items: _eventTypes.map((e) {
                                return DropdownMenuItem<String>(
                                  value: e['key'] as String,
                                  child: Row(
                                    children: [
                                      Icon(e['icon'] as IconData, size: 16, color: AppTheme.primaryNavy),
                                      const SizedBox(width: 8),
                                      Text(
                                        e['label'] as String,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _selectedEventType = v);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // People to Cook For (Guest Count / Pax)
                    CustomTextField(
                      label: context.tr('people_to_cook_for'),
                      hint: 'e.g. 250 Pax',
                      controller: _guestsCtrl,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.soup_kitchen_rounded,
                      validator: (v) {
                        final parsed = int.tryParse(v ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Please enter valid guest count (e.g. 200)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Event Date & Time Selection (Showing Year, Month Name, and Date)
                    Row(
                      children: [
                        // Date Picker: Shows 24 October 2026
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booking Date',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2035),
                                    builder: (pickerCtx, child) {
                                      return Theme(
                                        data: Theme.of(pickerCtx).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: AppTheme.primaryDark,
                                            onPrimary: Colors.white,
                                            onSurface: AppTheme.textPrimary,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (d != null) setState(() => _selectedDate = d);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, size: 17, color: AppTheme.primaryNavy),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          formattedDate,
                                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Time Picker
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time',
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 5),
                              InkWell(
                                onTap: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTime,
                                  );
                                  if (t != null) setState(() => _selectedTime = t);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.borderLight),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded, size: 17, color: AppTheme.primaryNavy),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Venue / Address (Optional)
                    CustomTextField(
                      label: context.tr('venue_optional'),
                      hint: 'e.g. Shanti Bhavan Hall, Station Road (Optional)',
                      controller: _venueCtrl,
                      prefixIcon: Icons.location_on_outlined,
                      // Address is optional as requested
                      validator: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 2. Customer Details Card (Name and Phone)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.person_outline_rounded, size: 18, color: AppTheme.primaryNavy),
                        SizedBox(width: 8),
                        Text(
                          'Customer Information',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: context.tr('customer_name'),
                            hint: 'Full Name',
                            controller: _customerCtrl,
                            prefixIcon: Icons.person_rounded,
                            validator: (v) => v == null || v.trim().isEmpty ? 'Customer name required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: context.tr('phone'),
                            hint: '10-digit Mobile',
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            prefixIcon: Icons.phone_rounded,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Mobile number required';
                              if (v.trim().length < 8) return 'Valid phone number required';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Menu Dishes Selection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restaurant_menu_rounded, size: 18, color: AppTheme.primaryNavy),
                            const SizedBox(width: 8),
                            Text(
                              'Menu Items (${_selectedDishes.length})',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryDark,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AppTheme.primaryDark.withValues(alpha: 0.35),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text(
                            'Add Dishes',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => _openDishPicker(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_selectedDishes.isEmpty)
                      InkWell(
                        onTap: () => _openDishPicker(context),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceBackground,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.borderLight),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.add_circle_outline_rounded, size: 28, color: AppTheme.textSecondary),
                              SizedBox(height: 6),
                              Text(
                                'Tap to choose or add dishes for this booking',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedDishes.map((d) {
                          return Chip(
                            backgroundColor: AppTheme.surfaceBackground,
                            side: const BorderSide(color: AppTheme.borderLight),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            label: Text(
                              d.getDishName(langCode),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                            ),
                            deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppTheme.textSecondary),
                            onDeleted: () {
                              setState(() {
                                _selectedDishes.removeWhere((item) => item.id == d.id);
                              });
                            },
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Commercials & Financials Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.payments_outlined, size: 18, color: AppTheme.primaryNavy),
                        SizedBox(width: 8),
                        Text(
                          'Payment & Commercials',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'Quotation Amount (₹)',
                            hint: '150000',
                            controller: _quotationCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.currency_rupee_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            label: 'Advance Received (₹)',
                            hint: '50000',
                            controller: _advanceCtrl,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icons.account_balance_wallet_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'Notes / Kitchen Instructions (Optional)',
                      hint: 'Special requests, Jain food, cooking instructions...',
                      controller: _notesCtrl,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 5. Save Action Button (Consistent Primary Button)
              CustomButton(
                text: context.tr('save_booking'),
                variant: ButtonVariant.primary,
                width: double.infinity,
                icon: Icons.check_circle_rounded,
                onPressed: () async {
                  if (_formKey.currentState?.validate() == true && activeComp != null) {
                    final pax = int.tryParse(_guestsCtrl.text.trim()) ?? 100;
                    final quotation = double.tryParse(_quotationCtrl.text.trim()) ?? 0.0;
                    final advance = double.tryParse(_advanceCtrl.text.trim()) ?? 0.0;
                    final fnId = 'fn_${DateTime.now().millisecondsSinceEpoch}';
                    final now = DateTime.now().toIso8601String();

                    // Generate meaningful event name from event type and customer
                    final eventTypeName = _getEventTypeName(_selectedEventType);
                    final customer = _customerCtrl.text.trim();
                    final generatedEventName = '$customer - $eventTypeName';

                    final newFunction = FunctionModel(
                      id: fnId,
                      companyId: activeComp.id,
                      customerName: customer,
                      customerPhone: _phoneCtrl.text.trim(),
                      eventName: generatedEventName,
                      eventType: _selectedEventType,
                      eventDate: _selectedDate.toIso8601String().substring(0, 10),
                      eventTime: _selectedTime.format(context),
                      venue: _venueCtrl.text.trim(),
                      guestCount: pax,
                      serviceStyle: _selectedServiceStyle,
                      status: 'confirmed',
                      quotationAmount: quotation,
                      advancePaid: advance,
                      balanceDue: (quotation - advance).clamp(0.0, double.infinity),
                      notes: _notesCtrl.text.trim(),
                      dishes: _selectedDishes.map((d) {
                        return FunctionDishModel(
                          id: const Uuid().v4(),
                          functionId: fnId,
                          companyId: activeComp.id,
                          recipeId: d.id,
                          dishName: d.dishNameEn,
                          targetGuests: pax.toDouble(),
                        );
                      }).toList(),
                      createdAt: now,
                      updatedAt: now,
                    );

                    await context.read<FunctionsViewModel>().saveFunction(newFunction);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking for $customer ($eventTypeName) saved successfully!'),
                          backgroundColor: AppTheme.accentEmerald,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
