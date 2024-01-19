import 'package:flutter/material.dart';
import 'package:habit_tracker/models/database/habit_database.dart';
import 'package:habit_tracker/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

void main() async {
  // Note: check what this does
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  await HabitDatabase.initialize();
  await HabitDatabase().saveFirstLaunchDate();

  runApp(
    MultiProvider(
      providers: [
        // Habit provider
        ChangeNotifierProvider(create: (context) => HabitDatabase()),

        //Theme provider
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
