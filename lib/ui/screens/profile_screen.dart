import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../providers/profile_provider.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/streak_data.dart';
import '../../data/models/quote_model.dart';
import '../../services/insights_service.dart';
import '../../ui/widgets/calendar_heatmap.dart';
import '../../ui/widgets/skeleton_loader.dart';
import 'edit_profile_screen.dart';
import 'personal_records_screen.dart';
import 'settings_screen.dart';

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
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            tooltip: 'Personal Records',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalRecordsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const ProfileSkeletonLoader();
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
                  _buildDailyQuote(),
                  const SizedBox(height: 16),
                  _buildSmartInsights(provider),
                  const SizedBox(height: 16),
                  _buildActivityHeatmap(provider),
                  const SizedBox(height: 16),
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

  Widget _buildDailyQuote() {
    final quote = QuoteService.getDailyQuote();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Daily Inspiration',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"${quote.text}"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '— ${quote.author}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartInsights(ProfileProvider provider) {
    if (provider.insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Smart Insights',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...provider.insights.map((insight) => _buildInsightCard(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(InsightModel insight) {
    Color getInsightColor() {
      switch (insight.type) {
        case InsightType.achievement:
          return Colors.green;
        case InsightType.warning:
          return Colors.orange;
        case InsightType.motivation:
          return Colors.blue;
        case InsightType.productivity:
          return Colors.purple;
        case InsightType.health:
          return Colors.teal;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getInsightColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: getInsightColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: getInsightColor(),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(insight.message, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHeatmap(ProfileProvider provider) {
    if (provider.activityData.isEmpty) {
      return const SizedBox.shrink();
    }

    return CalendarHeatmap(
      data: provider.activityData,
      numberOfWeeks: 12,
      onDayTapped: (date) {
        _showDayDetailsDialog(date, provider);
      },
    );
  }

  void _showDayDetailsDialog(DateTime date, ProfileProvider provider) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final activity = provider.activityData.firstWhere(
      (a) =>
          a.date.day == date.day &&
          a.date.month == date.month &&
          a.date.year == date.year,
      orElse: () => ActivityData(date: date, intensity: 0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(formattedDate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Level: ${activity.intensity}%',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: activity.intensity / 100),
            const SizedBox(height: 16),
            Text(
              activity.intensity >= 75
                  ? '🔥 Excellent day!'
                  : activity.intensity >= 50
                  ? '👍 Good progress'
                  : activity.intensity >= 25
                  ? '💪 Keep going'
                  : '📝 Light activity',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(UserProfile profile) {
    final hasAvatar =
        profile.avatarPath.isNotEmpty && File(profile.avatarPath).existsSync();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  backgroundImage: hasAvatar
                      ? FileImage(File(profile.avatarPath))
                      : null,
                  child: !hasAvatar
                      ? Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (profile.email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Age', '${profile.age} years'),
            _buildInfoRow('Gender', profile.gender),
            _buildInfoRow('Weight', '${profile.weight} kg'),
            if (profile.height > 0)
              _buildInfoRow(
                'Height',
                '${profile.height.toStringAsFixed(0)} cm',
              ),
            if (profile.goal.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Goal', style: const TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                profile.goal,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
