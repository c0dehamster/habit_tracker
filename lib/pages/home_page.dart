import 'package:flutter/material.dart';
import 'package:habit_tracker/components/habit_tile.dart';
import 'package:habit_tracker/components/main_drawer.dart';
import 'package:habit_tracker/components/main_heat_map.dart';
import 'package:habit_tracker/models/database/habit_database.dart';
import 'package:provider/provider.dart';

import '../models/habit.dart';
import '../util/habit_util.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // Read existing habits on app startup
    Provider.of<HabitDatabase>(context, listen: false).readHabits();

    super.initState();
  }

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
      body: ListView(
        children: [
          _buildHabitList(),
        ],
      ),
    );
  }

  // Build heatmap

  Widget _buildHeatMap() {
    // Habit database
    final habitDatabase = context.watch<HabitDatabase>();

    // Current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // Return heat map UI
    return FutureBuilder(
      future: habitDatabase.getFirstLaunchDate(),
      builder: (context, snapshot) {
        // Once the data is available, build the heatmap
        if (snapshot.hasData) {
          return MainHeatMap(
            startDate: snapshot.data!,
            datasets: prepHeatMapDataset(currentHabits),
          );
        } else {
          // Handle the case where no data is returned
          return Container();
        }
      },
    );
  }

  // Build habit list

  Widget _buildHabitList() {
    // Hadit database
    final habitDatabase = context.watch<HabitDatabase>();

    // Check the habit on and off
    void toggleCompleted(bool? value, Habit habit) {
      // Update the habit completion status
      if (value != null) {
        context.read<HabitDatabase>().updateHabitCompletion(habit.id, value);
      }
    }

    // Edit habit box
    void editHabitBox(Habit habit) {
      // Set the controller's name to be the habit's current name
      textController.text = habit.name;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: TextField(
            controller: textController,
          ),
          actions: [
            // Save button
            TextButton(
              onPressed: () {
                // Get the new habit name
                String newHabitName = textController.text;

                // Save to the database
                context.read<HabitDatabase>().updateHabitName(habit.id, newHabitName);

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

    // Delete habit box
    void deleteHabitBox(Habit habit) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Are you sure you want to delete?"),
          actions: [
            // Delete button
            TextButton(
              onPressed: () {
                // Save to the database
                context.read<HabitDatabase>().deleteHabit(habit.id);

                // Pop the dialog box
                Navigator.pop(context);
              },
              child: const Text("Delete"),
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

    // Current habits
    List<Habit> currentHabits = habitDatabase.currentHabits;

    // Return list of habits UI
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentHabits.length,
      itemBuilder: (context, index) {
        // Get each habit
        final habit = currentHabits[index];

        // Check if the habit is completed today
        bool isCompletedToday = isHabitCompletedToday(habit.completedDays);

        // Return habit tile UI
        return HabitTile(
          text: habit.name,
          isCompleted: isCompletedToday,
          onChanged: (value) => toggleCompleted(value, habit),
          editHabit: (context) => editHabitBox(habit),
          deleteHabit: (context) => deleteHabitBox(habit),
        );
      },
    );
  }
}
