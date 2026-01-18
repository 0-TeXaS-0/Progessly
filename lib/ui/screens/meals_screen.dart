import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import 'meal_templates_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadMeals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Manage Templates',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MealTemplatesScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Quick Log', icon: Icon(Icons.flash_on)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: Consumer<MealProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildQuickLogTab(provider),
                    _buildHistoryTab(provider),
                  ],
                ),
              ),
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

  Widget _buildQuickLogTab(MealProvider provider) {
    final suggested = provider.getSuggestedMealType();
    final mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Based on time, we suggest: $suggested',
                    style: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...mealTypes.map((type) => _buildMealTypeSection(provider, type)),
      ],
    );
  }

  Widget _buildMealTypeSection(MealProvider provider, String mealType) {
    final templates = provider.getTemplatesByType(mealType);
    final icon = _getMealIcon(mealType);

    if (templates.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Card(
          child: ListTile(
            leading: Text(icon, style: const TextStyle(fontSize: 24)),
            title: Text(mealType),
            subtitle: const Text('No templates yet'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showAddTemplateDialog(provider, mealType);
            },
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Text(icon, style: const TextStyle(fontSize: 24)),
        title: Text(mealType),
        subtitle: Text(
          '${templates.length} template${templates.length > 1 ? 's' : ''}',
        ),
        children: templates.map((template) {
          return ListTile(
            title: Text(template.name),
            subtitle: Text(
              '${template.calories} kcal • Logged ${template.timesLogged}x',
            ),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Log'),
              onPressed: () => provider.logFromTemplate(template),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMealIcon(String mealType) {
    switch (mealType) {
      case 'Breakfast':
        return '🍳';
      case 'Lunch':
        return '🍽️';
      case 'Dinner':
        return '🍕';
      case 'Snack':
        return '🍎';
      default:
        return '🍴';
    }
  }

  void _showAddTemplateDialog(MealProvider provider, String mealType) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $mealType Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                hintText: 'e.g., Oatmeal with Banana',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories',
                suffixText: 'kcal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final calories = int.tryParse(caloriesController.text) ?? 0;
                provider.addTemplate(
                  nameController.text.trim(),
                  calories,
                  mealType,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(MealProvider provider) {
    if (provider.meals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No meals logged today',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.meals.length,
      itemBuilder: (context, index) {
        final meal = provider.meals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(child: Text(_getMealIcon(meal.mealType))),
            title: Text(meal.name),
            subtitle: Text(
              '${meal.calories} kcal • ${meal.mealType} • ${meal.time}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(provider, meal.id!),
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(MealProvider provider, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal'),
        content: const Text('Are you sure you want to delete this meal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteMeal(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
