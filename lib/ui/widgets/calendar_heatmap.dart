import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivityData {
  final DateTime date;
  final int intensity; // 0-100 percentage of daily goal completion

  ActivityData({required this.date, required this.intensity});
}

class CalendarHeatmap extends StatelessWidget {
  final List<ActivityData> data;
  final int numberOfWeeks;
  final Function(DateTime)? onDayTapped;

  const CalendarHeatmap({
    super.key,
    required this.data,
    this.numberOfWeeks = 12,
    this.onDayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Activity Calendar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Last $numberOfWeeks weeks',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeatmap(context),
            const SizedBox(height: 12),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmap(BuildContext context) {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: numberOfWeeks * 7));

    // Group data by date
    final dataMap = <String, int>{};
    for (var activity in data) {
      final key = DateFormat('yyyy-MM-dd').format(activity.date);
      dataMap[key] = activity.intensity;
    }

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(numberOfWeeks, (weekIndex) {
          return _buildWeekColumn(context, startDate, weekIndex, dataMap);
        }),
      ),
    );
  }

  Widget _buildWeekColumn(
    BuildContext context,
    DateTime startDate,
    int weekIndex,
    Map<String, int> dataMap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (dayIndex) {
          final date = startDate.add(Duration(days: weekIndex * 7 + dayIndex));
          final key = DateFormat('yyyy-MM-dd').format(date);
          final intensity = dataMap[key] ?? 0;

          return _buildDayCell(context, date, intensity);
        }),
      ),
    );
  }

  Widget _buildDayCell(BuildContext context, DateTime date, int intensity) {
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    final isFuture = date.isAfter(today);

    Color cellColor;
    if (isFuture) {
      cellColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    } else {
      cellColor = _getColorForIntensity(context, intensity);
    }

    return GestureDetector(
      onTap: isFuture ? null : () => onDayTapped?.call(date),
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: cellColor,
          borderRadius: BorderRadius.circular(2),
          border: isToday
              ? Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.5,
                )
              : null,
        ),
      ),
    );
  }

  Color _getColorForIntensity(BuildContext context, int intensity) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (intensity == 0) {
      return Theme.of(context).colorScheme.surfaceContainerHighest;
    } else if (intensity < 25) {
      return primaryColor.withValues(alpha: 0.3);
    } else if (intensity < 50) {
      return primaryColor.withValues(alpha: 0.5);
    } else if (intensity < 75) {
      return primaryColor.withValues(alpha: 0.7);
    } else {
      return primaryColor;
    }
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Less', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(width: 4),
        ...[0, 25, 50, 75, 100].map((intensity) {
          return Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: _getColorForIntensity(context, intensity),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
        const SizedBox(width: 4),
        Text('More', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
