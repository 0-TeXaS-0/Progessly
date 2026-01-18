import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../widgets/gesture_widgets.dart';
import '../../services/sound_service.dart';

class EnhancedTasksScreen extends StatefulWidget {
  const EnhancedTasksScreen({super.key});

  @override
  State<EnhancedTasksScreen> createState() => _EnhancedTasksScreenState();
}

class _EnhancedTasksScreenState extends State<EnhancedTasksScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _soundService = SoundService();
  int _selectedPriority = 0;

  @override
  void initState() {
    super.initState();
    _soundService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(provider),
              _buildAddTask(provider),
              Expanded(child: _buildTaskList(provider)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(TaskProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            'Completed',
            provider.completedCount.toString(),
            Colors.green,
          ),
          _buildStatCard(
            'Pending',
            '${provider.totalCount - provider.completedCount}',
            Colors.orange,
          ),
          _buildStatCard(
            'Streak',
            '${provider.streak.dailyStreak} days',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTask(TaskProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Quick add task...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _quickAddTask(provider),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () => _quickAddTask(provider),
            iconSize: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  void _quickAddTask(TaskProvider provider) async {
    if (_titleController.text.trim().isNotEmpty) {
      await provider.addTask(_titleController.text.trim());
      _titleController.clear();
      _soundService.playTaskComplete();
    }
  }

  Widget _buildTaskList(TaskProvider provider) {
    if (provider.tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_outlined,
              size: 80,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            const Text('No tasks yet. Add one above!'),
          ],
        ),
      );
    }

    // Sort tasks by priority (high to low) and completion status
    final sortedTasks = List<TaskModel>.from(provider.tasks)
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1; // Completed tasks go to bottom
        }
        return b.priority.compareTo(a.priority); // High priority first
      });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        return DraggableListItem(
          index: index,
          dragKey: 'task_${task.id}',
          onReorder: (oldIndex, newIndex) =>
              _reorderTasks(provider, oldIndex, newIndex, sortedTasks),
          child: _buildTaskItem(task, provider),
        );
      },
    );
  }

  void _reorderTasks(
    TaskProvider provider,
    int oldIndex,
    int newIndex,
    List<TaskModel> sortedTasks,
  ) {
    // Update priorities based on new order
    final task = sortedTasks[oldIndex];
    final newPriority = sortedTasks.length - newIndex;
    provider.updateTask(task.copyWith(priority: newPriority));
  }

  Widget _buildTaskItem(TaskModel task, TaskProvider provider) {
    final priorityColor = _getPriorityColor(task.priority);
    final priorityIcon = _getPriorityIcon(task.priority);

    return SwipeToDismiss(
      itemName: task.title,
      onDismissed: () async {
        await provider.deleteTask(task.id!);
        _soundService.playTaskDelete();
      },
      child: LongPressMenu(
        menuItems: [
          PopupMenuItem(
            value: 'edit',
            child: const Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'high',
            child: Row(
              children: [
                Icon(Icons.priority_high, size: 20, color: Colors.red),
                const SizedBox(width: 8),
                const Text('High Priority'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'medium',
            child: Row(
              children: [
                Icon(Icons.drag_handle, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                const Text('Medium Priority'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'low',
            child: Row(
              children: [
                Icon(Icons.low_priority, size: 20, color: Colors.green),
                const SizedBox(width: 8),
                const Text('Low Priority'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            child: const Row(
              children: [
                Icon(Icons.delete, size: 20, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
        ],
        onSelected: (value) => _handleMenuAction(value, task, provider),
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: task.priority == 2 ? 4 : 2,
          child: InkWell(
            onTap: () async {
              await provider.toggleTask(task);
              if (task.isCompleted) {
                _soundService.playTaskComplete();
              } else {
                _soundService.playButtonTap();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: priorityColor, width: 4),
                ),
              ),
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(priorityIcon, color: priorityColor, size: 20),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (_) async {
                        await provider.toggleTask(task);
                        _soundService.playTaskComplete();
                      },
                    ),
                  ],
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                    fontWeight: task.priority == 2
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: task.description.isNotEmpty
                    ? Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: Icon(
                  Icons.drag_indicator,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(int priority) {
    switch (priority) {
      case 2:
        return Icons.priority_high;
      case 1:
        return Icons.drag_handle;
      default:
        return Icons.low_priority;
    }
  }

  void _handleMenuAction(
    String action,
    TaskModel task,
    TaskProvider provider,
  ) async {
    _soundService.playButtonTap();

    switch (action) {
      case 'edit':
        _showEditTaskDialog(task, provider);
        break;
      case 'high':
        provider.updateTask(task.copyWith(priority: 2));
        break;
      case 'medium':
        provider.updateTask(task.copyWith(priority: 1));
        break;
      case 'low':
        provider.updateTask(task.copyWith(priority: 0));
        break;
      case 'delete':
        await provider.deleteTask(task.id!);
        _soundService.playTaskDelete();
        break;
    }
  }

  void _showAddTaskDialog() {
    _titleController.clear();
    _descriptionController.clear();
    _selectedPriority = 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Low'),
                    icon: Icon(Icons.low_priority),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Med'),
                    icon: Icon(Icons.drag_handle),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('High'),
                    icon: Icon(Icons.priority_high),
                  ),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (Set<int> selected) {
                  setState(() => _selectedPriority = selected.first);
                  _soundService.playButtonTap();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _soundService.playButtonTap();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                final task = TaskModel(
                  title: _titleController.text.trim(),
                  description: _descriptionController.text.trim(),
                  priority: _selectedPriority,
                );
                context.read<TaskProvider>().addTaskModel(task);
                _soundService.playTaskComplete();
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(TaskModel task, TaskProvider provider) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;
    _selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Low'),
                    icon: Icon(Icons.low_priority),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('Med'),
                    icon: Icon(Icons.drag_handle),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('High'),
                    icon: Icon(Icons.priority_high),
                  ),
                ],
                selected: {_selectedPriority},
                onSelectionChanged: (Set<int> selected) {
                  setState(() => _selectedPriority = selected.first);
                  _soundService.playButtonTap();
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _soundService.playButtonTap();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (_titleController.text.trim().isNotEmpty) {
                provider.updateTask(
                  task.copyWith(
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    priority: _selectedPriority,
                  ),
                );
                _soundService.playButtonTap();
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tasks are automatically sorted by:'),
            const SizedBox(height: 8),
            const Text('1. Pending tasks first'),
            const Text('2. Priority (High → Low)'),
            const SizedBox(height: 16),
            const Text(
              'Tip: Long press a task to change priority or drag to reorder!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _soundService.playButtonTap();
              Navigator.pop(context);
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}
