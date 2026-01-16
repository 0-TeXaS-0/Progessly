import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/preferences/preferences_manager.dart';
import 'services/notification_service.dart';
import 'providers/task_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/water_provider.dart';
import 'providers/habit_provider.dart';
import 'providers/profile_provider.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefsManager = PreferencesManager();
  await prefsManager.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(ProgresslyApp(prefsManager: prefsManager));
}

class ProgresslyApp extends StatelessWidget {
  final PreferencesManager prefsManager;

  const ProgresslyApp({super.key, required this.prefsManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PreferencesManager>.value(value: prefsManager),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => WaterProvider(prefsManager)),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider(prefsManager)),
      ],
      child: MaterialApp(
        title: 'Progressly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: prefsManager.isOnboardingComplete()
            ? const HomeScreen()
            : const OnboardingScreen(),
      ),
    );
  }
}
