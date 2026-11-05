import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker_report/features/daily_report/presentation/cubit/daily_report_cubit.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/view/daily_report_screen.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_cubit.dart';
import 'package:gym_tracker_report/features/workout/presentation/cubit/workout_state.dart';
import 'package:gym_tracker_report/features/workout/presentation/view/workout_screen.dart';
import 'package:gym_tracker_report/features/workout/utils/date_utils.dart';

import '../widgets/floating_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [DailyReportScreen(), WorkoutScreen()];

  final List<bool> _initializedTabs = [true, false];

  static const _exitWindow = Duration(seconds: 2);
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    // Load today's workout day right away (not only when the Workout tab is
    // first opened), so Nutrition shows the same training from the start.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final workout = context.read<WorkoutCubit>();
      if (workout.state.dateKey.isEmpty) workout.loadDate(DateTime.now());
    });
  }

  void _onDestinationSelected(int index) {
    if (index == _selectedIndex) return;

    // Remove focus before changing the active screen.
    FocusManager.instance.primaryFocus?.unfocus();

    if (index == 0) {
      // Show the same day the Workout tab has for today.
      final workout = context.read<WorkoutCubit>().state;
      final report = context.read<DailyReportCubit>();
      if (workout.status == WorkoutStatus.success &&
          workout.dateKey == WorkoutDateUtils.formatDateKey(DateTime.now())) {
        report.syncTrainingFromWorkout(workout.workoutType.displayName);
      } else {
        report.initTodayTrainingDefault();
      }
    }

    setState(() {
      _initializedTabs[index] = true;
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Back never leaves the app by accident: on Workout it goes to Nutrition,
    // on Nutrition it asks for a second press within 2 seconds to exit.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onDestinationSelected(0);
          return;
        }
        final now = DateTime.now();
        final last = _lastBackPress;
        if (last != null && now.difference(last) < _exitWindow) {
          SystemNavigator.pop();
          return;
        }
        _lastBackPress = now;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              duration: _exitWindow,
              content: Text('اضغط رجوع مرة تانية للخروج'),
            ),
          );
      },
      // Nutrition's training type follows the day the Workout tab shows for
      // today, as soon as it loads or you switch it.
      child: BlocListener<WorkoutCubit, WorkoutState>(
        listenWhen: (before, now) =>
            now.status == WorkoutStatus.success &&
            now.dateKey == WorkoutDateUtils.formatDateKey(DateTime.now()) &&
            (before.workoutType != now.workoutType ||
                before.dateKey != now.dateKey ||
                before.status != now.status),
        listener: (context, state) => context
            .read<DailyReportCubit>()
            .syncTrainingFromWorkout(state.workoutType.displayName),
        child: Scaffold(
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
                        descendantsAreFocusable: _selectedIndex == index,
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
        ),
      ),
    );
  }
}
