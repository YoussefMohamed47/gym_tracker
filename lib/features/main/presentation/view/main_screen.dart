import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker_report/features/daily_report/presentation/cubit/daily_report_cubit.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/view/daily_report_screen.dart';
import 'package:gym_tracker_report/features/workout/presentation/view/workout_screen.dart';

import '../widgets/floating_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DailyReportScreen(),
    WorkoutScreen(),
  ];

  final List<bool> _initializedTabs = [
    true,
    false,
  ];

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;

    // Remove focus before changing the active screen.
    FocusManager.instance.primaryFocus?.unfocus();

    if (index == 0) {
      context.read<DailyReportCubit>().initTodayTrainingDefault();
    }

    setState(() {
      _initializedTabs[index] = true;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          for (int index = 0; index < _screens.length; index++)
            if (_initializedTabs[index])
              Offstage(
                offstage: _selectedIndex != index,
                child: TickerMode(
                  enabled: _selectedIndex == index,
                  child: FocusScope(
                    canRequestFocus: _selectedIndex == index,
                    descendantsAreFocusable:
                    _selectedIndex == index,
                    child: _screens[index],
                  ),
                ),
              ),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}