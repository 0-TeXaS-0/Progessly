import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habits')),
      body: Consumer<HabitProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(provider),
              _buildAddHabit(provider),
              Expanded(child: _buildHabitList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(HabitProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total', provider.habits.length.toString()),
          _buildStatCard('Completed', provider.completedCount.toString()),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildAddHabit(HabitProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Add new habit...'),
              onSubmitted: (_) => _addHabit(provider),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _addHabit(provider),
            iconSize: 32,
          ),
        ],
      ),
    );
  }

  void _addHabit(HabitProvider provider) {
    if (_nameController.text.trim().isNotEmpty) {
      provider.addHabit(_nameController.text.trim());
      _nameController.clear();
    }
  }

  Widget _buildHabitList(HabitProvider provider) {
    if (provider.habits.isEmpty) {
      return const Center(child: Text('No habits yet. Add one above!'));
    }

    return ListView.builder(
      itemCount: provider.habits.length,
      itemBuilder: (context, index) {
        final habit = provider.habits[index];
        final isCompleted = provider.isHabitCompleted(habit.id!);
        final streak = provider.getStreakForHabit(habit.id!);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: IconButton(
              icon: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : null,
              ),
              onPressed: isCompleted
                  ? null
                  : () => provider.completeHabit(habit.id!),
            ),
            title: Text(habit.name),
            subtitle: Text(
              '${streak.dailyStreak} day streak • ${habit.frequency}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.deleteHabit(habit.id!),
            ),
          ),
        );
      },
    );
  }
}
