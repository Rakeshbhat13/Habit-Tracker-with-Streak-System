import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/badges_screen.dart';
import 'services/db_init_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Hive for Flutter
    print('DEBUG: Starting App - Initializing Hive...');
    await DbInitService.init();
    print('DEBUG: App initialization complete.');

    if (!kIsWeb) {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ));
      try {
        await NotificationService.instance.init();
      } catch (e) {
        print('DEBUG: Notification service init failed: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? true;
    runApp(HabitTrackerApp(isDark: isDark));
  } catch (e, stack) {
    print('CRITICAL ERROR during startup: $e');
    print(stack);
  }
}

class HabitTrackerApp extends StatefulWidget {
  final bool isDark;
  const HabitTrackerApp({super.key, required this.isDark});

  static _HabitTrackerAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HabitTrackerAppState>();

  @override
  State<HabitTrackerApp> createState() => _HabitTrackerAppState();
}

class _HabitTrackerAppState extends State<HabitTrackerApp> {
  late bool isDark;
  @override
  void initState() { super.initState(); isDark = widget.isDark; }

  Future<void> toggleTheme() async {
    setState(() => isDark = !isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;
  final _pages = const [
    HomeScreen(),
    HistoryScreen(),
    StatsScreen(),
    BadgesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _idx,
          onDestinationSelected: (i) => setState(() => _idx = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_rounded),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events_rounded),
              label: 'Badges',
            ),
          ],
        ),
      ),
    );
  }
}
