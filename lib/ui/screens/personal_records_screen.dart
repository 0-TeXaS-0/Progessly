import 'package:flutter/material.dart';
import '../../data/models/personal_record.dart';
import '../../services/personal_records_service.dart';
import 'package:intl/intl.dart';

class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen> {
  List<PersonalRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await PersonalRecordsService.getRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'task':
        return Icons.check_circle;
      case 'water':
        return Icons.water_drop;
      case 'meal':
        return Icons.restaurant;
      case 'habit':
        return Icons.star;
      case 'streak':
        return Icons.local_fire_department;
      default:
        return Icons.emoji_events;
    }
  }

  Color _getColorForCategory(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'task':
        return colorScheme.primary;
      case 'water':
        return Colors.blue;
      case 'meal':
        return Colors.orange;
      case 'habit':
        return Colors.purple;
      case 'streak':
        return Colors.red;
      default:
        return colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Personal Records'), elevation: 0),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? _buildEmptyState(theme)
          : _buildRecordsList(theme, colorScheme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Records Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Keep tracking your activities to set new personal records!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _records.length,
      itemBuilder: (context, index) {
        final record = _records[index];
        return _buildRecordCard(record, theme, colorScheme);
      },
    );
  }

  Widget _buildRecordCard(
    PersonalRecord record,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final color = _getColorForCategory(record.category, colorScheme);
    final icon = _getIconForCategory(record.category);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${record.value.toInt()} ${record.unit}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(record.achievedDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  if (record.description != null) ...[
                    const SizedBox(height: 8),
                    Text(record.description!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
          ],
        ),
      ),
    );
  }
}
