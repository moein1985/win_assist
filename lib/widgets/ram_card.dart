import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:win_assist/models/dashboard_info.dart';

class RamCard extends StatelessWidget {
  final DashboardInfo info;

  const RamCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usedRam = info.totalRamInGB - info.freeRamInGB;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 45.0,
              lineWidth: 10.0,
              percent: info.ramUsagePercentage,
              center: Text(
                '${(info.ramUsagePercentage * 100).toStringAsFixed(1)}%',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              progressColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RAM Usage',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${usedRam.toStringAsFixed(2)} GB / ${info.totalRamInGB.toStringAsFixed(2)} GB',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}