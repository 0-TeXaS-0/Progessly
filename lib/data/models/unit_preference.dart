enum WaterUnit {
  ml,
  oz,
  cups;

  String get displayName {
    switch (this) {
      case WaterUnit.ml:
        return 'Milliliters (ml)';
      case WaterUnit.oz:
        return 'Fluid Ounces (oz)';
      case WaterUnit.cups:
        return 'Cups';
    }
  }

  String get shortName {
    switch (this) {
      case WaterUnit.ml:
        return 'ml';
      case WaterUnit.oz:
        return 'oz';
      case WaterUnit.cups:
        return 'cups';
    }
  }

  // Convert from ml to this unit
  double fromMl(double ml) {
    switch (this) {
      case WaterUnit.ml:
        return ml;
      case WaterUnit.oz:
        return ml / 29.5735; // 1 oz = 29.5735 ml
      case WaterUnit.cups:
        return ml / 240; // 1 cup = 240 ml
    }
  }

  // Convert to ml from this unit
  double toMl(double value) {
    switch (this) {
      case WaterUnit.ml:
        return value;
      case WaterUnit.oz:
        return value * 29.5735;
      case WaterUnit.cups:
        return value * 240;
    }
  }
}

enum WeightUnit {
  kg,
  lbs;

  String get displayName {
    switch (this) {
      case WeightUnit.kg:
        return 'Kilograms (kg)';
      case WeightUnit.lbs:
        return 'Pounds (lbs)';
    }
  }

  String get shortName {
    switch (this) {
      case WeightUnit.kg:
        return 'kg';
      case WeightUnit.lbs:
        return 'lbs';
    }
  }

  // Convert from kg to this unit
  double fromKg(double kg) {
    switch (this) {
      case WeightUnit.kg:
        return kg;
      case WeightUnit.lbs:
        return kg * 2.20462;
    }
  }

  // Convert to kg from this unit
  double toKg(double value) {
    switch (this) {
      case WeightUnit.kg:
        return value;
      case WeightUnit.lbs:
        return value / 2.20462;
    }
  }
}

class UnitPreferences {
  final WaterUnit waterUnit;
  final WeightUnit weightUnit;

  const UnitPreferences({
    this.waterUnit = WaterUnit.ml,
    this.weightUnit = WeightUnit.kg,
  });

  Map<String, dynamic> toJson() => {
    'waterUnit': waterUnit.name,
    'weightUnit': weightUnit.name,
  };

  factory UnitPreferences.fromJson(Map<String, dynamic> json) {
    return UnitPreferences(
      waterUnit: WaterUnit.values.firstWhere(
        (e) => e.name == json['waterUnit'],
        orElse: () => WaterUnit.ml,
      ),
      weightUnit: WeightUnit.values.firstWhere(
        (e) => e.name == json['weightUnit'],
        orElse: () => WeightUnit.kg,
      ),
    );
  }

  UnitPreferences copyWith({WaterUnit? waterUnit, WeightUnit? weightUnit}) {
    return UnitPreferences(
      waterUnit: waterUnit ?? this.waterUnit,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }
}
