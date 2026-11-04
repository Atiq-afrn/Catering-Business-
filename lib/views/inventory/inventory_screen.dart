import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/company_header_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../data/models/ingredient_model.dart';
import '../../viewmodels/auth_company_viewmodel.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../auth/auth_company_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchCtrl = TextEditingController();

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
      context.read<InventoryViewModel>().loadInventory(comp.id);
    }
  }

  void _openStockAdjustmentDialog(BuildContext context, IngredientModel ing) {
    final qtyCtrl = TextEditingController(text: '10');
    final notesCtrl = TextEditingController();
    String movementType = 'received'; // 'received', 'consumed', 'wasted'

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Adjust Stock: ${ing.nameEn}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Stock: ${ing.currentStock} ${ing.baseUnit}', style: const TextStyle(fontSize: 12.5, color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(context.tr('record_stock_in'), style: const TextStyle(fontSize: 11)),
                      selected: movementType == 'received',
                      selectedColor: AppTheme.accentEmerald,
                      labelStyle: TextStyle(color: movementType == 'received' ? Colors.white : AppTheme.textPrimary),
                      onSelected: (_) => setDialogState(() => movementType = 'received'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(context.tr('record_consumption'), style: const TextStyle(fontSize: 11)),
                      selected: movementType == 'consumed',
                      selectedColor: const Color(0xFFDC2626),
                      labelStyle: TextStyle(color: movementType == 'consumed' ? Colors.white : AppTheme.textPrimary),
                      onSelected: (_) => setDialogState(() => movementType = 'consumed'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Quantity (${ing.baseUnit})',
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.scale_outlined,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                label: context.tr('notes'),
                hint: 'e.g. Received from Supplier / Consumed in Event',
                controller: notesCtrl,
              ),
            ],
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
                final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                if (qty > 0) {
                  final activeComp = context.read<AuthCompanyViewModel>().activeCompany;
                  if (activeComp != null) {
                    await context.read<InventoryViewModel>().recordStockMovement(
                          companyId: activeComp.id,
                          ingredient: ing,
                          movementType: movementType,
                          quantity: qty,
                          notes: notesCtrl.text.trim(),
                        );
                  }
                  if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final invVM = context.watch<InventoryViewModel>();
    final langCode = context.watch<AuthCompanyViewModel>().currentLanguage;
    final ingredients = invVM.filteredIngredients;

    final categories = [
      {'key': 'all', 'label': context.tr('all')},
      {'key': 'spices', 'label': 'Spices / मसाले'},
      {'key': 'grains', 'label': 'Grains / धान्य'},
      {'key': 'vegetables', 'label': 'Vegetables / सब्जियां'},
      {'key': 'dairy', 'label': 'Dairy / दुग्ध उत्पाद'},
      {'key': 'groceries', 'label': 'Groceries / किराना'},
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceBackground,
      appBar: AppBar(
        title: Text(context.tr('inventory_title')),
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

          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => invVM.setSearchQuery(v),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search raw materials / सामग्री खोजें...',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    invVM.setSearchQuery('');
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: Text(
                        'Low Stock',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: invVM.onlyLowStock ? FontWeight.w700 : FontWeight.w500,
                          color: invVM.onlyLowStock ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      selected: invVM.onlyLowStock,
                      selectedColor: const Color(0xFFDC2626),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      onSelected: (_) => invVM.toggleLowStockFilter(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = invVM.selectedCategory == cat['key'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat['label']!, style: TextStyle(fontSize: 11.5, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryNavy,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : AppTheme.textPrimary),
                          backgroundColor: const Color(0xFFF1F5F9),
                          side: BorderSide.none,
                          onSelected: (_) => invVM.setCategoryFilter(cat['key']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Inventory Items List
          Expanded(
            child: invVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: ingredients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ing = ingredients[index];
                      final name = ing.getName(langCode);
                      final isLow = ing.currentStock <= ing.minThreshold && ing.minThreshold > 0;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isLow ? const Color(0xFFFCA5A5) : AppTheme.borderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isLow ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isLow ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
                                color: isLow ? const Color(0xFFDC2626) : AppTheme.primaryNavy,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                                      ),
                                      if (isLow) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: const Color(0xFFF87171)),
                                          ),
                                          child: const Text('Low', style: TextStyle(fontSize: 9.5, color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ing.nameEn} • Rate: ₹${ing.defaultPurchasePrice.toStringAsFixed(0)}/${ing.baseUnit} • Min: ${ing.minThreshold.toInt()} ${ing.baseUnit}',
                                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${ing.currentStock.toStringAsFixed(ing.currentStock % 1 == 0 ? 0 : 2)} ${ing.baseUnit}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isLow ? const Color(0xFFDC2626) : AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () => _openStockAdjustmentDialog(context, ing),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppTheme.borderLight),
                                    ),
                                    child: const Text('Adjust', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                                  ),
                                ),
                              ],
                            ),
                          ],
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
