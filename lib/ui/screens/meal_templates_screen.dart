import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../data/models/meal_template_model.dart';

class MealTemplatesScreen extends StatelessWidget {
  const MealTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Templates')),
      body: Consumer<MealProvider>(
        builder: (context, provider, child) {
          if (provider.templates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No templates yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add templates to quickly log your regular meals',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Template'),
                    onPressed: () => _showAddTemplateDialog(context, provider),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildMealTypeSection(context, provider, 'Breakfast', '🍳'),
              _buildMealTypeSection(context, provider, 'Lunch', '🍽️'),
              _buildMealTypeSection(context, provider, 'Dinner', '🍕'),
              _buildMealTypeSection(context, provider, 'Snack', '🍎'),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showAddTemplateDialog(context, context.read<MealProvider>()),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMealTypeSection(
    BuildContext context,
    MealProvider provider,
    String mealType,
    String icon,
  ) {
    final templates = provider.getTemplatesByType(mealType);

    if (templates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () =>
                    _showAddTemplateDialog(context, provider, mealType),
              ),
            ],
          ),
        ),
        ...templates.map(
          (template) => _buildTemplateCard(context, provider, template),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    MealProvider provider,
    MealTemplateModel template,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(template.name),
        subtitle: Text(
          '${template.calories} kcal • Logged ${template.timesLogged}x',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                template.isFavorite ? Icons.star : Icons.star_border,
                color: template.isFavorite ? Colors.amber : null,
              ),
              onPressed: () => provider.toggleTemplateFavorite(template),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditTemplateDialog(context, provider, template);
                } else if (value == 'delete') {
                  _confirmDelete(context, provider, template);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTemplateDialog(
    BuildContext context,
    MealProvider provider, [
    String? initialMealType,
  ]) {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    String selectedMealType = initialMealType ?? 'Breakfast';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Meal Template'),
          content: SingleChildScrollView(
            child: Column(
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMealType,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedMealType = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final calories = int.tryParse(caloriesController.text) ?? 0;
                  provider.addTemplate(
                    nameController.text.trim(),
                    calories,
                    selectedMealType,
                  );
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTemplateDialog(
    BuildContext context,
    MealProvider provider,
    MealTemplateModel template,
  ) {
    final nameController = TextEditingController(text: template.name);
    final caloriesController = TextEditingController(
      text: template.calories.toString(),
    );
    String selectedMealType = template.mealType;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Template'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Meal Name'),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedMealType,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedMealType = value!);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final calories = int.tryParse(caloriesController.text) ?? 0;
                  final updated = template.copyWith(
                    name: nameController.text.trim(),
                    calories: calories,
                    mealType: selectedMealType,
                  );
                  provider.updateTemplate(updated);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    MealProvider provider,
    MealTemplateModel template,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTemplate(template.id!);
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
