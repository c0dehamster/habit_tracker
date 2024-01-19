import 'package:flutter/material.dart';
import 'package:habit_tracker/components/main_drawer.dart';
import 'package:habit_tracker/models/database/habit_database.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text controller
  final TextEditingController textController = TextEditingController();

  // Create a new habit
  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(hintText: "Create a new habit"),
        ),
        actions: [
          // Save button
          TextButton(
            onPressed: () {
              // Get the new habit name
              String newHabitName = textController.text;

              // Save to the database
              context.read<HabitDatabase>().addHabit(newHabitName);

              // Pop the dialog box
              Navigator.pop(context);

              // Clear the controller
              textController.clear();
            },
            child: const Text("Save"),
          ),

          // Cancel button
          TextButton(
            onPressed: () {
              // Pop the dialog box
              Navigator.pop(context);

              // Clear the controller
              textController.clear();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(),
      drawer: const MainDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHabit,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.edit,
        ),
      ),
    );
  }
}
