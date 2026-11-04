/// Handles unit conversion and scaling math for Indian catering measurements
class UnitConverter {
  static const Map<String, String> compatibleUnitGroups = {
    'kg': 'weight',
    'g': 'weight',
    'gm': 'weight',
    'gram': 'weight',
    'l': 'volume',
    'ltr': 'volume',
    'liter': 'volume',
    'ml': 'volume',
    'pcs': 'count',
    'piece': 'count',
    'packet': 'count',
    'pkt': 'count',
    'dozen': 'count',
    'tin': 'count',
  };

  /// Normalizes unit string to standard abbreviation (kg, g, l, ml, pcs, pkt, dozen)
  static String normalizeUnit(String unit) {
    final lower = unit.trim().toLowerCase();
    if (lower == 'gm' || lower == 'gram' || lower == 'grams') return 'g';
    if (lower == 'kilogram' || lower == 'kgs') return 'kg';
    if (lower == 'ltr' || lower == 'liter' || lower == 'liters') return 'l';
    if (lower == 'milliliter' || lower == 'mls') return 'ml';
    if (lower == 'piece' || lower == 'pieces' || lower == 'pc') return 'pcs';
    if (lower == 'packet' || lower == 'packets') return 'pkt';
    return lower;
  }

  /// Checks if two units are compatible for direct mathematical summing/conversion
  static bool areUnitsCompatible(String unitA, String unitB) {
    final normA = normalizeUnit(unitA);
    final normB = normalizeUnit(unitB);
    if (normA == normB) return true;

    final groupA = compatibleUnitGroups[normA];
    final groupB = compatibleUnitGroups[normB];
    return groupA != null && groupA == groupB;
  }

  /// Converts a quantity from one compatible unit to another.
  /// If incompatible, returns the original quantity.
  static double convertQuantity(double quantity, String fromUnit, String toUnit) {
    final from = normalizeUnit(fromUnit);
    final to = normalizeUnit(toUnit);

    if (from == to) return quantity;

    // Weight group (kg <-> g)
    if (from == 'g' && to == 'kg') return quantity / 1000.0;
    if (from == 'kg' && to == 'g') return quantity * 1000.0;

    // Volume group (l <-> ml)
    if (from == 'ml' && to == 'l') return quantity / 1000.0;
    if (from == 'l' && to == 'ml') return quantity * 1000.0;

    // Count group (dozen <-> pcs)
    if (from == 'dozen' && to == 'pcs') return quantity * 12.0;
    if (from == 'pcs' && to == 'dozen') return quantity / 12.0;

    return quantity;
  }

  /// Format quantity with best human-readable unit (e.g. 1500 g -> 1.5 kg)
  static String formatSmartQuantity(double quantity, String unit) {
    final norm = normalizeUnit(unit);
    if (norm == 'g' && quantity >= 1000) {
      final inKg = quantity / 1000;
      return '${inKg.toStringAsFixed(inKg % 1 == 0 ? 0 : 2)} kg';
    }
    if (norm == 'ml' && quantity >= 1000) {
      final inL = quantity / 1000;
      return '${inL.toStringAsFixed(inL % 1 == 0 ? 0 : 2)} L';
    }
    return '${quantity.toStringAsFixed(quantity % 1 == 0 ? 0 : 2)} $unit';
  }
}
