import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/unit_preference.dart';

class UnitPreferencesProvider extends ChangeNotifier {
  UnitPreferences _preferences = const UnitPreferences();

  UnitPreferences get preferences => _preferences;
  WaterUnit get waterUnit => _preferences.waterUnit;
  WeightUnit get weightUnit => _preferences.weightUnit;

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('unit_preferences');
    if (json != null) {
      _preferences = UnitPreferences.fromJson(jsonDecode(json));
      notifyListeners();
    }
  }

  Future<void> setWaterUnit(WaterUnit unit) async {
    _preferences = _preferences.copyWith(waterUnit: unit);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    _preferences = _preferences.copyWith(weightUnit: unit);
    await _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'unit_preferences',
      jsonEncode(_preferences.toJson()),
    );
  }

  // Helper methods for conversions
  String formatWater(double ml) {
    final value = waterUnit.fromMl(ml);
    return '${value.toStringAsFixed(0)} ${waterUnit.shortName}';
  }

  double parseWater(double value) {
    return waterUnit.toMl(value);
  }

  String formatWeight(double kg) {
    final value = weightUnit.fromKg(kg);
    return '${value.toStringAsFixed(1)} ${weightUnit.shortName}';
  }

  double parseWeight(double value) {
    return weightUnit.toKg(value);
  }
}
