import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/users/presentation/pages/users_page.dart';
import 'package:win_assist/injection_container.dart' as di;
import 'package:win_assist/features/users/presentation/bloc/users_bloc.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tools')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Local Users Manager'),
              subtitle: const Text('Manage local users on the server'),
              trailing: const Icon(Icons.people),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => BlocProvider<UsersBloc>(
                  create: (_) => di.sl<UsersBloc>()..add(GetUsersEvent()),
                  child: const UsersPage(),
                )));
              },
            ),
          ),
        ],
      ),
    );
  }
}
