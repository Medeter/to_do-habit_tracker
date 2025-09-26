import 'package:hive/hive.dart';

part 'settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  late bool isDarkMode;

  @HiveField(1)
  late bool notificationsEnabled;

  @HiveField(2)
  late int dailyReminderHour;

  @HiveField(3)
  late int dailyReminderMinute;

  @HiveField(4)
  late String language;

  @HiveField(5)
  late bool showCompletedTasks;

  @HiveField(6)
  late TaskSortOrder taskSortOrder;

  AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.dailyReminderHour = 9,
    this.dailyReminderMinute = 0,
    this.language = 'en',
    this.showCompletedTasks = false,
    this.taskSortOrder = TaskSortOrder.createdDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'notificationsEnabled': notificationsEnabled,
      'dailyReminderHour': dailyReminderHour,
      'dailyReminderMinute': dailyReminderMinute,
      'language': language,
      'showCompletedTasks': showCompletedTasks,
      'taskSortOrder': taskSortOrder.toString(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      isDarkMode: json['isDarkMode'] ?? false,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      dailyReminderHour: json['dailyReminderHour'] ?? 9,
      dailyReminderMinute: json['dailyReminderMinute'] ?? 0,
      language: json['language'] ?? 'en',
      showCompletedTasks: json['showCompletedTasks'] ?? false,
      taskSortOrder: TaskSortOrder.values.firstWhere(
        (e) => e.toString() == json['taskSortOrder'],
        orElse: () => TaskSortOrder.createdDate,
      ),
    );
  }
}

@HiveType(typeId: 4)
enum TaskSortOrder {
  @HiveField(0)
  createdDate,
  @HiveField(1)
  dueDate,
  @HiveField(2)
  priority,
  @HiveField(3)
  alphabetical,
  @HiveField(4)
  completed,
}