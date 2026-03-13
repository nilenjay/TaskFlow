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
import 'features/settings/cubit/theme_cubit.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'features/todo/presentation/screens/calendar_screen.dart';
import 'features/todo/presentation/screens/settings_screen.dart';
import 'features/todo/presentation/screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());    // typeId: 0
  Hive.registerAdapter(FocusTypeAdapter());   // typeId: 1
  Hive.registerAdapter(SessionLogAdapter());  // typeId: 2
  Hive.registerAdapter(AppSettingsAdapter()); // typeId: 3
  await Hive.openBox<TodoModel>('todosBox');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TodoBloc(TodoLocalDataSource())),
        BlocProvider(create: (_) => FocusBloc(FocusLocalDataSource())),
        BlocProvider(
            create: (_) =>
                SettingsCubit(SettingsLocalDataSource())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        // Update system nav bar to always match our dark bg
        SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF0D1020),
          systemNavigationBarIconBrightness: Brightness.light,
        ));

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo App',
          themeMode: settingsState.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF818CF8),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF818CF8),
              secondary: Color(0xFF4F46E5),
            ),
          ),
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
      },
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
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final focusState = context.watch<FocusBloc>().state;
    final isFocusRunning =
        _currentIndex == 2 && focusState is FocusRunning;

    // Nav bar colours — transparent over focus gradient, dark everywhere else
    const darkNavBg        = Color(0xFF0D1020);
    const darkIndicator    = Color(0xFF2A2D4A);
    const darkIconUnsel    = Color(0xFF64748B);
    const darkIconSel      = Color(0xFF818CF8);

    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      extendBody: isFocusRunning,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: isFocusRunning
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
            : NavigationBarThemeData(
          backgroundColor: darkNavBg,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: darkIndicator,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return IconThemeData(
                color: sel ? darkIconSel : darkIconUnsel,
                size: 24);
          }),
          labelTextStyle:
          WidgetStateProperty.resolveWith((states) {
            final sel = states.contains(WidgetState.selected);
            return TextStyle(
              color: sel ? darkIconSel : darkIconUnsel,
              fontWeight:
              sel ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) =>
              setState(() => _currentIndex = i),
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
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}