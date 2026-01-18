import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/unit_preferences_provider.dart';
import '../../data/models/unit_preference.dart';
import '../../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _soundService = SoundService();
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _soundEnabled = _soundService.soundEnabled;
      _hapticsEnabled = _soundService.hapticsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unitProvider = context.watch<UnitPreferencesProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: [
          _buildSectionHeader('Units', theme),
          _buildWaterUnitTile(unitProvider, theme),
          _buildWeightUnitTile(unitProvider, theme),
          const Divider(height: 32),
          _buildSectionHeader('Sound & Haptics', theme),
          _buildSoundToggle(theme),
          _buildHapticsToggle(theme),
          const Divider(height: 32),
          _buildSectionHeader('About', theme),
          _buildAboutTile(theme),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWaterUnitTile(
    UnitPreferencesProvider provider,
    ThemeData theme,
  ) {
    return ListTile(
      leading: const Icon(Icons.water_drop),
      title: const Text('Water Unit'),
      subtitle: Text(provider.waterUnit.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showWaterUnitDialog(provider),
    );
  }

  Widget _buildWeightUnitTile(
    UnitPreferencesProvider provider,
    ThemeData theme,
  ) {
    return ListTile(
      leading: const Icon(Icons.fitness_center),
      title: const Text('Weight Unit'),
      subtitle: Text(provider.weightUnit.displayName),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showWeightUnitDialog(provider),
    );
  }

  Widget _buildSoundToggle(ThemeData theme) {
    return SwitchListTile(
      secondary: const Icon(Icons.volume_up),
      title: const Text('Sound Effects'),
      subtitle: const Text('Play sounds for actions'),
      value: _soundEnabled,
      onChanged: (value) async {
        await _soundService.setSoundEnabled(value);
        setState(() => _soundEnabled = value);
        if (value) await _soundService.playButtonTap();
      },
    );
  }

  Widget _buildHapticsToggle(ThemeData theme) {
    return SwitchListTile(
      secondary: const Icon(Icons.vibration),
      title: const Text('Haptic Feedback'),
      subtitle: const Text('Vibrate on actions'),
      value: _hapticsEnabled,
      onChanged: (value) async {
        await _soundService.setHapticsEnabled(value);
        setState(() => _hapticsEnabled = value);
        if (value) await _soundService.playButtonTap();
      },
    );
  }

  Widget _buildAboutTile(ThemeData theme) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('About Progressly'),
      subtitle: const Text('Version 1.0.0'),
      onTap: () => _showAboutDialog(),
    );
  }

  void _showWaterUnitDialog(UnitPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Water Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WaterUnit.values.map((unit) {
            final isSelected = unit == provider.waterUnit;
            return ListTile(
              title: Text(unit.displayName),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              selected: isSelected,
              onTap: () {
                provider.setWaterUnit(unit);
                _soundService.playButtonTap();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showWeightUnitDialog(UnitPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Weight Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: WeightUnit.values.map((unit) {
            final isSelected = unit == provider.weightUnit;
            return ListTile(
              title: Text(unit.displayName),
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              selected: isSelected,
              onTap: () {
                provider.setWeightUnit(unit);
                _soundService.playButtonTap();
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Progressly',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.track_changes, size: 48),
      children: [
        const Text(
          'Track your daily habits, tasks, meals, and water intake. '
          'Build streaks, earn achievements, and make progress every day!',
        ),
      ],
    );
  }
}
