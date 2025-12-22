import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:win_assist/features/services/domain/entities/dashboard_info.dart';

class StorageCard extends StatelessWidget {
  final DashboardInfo info;

  const StorageCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final usedGB = info.totalStorageInGB - info.freeStorageInGB;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Storage (Drive C)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              percent: info.storageUsagePercentage,
              lineHeight: 20,
              center: Text(
                '${(info.storageUsagePercentage * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              progressColor: Colors.blueAccent,
              backgroundColor: Colors.grey.shade300,
              barRadius: const Radius.circular(10),
            ),
            const SizedBox(height: 16),
            Text(
              '${usedGB.toStringAsFixed(2)} GB Used of ${info.totalStorageInGB.toStringAsFixed(2)} GB',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}