import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animations/animations.dart';
import '../../features/daily_report/presentation/cubit/daily_report_cubit.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/history/presentation/view/report_history_screen.dart';
import '../../features/splash/presentation/view/splash_screen.dart';
import '../../features/daily_report/presentation/widgets/full_screen_image.dart';
import '../../features/main/presentation/view/main_screen.dart';
import '../../features/workout/presentation/cubit/workout_cubit.dart';
import '../../features/workout/presentation/view/workout_screen.dart';
import '../di/injection_container.dart' as di;

class AppRouter {
  static const String splash = '/splash';
  static const String main = '/';
  static const String dailyReport =
      '/report-detail'; // Old dailyReport route renamed
  static const String history = '/history';
  static const String fullScreenImage = '/full-screen-image';
  static const String workout = '/workout-detail';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case main:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => di.sl<DailyReportCubit>()),
                  BlocProvider(create: (context) => di.sl<WorkoutCubit>()),
                ],
                child: const MainScreen(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
      case history:
        // History needs HistoryCubit to list reports and DailyReportCubit to restore them
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              MultiBlocProvider(
                providers: [
                  // Use factory for HistoryCubit (new instance per visit)
                  BlocProvider(create: (context) => di.sl<HistoryCubit>()),
                  // Use .value for DailyReportCubit singleton to prevent closing it when popping this screen
                  BlocProvider.value(value: di.sl<DailyReportCubit>()),
                ],
                child: const ReportHistoryScreen(),
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        );
      case fullScreenImage:
        final args = settings.arguments as Map<String, dynamic>;
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) =>
              FullScreenImage(
                imagePath: args['imagePath'] as String,
                title: args['title'] as String?,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );
      case workout:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => BlocProvider(
            create: (context) => di.sl<WorkoutCubit>(),
            child: const WorkoutScreen(),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              child: child,
            );
          },
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  // Removed wrapWithProviders to move providers into onGenerateRoute as requested
}
