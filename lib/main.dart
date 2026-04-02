import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/notifications/notification_service.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/data/service/auth_service.dart';
import 'features/auth/router/auth_router.dart';
import 'features/focus/data/datasourses/focus_local_datasourse.dart';
import 'features/focus/data/models/focus_model.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_state.dart';
import 'features/focus/presentation/screens/focus_screen.dart';
import 'features/settings/cubit/theme_cubit.dart';
import 'features/settings/data/datasources/settings_local_datasource.dart';
import 'features/settings/data/models/settings_model.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_event.dart';
import 'features/todo/presentation/screens/app_theme.dart';
import 'features/todo/presentation/screens/calendar_screen.dart';
import 'features/todo/presentation/screens/settings_screen.dart';
import 'features/todo/presentation/screens/splash_screen.dart';
import 'features/todo/presentation/screens/todo_screen.dart';
import 'firebase_options.dart';

const int _schemaVersion = 3;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.instance.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFF0D1020),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  Hive.registerAdapter(FocusTypeAdapter());
  Hive.registerAdapter(SessionLogAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(TodoCategoryAdapter());
  Hive.registerAdapter(TodoStatusAdapter());

  // Schema migration guard
  final metaBox = await Hive.openBox<int>('_meta');
  final storedVersion = metaBox.get('schemaVersion', defaultValue: 0)!;
  if (storedVersion != _schemaVersion) {
    await Hive.deleteBoxFromDisk('todosBox');
    await metaBox.put('schemaVersion', _schemaVersion);
  }

  await Hive.openBox<TodoModel>('todosBox');

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => AuthBloc(AuthService.instance)
              ..add(const AuthStarted())),
        BlocProvider(create: (_) => TodoBloc(TodoLocalDataSource())),
        BlocProvider(create: (_) => FocusBloc(FocusLocalDataSource())),
        BlocProvider(
            create: (_) => SettingsCubit(SettingsLocalDataSource())),
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
        final isDark = settingsState.settings.isDarkMode;
        
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: isDark ? const Color(0xFF0D1020) : Colors.white,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TaskFlow',
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
          home: const _Root(),
        );
      },
    );
  }
}

// ─── Root — routes between Auth and AppShell ──────────────────────────────────

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // When user logs in, trigger a Firestore sync
        if (state is AuthAuthenticated) {
          context.read<TodoBloc>().add(const SyncFromFirestore());
        }
      },
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const SplashScreen();
        }
        if (state is AuthAuthenticated) {
          return const AppShell();
        }
        return const AuthRouter();
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isDark = settingsState.settings.isDarkMode;
        final focusState = context.watch<FocusBloc>().state;
        final isFocusRunning =
            _currentIndex == 2 && focusState is FocusRunning;

        // Custom colors for BottomNav
        final navBg = isDark ? const Color(0xFF0D1020) : const Color(0xFFFFFFFF);
        final indicator = isDark ? const Color(0xFF2A2D4A) : AppTheme.accent.withOpacity(0.1);
        final iconUnsel = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
        final iconSel = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
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
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                );
              }),
            )
                : NavigationBarThemeData(
              backgroundColor: navBg,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              indicatorColor: indicator,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final sel = states.contains(WidgetState.selected);
                return IconThemeData(
                    color: sel ? iconSel : iconUnsel,
                    size: 24);
              }),
              labelTextStyle:
              WidgetStateProperty.resolveWith((states) {
                final sel = states.contains(WidgetState.selected);
                return TextStyle(
                  color: sel ? iconSel : iconUnsel,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
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
      },
    );
  }
}