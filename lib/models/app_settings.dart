import 'package:isar/isar.dart';

// run cmd to generate file: dart tun build_runner
part 'app_settings.g.dart';

@Collection()
class AppSettings {
  Id id = Isar.autoIncrement;
  DateTime? firstLaunchDate;
}
