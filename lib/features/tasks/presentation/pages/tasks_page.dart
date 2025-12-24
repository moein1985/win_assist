import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_event.dart';
import 'package:win_assist/features/tasks/presentation/bloc/tasks_state.dart';
import 'package:win_assist/features/tasks/domain/entities/scheduled_task.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _searchQuery = _searchController.text.trim().toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search tasks by name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, ScheduledTask task, bool actionInProgress) {
    Color statusColor;
    switch (task.state) {
      case TaskState.running:
        statusColor = Colors.green;
        break;
      case TaskState.ready:
        statusColor = Colors.blue;
        break;
      case TaskState.disabled:
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
    }

    final lastRun = task.lastRunTime != null ? task.lastRunTime!.toLocal().toString().substring(0, 10) : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: statusColor, radius: 6),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Last Run: $lastRun | ${task.resultLabel}'),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Run',
                  icon: const Icon(Icons.play_arrow),
                  onPressed: (task.state != TaskState.running && !actionInProgress)
                      ? () => context.read<TasksBloc>().add(RunTaskEvent(task.name))
                      : null,
                ),
                IconButton(
                  tooltip: 'Stop',
                  icon: const Icon(Icons.stop),
                  onPressed: (task.state == TaskState.running && !actionInProgress)
                      ? () => context.read<TasksBloc>().add(StopTaskEvent(task.name))
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
            final allTasks = state.tasks;
            var tasks = allTasks.where((t) => t.name.toLowerCase().contains(_searchQuery)).toList();
            if (tasks.isEmpty) return Column(
              children: [
                _buildSearchBar(),
                const Expanded(child: Center(child: Text('No scheduled tasks found.'))),
              ],
            );

            final actionInProgress = state is TasksActionInProgress;

            return RefreshIndicator(
              onRefresh: () async => context.read<TasksBloc>().add(GetTasksEvent()),
              child: Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemBuilder: (context, index) => _buildTaskCard(context, tasks[index], actionInProgress),
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemCount: tasks.length,
                    ),
                  ),
                ],
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
