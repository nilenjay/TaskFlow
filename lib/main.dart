import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/notifications/notification_service.dart';
import 'features/todo/data/datasources/todo_local_datasource.dart';
import 'features/todo/data/models/todo_model.dart';
import 'features/todo/presentation/bloc/todo_bloc/todo_bloc.dart';
import 'features/todo/presentation/screens/todo_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();


  await Hive.initFlutter();
  Hive.registerAdapter(TodoModelAdapter());
  await Hive.openBox<TodoModel>('todosBox');

  runApp(
    BlocProvider(
      create: (_) => TodoBloc(TodoLocalDataSource()),
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

      home: const TodoScreen(),
    );
  }
}