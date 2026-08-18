enum WeightUnit { kg, lb }

class WeightConverter {
  static const double kgToLbFactor = 2.20462262185;

  /// Converts KG to LB with high precision.
  static double kgToLb(double kg) {
    return kg * kgToLbFactor;
  }

  /// Converts LB to KG with high precision.
  static double lbToKg(double lb) {
    return lb / kgToLbFactor;
  }

  /// Converts a weight to the target unit.
  static double convert(double weight, WeightUnit from, WeightUnit to) {
    if (from == to) return weight;
    if (to == WeightUnit.lb) {
      return kgToLb(weight);
    } else {
      return lbToKg(weight);
    }
  }

  /// Formats weight for display (rounded to 1 or 2 decimal places as per UI needs).
  /// Primary storage should always use the raw double in KG.
  static String format(double weight, {int decimals = 1}) {
    return weight.toStringAsFixed(decimals);
  }
}
