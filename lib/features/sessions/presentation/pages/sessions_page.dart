import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/sessions/presentation/bloc/sessions_bloc.dart';
import 'package:win_assist/features/sessions/domain/entities/windows_session.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  late SessionsBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<SessionsBloc>(context);
    _bloc.add(GetSessionsEvent());
  }

  Future<void> _confirmKill(WindowsSession session) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm'),
        content: Text('آیا مطمئن هستید که می‌خواهید کاربر ${session.username} را خارج کنید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Kill')),
        ],
      ),
    );

    if (result == true) {
      _bloc.add(KillSessionEvent(sessionId: session.id, username: session.username));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Remote Sessions')),
      body: BlocListener<SessionsBloc, SessionsState>(
        listener: (context, state) {
          if (state is SessionsActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is SessionsError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: BlocBuilder<SessionsBloc, SessionsState>(
          builder: (context, state) {
            if (state is SessionsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SessionsLoaded) {
              final sessions = state.sessions;
              if (sessions.isEmpty) {
                return const Center(child: Text('No remote sessions found.'));
              }

              return RefreshIndicator(
                onRefresh: () async => _bloc.add(GetSessionsEvent()),
                child: ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final WindowsSession s = sessions[index];
                    final isActive = s.state.toLowerCase().contains('active');
                    final color = isActive ? Colors.green : Colors.grey;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(s.username),
                        subtitle: Text('Id: ${s.id} • ${s.state}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: color, size: 12),
                            IconButton(
                              icon: const Icon(Icons.logout),
                              onPressed: () => _confirmKill(s),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is SessionsError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Welcome to Remote Sessions'));
          },
        ),
      ),
    );
  }
}
