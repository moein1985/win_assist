import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_bloc.dart';
import 'package:win_assist/features/logs/presentation/bloc/logs_state.dart';
import 'package:win_assist/features/logs/domain/entities/log_entry.dart';

class LogsPage extends StatelessWidget {
  const LogsPage({super.key});

  Color _colorForType(LogEntryType type) {
    switch (type) {
      case LogEntryType.error:
        return Colors.red;
      case LogEntryType.warning:
        return Colors.orange;
    }
  }

  IconData _iconForType(LogEntryType type) {
    switch (type) {
      case LogEntryType.error:
        return Icons.error_outline;
      case LogEntryType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Event Logs')),
      body: BlocBuilder<LogsBloc, LogsState>(
        builder: (context, state) {
          if (state is LogsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LogsLoaded) {
            final logs = state.logs;
            if (logs.isEmpty) {
              return const Center(child: Text('No logs found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final log = logs[index];
                final color = _colorForType(log.entryType);
                final icon = _iconForType(log.entryType);
                final firstLine = log.message.split('\n').first;
                final titleText = '${log.entryType == LogEntryType.error ? 'Error' : 'Warning'} from ${log.source}';
                final titleLine = '${log.source}  •  #${log.index}';
                final trailingText = log.timeGenerated.toLocal().toString().substring(0, 19);
                return InkWell(
                  onTap: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(titleText),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(log.message),
                            const SizedBox(height: 12),
                            Text('Time: ${log.timeGenerated.toLocal().toString()}'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                      ],
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: color, width: 6)),
                      color: Theme.of(context).cardColor,
                    ),
                    child: ListTile(
                      leading: Icon(icon, color: color),
                      title: Text(titleLine),
                      subtitle: Text(
                        firstLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        trailingText,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is LogsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
