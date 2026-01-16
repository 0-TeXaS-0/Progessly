import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  String _selectedMealType = 'Breakfast';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadMeals();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meals')),
      body: Consumer<MealProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(provider),
              _buildAddMeal(provider),
              Expanded(child: _buildMealList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(MealProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Meals', provider.mealCount.toString()),
          _buildStatCard('Calories', provider.totalCalories.toString()),
          _buildStatCard('Streak', '${provider.streak.dailyStreak} days'),
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

  Widget _buildAddMeal(MealProvider provider) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Log Meal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Meal name'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Calories',
                      suffixText: 'kcal',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedMealType,
                    decoration: const InputDecoration(hintText: 'Type'),
                    items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMealType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Meal'),
                onPressed: () => _addMeal(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMeal(MealProvider provider) {
    if (_nameController.text.trim().isNotEmpty) {
      final calories = int.tryParse(_caloriesController.text) ?? 0;
      provider.addMeal(
        _nameController.text.trim(),
        calories,
        _selectedMealType,
      );
      _nameController.clear();
      _caloriesController.clear();
    }
  }

  Widget _buildMealList(MealProvider provider) {
    if (provider.meals.isEmpty) {
      return const Center(child: Text('No meals logged today'));
    }

    return ListView.builder(
      itemCount: provider.meals.length,
      itemBuilder: (context, index) {
        final meal = provider.meals[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text(meal.mealType[0])),
            title: Text(meal.name),
            subtitle: Text('${meal.calories} kcal • ${meal.mealType}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => provider.deleteMeal(meal.id!),
            ),
          ),
        );
      },
    );
  }
}
