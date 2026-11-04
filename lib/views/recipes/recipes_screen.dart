import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/company_header_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/recipe_model.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/recipes_viewmodel.dart';
import '../auth/auth_company_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _searchCtrl = TextEditingController();
  final _calcPaxCtrl = TextEditingController(text: '150');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
    });
  }

  void _load() {
    final comp = context.read<AuthCompanyViewModel>().activeCompany;
    if (comp != null) {
      context.read<RecipesViewModel>().loadRecipes(comp.id);
    }
  }

  void _openAddRecipeDialog(BuildContext context) {
    final nameEnCtrl = TextEditingController();
    final nameHiCtrl = TextEditingController();
    final nameGuCtrl = TextEditingController();
    final basePaxCtrl = TextEditingController(text: '100');
    final servingSizeCtrl = TextEditingController(text: '150');
    final yieldCtrl = TextEditingController(text: '20');
    final notesCtrl = TextEditingController();
    String category = 'cat_curry';

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(context.tr('create_recipe'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Dish Name (English)',
                  hint: 'e.g. Veg Kolhapuri',
                  controller: nameEnCtrl,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'नाम (हिन्दी)',
                        hint: 'वेज कोल्हापुरी',
                        controller: nameHiCtrl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: 'નામ (ગુજરાતી)',
                        hint: 'વેજ કોલ્હાપુરી',
                        controller: nameGuCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: context.tr('base_quantity'),
                        hint: '100',
                        controller: basePaxCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        label: '${context.tr('cooking_yield')} (kg)',
                        hint: '20',
                        controller: yieldCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: context.tr('notes'),
                  hint: 'Preparation stages & spice ratios',
                  controller: notesCtrl,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          CustomButton(
            text: context.tr('cancel'),
            variant: ButtonVariant.outline,
            isDense: true,
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          CustomButton(
            text: context.tr('save'),
            isDense: true,
            onPressed: () async {
              if (nameEnCtrl.text.isNotEmpty) {
                final authVM = context.read<AuthCompanyViewModel>();
                final activeComp = authVM.activeCompany;
                if (activeComp != null) {
                  final newRecipe = RecipeModel(
                    id: 'rec_${const Uuid().v4().substring(0, 8)}',
                    companyId: activeComp.id,
                    dishNameEn: nameEnCtrl.text.trim(),
                    dishNameHi: nameHiCtrl.text.trim(),
                    dishNameGu: nameGuCtrl.text.trim(),
                    category: category,
                    baseQuantity: double.tryParse(basePaxCtrl.text) ?? 100.0,
                    cookingYield: double.tryParse(yieldCtrl.text) ?? 20.0,
                    servingSize: double.tryParse(servingSizeCtrl.text) ?? 150.0,
                    notes: notesCtrl.text.trim(),
                    updatedAt: DateTime.now().toIso8601String(),
                  );
                  await context.read<RecipesViewModel>().saveRecipe(newRecipe);
                }
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recVM = context.watch<RecipesViewModel>();
    final langCode = context.watch<AuthCompanyViewModel>().currentLanguage;
    final recipes = recVM.filteredRecipes;
    final selectedRecipe = recVM.selectedRecipeForCalc;

    final categories = [
      {'key': 'all', 'label': context.tr('all')},
      {'key': 'cat_rice', 'label': context.tr('cat_rice')},
      {'key': 'cat_curry', 'label': context.tr('cat_curry')},
      {'key': 'cat_dal', 'label': context.tr('cat_dal')},
      {'key': 'cat_dessert', 'label': context.tr('cat_dessert')},
      {'key': 'cat_bread', 'label': context.tr('cat_bread')},
      {'key': 'cat_salad', 'label': context.tr('cat_salad')},
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('recipes_title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.tr('create_recipe'),
            onPressed: () => _openAddRecipeDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Company Scope Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: CompanyHeaderCard(
              onSwitchCompany: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthCompanyScreen()),
                ).then((_) => _load());
              },
            ),
          ),

          // Search & Categories Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => recVM.setSearchQuery(v),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: context.tr('search'),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              recVM.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                  final isSelected = recVM.selectedCategory == cat['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat['label']!, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          onSelected: (_) => recVM.setCategoryFilter(cat['key']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Layout: Split or Stack (Calculator at top, recipe selector)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dynamic Scaling Engine Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentEmerald.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.calculate_rounded, color: AppTheme.accentEmerald, size: 18),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  context.tr('recipe_calculator'),
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            if (selectedRecipe != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  selectedRecipe.getDishName(langCode),
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Calculation Mode Tabs
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment(
                              value: 'people',
                              label: Text(context.tr('basis_people'), style: const TextStyle(fontSize: 11)),
                              icon: const Icon(Icons.people_alt_outlined, size: 14),
                            ),
                            ButtonSegment(
                              value: 'raw_ingredient',
                              label: Text(context.tr('basis_raw'), style: const TextStyle(fontSize: 11)),
                              icon: const Icon(Icons.scale_outlined, size: 14),
                            ),
                            ButtonSegment(
                              value: 'finished_weight',
                              label: Text(context.tr('basis_yield'), style: const TextStyle(fontSize: 11)),
                              icon: const Icon(Icons.dinner_dining_outlined, size: 14),
                            ),
                          ],
                          selected: {recVM.calculatorMode},
                          onSelectionChanged: (val) {
                            recVM.updateCalculatorMode(val.first);
                          },
                        ),
                        const SizedBox(height: 14),

                        // Interactive Guest Slider / Input
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${context.tr('scaled_for')}: ${recVM.calculatorTargetQuantity.toInt()} ${recVM.calculatorMode == 'people' ? context.tr('guests') : 'kg'}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                                  ),
                                  Slider(
                                    value: recVM.calculatorTargetQuantity.clamp(10.0, 2000.0),
                                    min: 10.0,
                                    max: 2000.0,
                                    divisions: 199,
                                    activeColor: AppTheme.primaryNavy,
                                    onChanged: (val) {
                                      _calcPaxCtrl.text = val.toInt().toString();
                                      recVM.updateCalculatorTarget(val);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 80,
                              child: CustomTextField(
                                label: 'Input',
                                controller: _calcPaxCtrl,
                                keyboardType: TextInputType.number,
                                onChanged: (v) {
                                  final num = double.tryParse(v);
                                  if (num != null && num > 0) {
                                    recVM.updateCalculatorTarget(num);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Calculated Ingredients Table
                        Text(
                          context.tr('ingredients'),
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),

                        if (recVM.calculatedItems.isEmpty)
                          Text(context.tr('no_data'), style: const TextStyle(color: AppTheme.textMuted))
                        else
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.borderLight),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recVM.calculatedItems.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (c, idx) {
                                final item = recVM.calculatedItems[idx];
                                final name = item.getName(langCode);

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          name,
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${item.requiredQuantity.toStringAsFixed(item.requiredQuantity % 1 == 0 ? 0 : 2)} ${item.unit}',
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          item.toPurchaseQuantity > 0
                                              ? 'Buy: ${item.toPurchaseQuantity.toStringAsFixed(item.toPurchaseQuantity % 1 == 0 ? 0 : 2)} ${item.unit}'
                                              : 'In Stock',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: item.toPurchaseQuantity > 0 ? const Color(0xFFB45309) : AppTheme.accentEmerald,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Recipe Catalogue Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('recipes_title'),
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${recipes.length} Dishes',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final rec = recipes[index];
                      final isSelected = selectedRecipe?.id == rec.id;

                      return InkWell(
                        onTap: () {
                          recVM.setRecipeForCalculator(rec);
                          _calcPaxCtrl.text = rec.baseQuantity.toInt().toString();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppTheme.accentEmerald : AppTheme.borderLight,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: isSelected ? AppTheme.accentEmerald : const Color(0xFFF1F5F9),
                                child: Icon(
                                  Icons.restaurant_rounded,
                                  color: isSelected ? Colors.white : AppTheme.primaryNavy,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec.getDishName(langCode),
                                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${context.tr(rec.category)} • Base: ${rec.baseQuantity.toInt()} pax • Yield: ${rec.cookingYield.toInt()} kg',
                                      style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
                                    ),
                                    if (rec.notes.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        rec.notes,
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              CustomButton(
                                text: isSelected ? 'Active' : 'Scale',
                                variant: isSelected ? ButtonVariant.secondary : ButtonVariant.outline,
                                isDense: true,
                                onPressed: () {
                                  recVM.setRecipeForCalculator(rec);
                                  _calcPaxCtrl.text = rec.baseQuantity.toInt().toString();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
