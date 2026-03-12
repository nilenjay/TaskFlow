import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/notifications/notification_service.dart';
import 'features/focus/data/datasourses/focus_local_datasourse.dart';
import 'features/focus/data/models/focus_model.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_state.dart';
import 'features/focus/presentation/screens/focus_screen.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'features/todo/presentation/screens/calendar_screen.dart';
import 'features/todo/presentation/screens/todo_screen.dart';

// Shared dark nav bar colours used on all screens
const _navBgColor        = Color(0xFF0D1020);
const _navIndicatorColor = Color(0xFF2A2D4A);
const _navIconUnsel      = Color(0xFF64748B); // slate-500
const _navIconSel        = Color(0xFF818CF8); // indigo-400
const _navLabelUnsel     = Color(0xFF64748B);
const _navLabelSel       = Color(0xFF818CF8);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  // Make system nav bar match our dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: _navBgColor,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  Hive.registerAdapter(FocusTypeAdapter());
  Hive.registerAdapter(SessionLogAdapter());
  await Hive.openBox<TodoModel>('todosBox');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TodoBloc(TodoLocalDataSource())),
        BlocProvider(create: (_) => FocusBloc(FocusLocalDataSource())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      // Force dark theme always — all screens are now dark
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF818CF8),
        scaffoldBackgroundColor: const Color(0xFF020617),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF818CF8),
          secondary: Color(0xFF4F46E5),
          surface: Color(0xFF0D1020),
        ),
      ),
      home: const AppShell(),
    );
  }
}

// ─── AppShell ─────────────────────────────────────────────────────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TodoScreen(),
    const CalendarScreen(),
    const FocusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final focusState = context.watch<FocusBloc>().state;
    final isFocusRunning = _currentIndex == 2 && focusState is FocusRunning;

    // Only extend body (gradient bleeds behind nav) when focus session is active
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      extendBody: isFocusRunning,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: isFocusRunning
        // ── Focus running: transparent nav over gradient ──────────────
            ? NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.white.withOpacity(0.18),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return IconThemeData(
                color: sel ? Colors.white : Colors.white60,
                size: 24);
          }),
          labelTextStyle:
          WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return TextStyle(
              color: sel ? Colors.white : Colors.white60,
              fontWeight:
              sel ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            );
          }),
        )
        // ── All other screens: dark nav bar ───────────────────────────
            : NavigationBarThemeData(
          backgroundColor: _navBgColor,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: _navIndicatorColor,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return IconThemeData(
                color: sel ? _navIconSel : _navIconUnsel,
                size: 24);
          }),
          labelTextStyle:
          WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return TextStyle(
              color: sel ? _navLabelSel : _navLabelUnsel,
              fontWeight:
              sel ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.check_box_outline_blank),
              selectedIcon: Icon(Icons.check_box),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: 'Focus',
            ),
          ],
        ),
      ),
    );
  }
}