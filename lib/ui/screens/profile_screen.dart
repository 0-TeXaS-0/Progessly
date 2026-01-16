import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/streak_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = provider.profile;
          if (profile == null) {
            return const Center(child: Text('No profile data'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(profile),
                  const SizedBox(height: 16),
                  _buildDailySummary(provider),
                  const SizedBox(height: 16),
                  _buildStreaks(provider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Name', profile.name),
            _buildInfoRow('Age', '${profile.age} years'),
            _buildInfoRow('Gender', profile.gender),
            _buildInfoRow('Weight', '${profile.weight} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildDailySummary(ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildSummaryRow(
              Icons.task_alt,
              'Tasks Completed',
              provider.tasksCompleted.toString(),
            ),
            _buildSummaryRow(
              Icons.restaurant,
              'Meals Logged',
              provider.mealsLogged.toString(),
            ),
            _buildSummaryRow(
              Icons.water_drop,
              'Water Intake',
              '${provider.waterIntake} ml',
            ),
            _buildSummaryRow(
              Icons.emoji_events,
              'Habits Completed',
              provider.habitsCompleted.toString(),
            ),
            _buildSummaryRow(
              Icons.local_fire_department,
              'Total Calories',
              '${provider.totalCalories} kcal',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStreaks(ProfileProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Streaks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildStreakRow('Tasks', provider.taskStreak),
            _buildStreakRow('Meals', provider.mealStreak),
            _buildStreakRow('Water', provider.waterStreak),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakRow(String label, StreakData streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              _buildStreakBadge('Current', streak.dailyStreak),
              const SizedBox(width: 8),
              _buildStreakBadge('Longest', streak.longestStreak),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$label: $value', style: const TextStyle(fontSize: 12)),
    );
  }
}
