import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/users/presentation/bloc/users_bloc.dart';
import 'package:win_assist/features/users/domain/entities/windows_user.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Expect a UsersBloc to be provided by the caller (ToolsScreen provides it when navigating)
    return const _UsersView();
  }
}

class _UsersView extends StatefulWidget {
  const _UsersView();

  @override
  State<_UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<_UsersView> {
  late UsersBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<UsersBloc>(context);
    _bloc.add(GetUsersEvent());
  }

  Future<void> _showResetDialog(String username) async {
    final TextEditingController passwordController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset password for $username'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newPassword = passwordController.text;
      _bloc.add(ResetUserPasswordEvent(username: username, newPassword: newPassword));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Local Users')),
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state is UsersActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is UsersError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        child: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            if (state is UsersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UsersLoaded) {
              final users = state.users;
              if (users.isEmpty) {
                return const Center(child: Text('No local users found.'));
              }

              return RefreshIndicator(
                onRefresh: () async => _bloc.add(GetUsersEvent()),
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final WindowsUser user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(user.name),
                        subtitle: Text(user.description ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: user.isEnabled,
                              onChanged: (value) {
                                _bloc.add(ToggleUserStatusEvent(username: user.name, enable: value));
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.vpn_key),
                              onPressed: () => _showResetDialog(user.name),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is UsersError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Welcome to Local Users Manager'));
          },
        ),
      ),
    );
  }
}
