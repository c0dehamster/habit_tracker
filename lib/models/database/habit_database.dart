import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/models/app_settings.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitDatabase extends ChangeNotifier {
  static late Isar isar;

  /* SETUP */

  /* Initialize the database */
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [HabitSchema, AppSettingsSchema], // Note: read about schemas
      directory: dir.path,
    );
  }

  // Save the first time the app is launched (for the heatmap)
  Future<void> saveFirstLaunchDate() async {
    final existingSettings = await isar.appSettings.where().findFirst();

    // If the app hasn't been launch before, save the current date
    if (existingSettings == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  // Get first startup date (for the heatmap)
  Future<DateTime?> getFirstLaunchDate() async {
    final settings = await isar.appSettings.where().findFirst();
    return settings?.firstLaunchDate;
  }

  /* CRUD OPERATIONS */

  // List of habits
  final List<Habit> currentHabits = [];

  // CREATE - add a new habit
  Future<void> addHabit(String habitName) async {
    // Create a new habit
    final newHabit = Habit()..name = habitName;

    // Save to the database
    await isar.writeTxn(() => isar.habits.put(newHabit));

    // Re-read from the database
    readHabits();
  }

  // READ saved habits from a database
  Future<void> readHabits() async {
    // Fetch all habits from the database
    List<Habit> fetchedHabits = await isar.habits.where().findAll();

    // Give to current habits
    currentHabits.clear();
    currentHabits.addAll(fetchedHabits);

    // Update UI
    notifyListeners();
  }

  // UPDATE - check habit on and off
  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    // Find the specific habit
    final habit = await isar.habits.get(id);

    // Update coompletion status
    if (habit != null) {
      await isar.writeTxn(
        () async {
          // If the habit is completed, add the current date to the completedDays list
          if (isCompleted && !habit.completedDays.contains(DateTime.now())) {
            // Today
            final today = DateTime.now();

            // Add the current date if it is not already in the list
            habit.completedDays.add(
              DateTime(
                today.year,
                today.month,
                today.day,
              ),
            );
          }

          // If the habit is not complete, remove the habit from the list
          else {
            // Remove the current habit if the habit is marked as not completed
            habit.completedDays.removeWhere(
              (date) =>
                  date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day,
            );
          }
          // Save the updated habits to the database
          await isar.habits.put(habit);
        },
      );
    }

    // Re-read from the database
    readHabits();
  }

  // UPDATE - edit habit name
  Future<void> updateHabitName(int id, String newName) async {
    // Find the required habit
    final habit = await isar.habits.get(id);

    // Update the habit name
    if (habit != null) {
      // Update the name
      habit.name = newName;

      // Save the updated habit back to the database
      await isar.habits.put(habit);
    }

    // Re-read from the database
    readHabits();
  }

  // DELETE habit
  Future<void> deleteHabit(int id) async {
    // Delete
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });

    // Re-read from the database
    readHabits();
  }
}
