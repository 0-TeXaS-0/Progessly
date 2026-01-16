import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/water_provider.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WaterProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Tracker')),
      body: Consumer<WaterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProgress(provider),
                _buildQuickAdd(provider),
                _buildCustomAdd(provider),
                _buildLogs(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgress(WaterProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '${provider.totalIntake} / ${provider.dailyGoal} ml',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: provider.progress,
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Text('${provider.remaining} ml remaining'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Streak', '${provider.streak.dailyStreak} days'),
              _buildStatCard('Weekly', '${provider.streak.weeklyStreak} days'),
              _buildStatCard(
                'Longest',
                '${provider.streak.longestStreak} days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildQuickAdd(WaterProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Add',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickButton(provider, 250),
              _buildQuickButton(provider, 500),
              _buildQuickButton(provider, 750),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickButton(WaterProvider provider, int amount) {
    return ElevatedButton(
      onPressed: () => provider.addWater(amount),
      child: Text('$amount ml'),
    );
  }

  Widget _buildCustomAdd(WaterProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Amount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter amount in ml...',
                    suffixText: 'ml',
                  ),
                  onSubmitted: (_) => _addCustomAmount(provider),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle),
                onPressed: () => _addCustomAmount(provider),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addCustomAmount(WaterProvider provider) {
    final amount = int.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      provider.addWater(amount);
      _amountController.clear();
    }
  }

  Widget _buildLogs(WaterProvider provider) {
    if (provider.logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No water logged today')),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.logs.length,
      itemBuilder: (context, index) {
        final log = provider.logs[index];
        return ListTile(
          leading: const Icon(Icons.water_drop),
          title: Text('${log.amount} ml'),
          subtitle: Text(log.time),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => provider.deleteWaterLog(log.id!),
          ),
        );
      },
    );
  }
}
