import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_state.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Scheduler')),
      body: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TasksError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is TasksLoaded) {
            final tasks = state.tasks;
            if (tasks.isEmpty) return const Center(child: Text('No scheduled tasks found.'));
            return RefreshIndicator(
              onRefresh: () async => context.read<TasksBloc>().add(GetTasksEvent()),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final lastResult = task.lastTaskResult;
                  final lastResultText = lastResult == null ? 'N/A' : (lastResult == 0 ? 'Success' : 'Fail ($lastResult)');
                  return Card(
                    child: ListTile(
                      title: Text(task.name),
                      subtitle: Text('State: ${task.state}\nLast Run: ${task.lastRunTime ?? 'N/A'}\nLast Result: $lastResultText'),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Run',
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => context.read<TasksBloc>().add(RunTaskEvent(task.name)),
                          ),
                          IconButton(
                            tooltip: 'Stop',
                            icon: const Icon(Icons.stop),
                            onPressed: () => context.read<TasksBloc>().add(StopTaskEvent(task.name)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemCount: tasks.length,
              ),
            );
          }

          // Initial - load
          context.read<TasksBloc>().add(GetTasksEvent());
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
