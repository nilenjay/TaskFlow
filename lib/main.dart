import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/notifications/notification_service.dart';
import 'features/focus/data/datasourses/focus_local_datasourse.dart';
import 'features/focus/data/models/focus_model.dart';
import 'features/focus/presentation/bloc/focus_bloc/focus_bloc.dart';
import 'features/focus/presentation/screens/focus_screen.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'features/todo/presentation/screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

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
      title: "Todo App",
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const AppShell(),
    );
  }
}

// ─── AppShell — owns the bottom nav and switches between pages ────────────────

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TodoScreen(),
    const FocusScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outline_blank),
            selectedIcon: Icon(Icons.check_box),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Focus',
          ),
        ],
      ),
    );
  }
}