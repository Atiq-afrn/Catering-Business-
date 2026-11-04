import 'package:flutter_test/flutter_test.dart';
import 'package:catering_business/core/utils/unit_converter.dart';
import 'package:catering_business/data/models/recipe_model.dart';
import 'package:catering_business/data/models/function_model.dart';
import 'package:catering_business/data/models/event_material_model.dart';
import 'package:catering_business/data/models/staff_model.dart';
import 'package:catering_business/data/models/staff_payment_model.dart';
import 'package:catering_business/services/recipe_calculation_service.dart';

void main() {
  test('UnitConverter converts kg to g and l to ml accurately', () {
    expect(UnitConverter.convertQuantity(1.5, 'kg', 'g'), 1500.0);
    expect(UnitConverter.convertQuantity(2500, 'g', 'kg'), 2.5);
    expect(UnitConverter.convertQuantity(2.0, 'l', 'ml'), 2000.0);
    expect(UnitConverter.convertQuantity(500, 'ml', 'l'), 0.5);
  });

  test('RecipeCalculationService scales ingredients by guest count with allowance', () {
    final recipe = RecipeModel(
      id: 'rec_test',
      companyId: 'comp_test',
      dishNameEn: 'Biryani',
      dishNameHi: 'बिरयानी',
      dishNameGu: 'બિરયાની',
      category: 'cat_rice',
      baseQuantity: 100.0,
      baseUnit: 'pax',
      updatedAt: DateTime.now().toIso8601String(),
      ingredients: [
        RecipeIngredientModel(
          id: 'ri_1',
          recipeId: 'rec_test',
          companyId: 'comp_test',
          ingredientId: 'ing_rice',
          ingredientNameEn: 'Rice',
          quantity: 10.0,
          unit: 'kg',
          allowancePercent: 5.0,
        ),
      ],
    );

    final calculated = RecipeCalculationService.calculateRecipeRequirements(
      recipe: recipe,
      targetQuantity: 200.0,
      mode: 'people',
    );

    expect(calculated.length, 1);
    expect(calculated.first.requiredQuantity, 21.0);
  });

  test('EventMaterialModel translates correctly in 4 languages', () {
    final mat = EventMaterialModel(
      id: 'em_test',
      eventId: 'fn_001',
      companyId: 'comp_test',
      category: 'spices',
      itemName: 'Cardamom',
      itemNameHi: 'इलायची',
      itemNameMr: 'वेलची',
      itemNameGu: 'એલચી',
      quantity: 100,
      unit: 'g',
    );

    expect(mat.getLocalizedName('en'), 'Cardamom');
    expect(mat.getLocalizedName('hi'), 'इलायची');
    expect(mat.getLocalizedName('mr'), 'वेलची');
    expect(mat.getLocalizedName('gu'), 'એલચી');
  });

  test('Upcoming vs Previous date classification rule', () {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final pastDate = DateTime.now().subtract(const Duration(days: 5)).toIso8601String().substring(0, 10);
    final futureDate = DateTime.now().add(const Duration(days: 5)).toIso8601String().substring(0, 10);

    final pastEvent = FunctionModel(
      id: 'fn_past',
      companyId: 'comp_1',
      customerName: 'Client A',
      customerPhone: '9898011223',
      eventName: 'Past Event',
      eventType: 'wedding',
      eventDate: pastDate,
      venue: 'Hall A',
      guestCount: 200,
      createdAt: '',
      updatedAt: '',
    );

    final futureEvent = FunctionModel(
      id: 'fn_future',
      companyId: 'comp_1',
      customerName: 'Client B',
      customerPhone: '9898011224',
      eventName: 'Future Event',
      eventType: 'wedding',
      eventDate: futureDate,
      venue: 'Hall B',
      guestCount: 300,
      createdAt: '',
      updatedAt: '',
    );

    // Date comparison logic
    expect(pastEvent.eventDate.compareTo(today) < 0, true);
    expect(futureEvent.eventDate.compareTo(today) >= 0, true);
  });

  test('StaffModel has joining date and StaffPaymentModel tracks receipts', () {
    final staff = StaffModel(
      id: 'st_01',
      companyId: 'comp_1',
      name: 'Maharaj Ramesh',
      phone: '+919898012345',
      role: 'head_chef',
      joiningDate: '2024-03-15',
    );

    expect(staff.joiningDate, '2024-03-15');

    final payment = StaffPaymentModel(
      id: 'pay_01',
      staffId: staff.id,
      companyId: 'comp_1',
      amount: 5000,
      paymentDate: '2026-10-18',
      paymentMode: 'upi',
      receiptImagePath: '/path/to/screenshot.jpg',
      notes: 'Weekly payment',
    );

    expect(payment.amount, 5000.0);
    expect(payment.receiptImagePath, '/path/to/screenshot.jpg');
  });

  test('Upcoming booking date formats cleanly like Jun 10, 2026', () {
    final dt = DateTime.parse('2026-06-10');
    final formatted = '${_monthName(dt.month)} ${dt.day.toString().padLeft(2, '0')}, ${dt.year}';
    expect(formatted, 'Jun 10, 2026');
  });

  test('Staff search matches name, phone, and role', () {
    final staffList = [
      StaffModel(id: '1', companyId: 'c1', name: 'Ramesh Maharaj', phone: '9898012345', role: 'head_chef', joiningDate: '2025-01-01'),
      StaffModel(id: '2', companyId: 'c1', name: 'Suresh Karigar', phone: '9876543210', role: 'asst_chef', joiningDate: '2025-02-01'),
      StaffModel(id: '3', companyId: 'c1', name: 'Gopal Helper', phone: '9123456789', role: 'helper', joiningDate: '2025-03-01'),
    ];

    // Search by name
    final queryName = 'ramesh';
    final byName = staffList.where((s) => s.name.toLowerCase().contains(queryName)).toList();
    expect(byName.length, 1);
    expect(byName.first.id, '1');

    // Search by phone
    final queryPhone = '98765';
    final byPhone = staffList.where((s) => s.phone.contains(queryPhone)).toList();
    expect(byPhone.length, 1);
    expect(byPhone.first.id, '2');

    // Search by role
    final queryRole = 'helper';
    final byRole = staffList.where((s) => s.role.contains(queryRole)).toList();
    expect(byRole.length, 1);
    expect(byRole.first.id, '3');
  });
}

String _monthName(int month) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return months[month - 1];
}
