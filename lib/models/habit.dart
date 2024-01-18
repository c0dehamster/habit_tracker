import 'package:isar/isar.dart';

// run cmd to generate file: dart tun build_runner
part 'habit.g.dart';

@Collection()
class Habit {
  // Habit id
  Id id = Isar.autoIncrement;

  // Habit name, will be init later on
  late String name;

  // Completed days
  List<DateTime> completedDays = [
    // Will look like DateTime(year, month, day)
  ];
}
