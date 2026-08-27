import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'workouts/workouts_screen.dart';
import 'macros/macros_screen.dart';
import 'runs/runs_screen.dart';
import 'progress/progress_screen.dart';
import 'account/account_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  const HomeNavigationScreen({super.key});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    WorkoutsScreen(),
    MacrosScreen(),
    RunsScreen(),
    ProgressScreen(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.navBar,
          border: Border(
            top: BorderSide(color: AppColors.divider, width: 1),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.navBar,
            indicatorColor: AppColors.accentGreen.withOpacity(0.18),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: AppColors.accentGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                );
              }
              return const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.accentGreen, size: 24);
              }
              return const IconThemeData(color: AppColors.textMuted, size: 22);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.fitness_center_rounded),
                selectedIcon: Icon(Icons.fitness_center_rounded),
                label: 'TRAIN',
              ),
              NavigationDestination(
                icon: Icon(Icons.pie_chart_outline_rounded),
                selectedIcon: Icon(Icons.pie_chart_rounded),
                label: 'MACROS',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_run_rounded),
                selectedIcon: Icon(Icons.directions_run_rounded),
                label: 'RUNS',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_rounded),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'PROGRESS',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'ACCOUNT',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
