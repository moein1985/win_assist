import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:win_assist/features/services/data/datasources/windows_service_data_source.dart';
import 'package:win_assist/features/services/presentation/bloc/dashboard_bloc.dart';
import 'package:win_assist/features/services/presentation/bloc/services_bloc.dart';
import 'package:win_assist/features/services/presentation/pages/dashboard_page.dart';
import 'package:win_assist/features/services/presentation/pages/services_page.dart';
import 'package:win_assist/screens/tools_screen.dart';
import 'package:win_assist/injection_container.dart' as di;

class HomeScreen extends StatefulWidget {
  final WindowsServiceDataSource dataSource;

  const HomeScreen({super.key, required this.dataSource});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BlocProvider<DashboardBloc>(
        create: (context) => di.sl<DashboardBloc>()..add(GetDashboardInfoEvent()),
        child: const DashboardPage(),
      ),
      BlocProvider<ServicesBloc>(
        create: (context) => di.sl<ServicesBloc>()..add(GetServicesEvent()),
        child: const ServicesPage(),
      ),
      // Tools tab (contains Local Users Manager)
      const ToolsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    widget.dataSource.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Win Assist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle_outlined),
            label: 'Tools',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
