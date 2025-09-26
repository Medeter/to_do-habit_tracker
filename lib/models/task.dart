import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String description;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late DateTime createdAt;

  @HiveField(5)
  late DateTime? dueDate;

  @HiveField(6)
  late TaskType type;

  @HiveField(7)
  late TaskPriority priority;

  @HiveField(8)
  late List<DateTime> completionDates; // For tracking habit completion history

  @HiveField(9)
  late Map<String, dynamic> metadata; // For any additional data

  @HiveField(10)
  late int? notificationId; // For tracking notification

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.type = TaskType.task,
    this.priority = TaskPriority.medium,
    List<DateTime>? completionDates,
    Map<String, dynamic>? metadata,
    this.notificationId,
  }) {
    this.completionDates = completionDates ?? [];
    this.metadata = metadata ?? {};
  }

  // Helper methods
  bool get isHabit => type == TaskType.habit;
  bool get isTask => type == TaskType.task;
  
  bool isCompletedOnDate(DateTime date) {
    return completionDates.any((completionDate) =>
        completionDate.year == date.year &&
        completionDate.month == date.month &&
        completionDate.day == date.day);
  }

  void markCompletedOnDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!isCompletedOnDate(normalizedDate)) {
      completionDates.add(normalizedDate);
    }
  }

  void markNotCompletedOnDate(DateTime date) {
    completionDates.removeWhere((completionDate) =>
        completionDate.year == date.year &&
        completionDate.month == date.month &&
        completionDate.day == date.day);
  }

  int getCurrentStreak() {
    if (completionDates.isEmpty) return 0;

    completionDates.toSet().toList().sort(); // Sort completion dates
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    int streak = 0;
    DateTime checkDate = today;
    
    // Check if today is completed or if yesterday was completed (allowing for today not being completed yet)
    if (isCompletedOnDate(today)) {
      streak = 1;
      checkDate = today.subtract(const Duration(days: 1));
    } else if (isCompletedOnDate(today.subtract(const Duration(days: 1)))) {
      streak = 1;
      checkDate = today.subtract(const Duration(days: 2));
    } else {
      return 0;
    }
    
    // Count consecutive days backwards
    while (isCompletedOnDate(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'type': type.toString(),
      'priority': priority.toString(),
      'completionDates': completionDates.map((date) => date.toIso8601String()).toList(),
      'metadata': metadata,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      type: TaskType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => TaskType.task,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString() == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      completionDates: (json['completionDates'] as List<dynamic>?)
              ?.map((date) => DateTime.parse(date))
              .toList() ??
          [],
      metadata: json['metadata'] ?? {},
    );
  }
}

@HiveType(typeId: 1)
enum TaskType {
  @HiveField(0)
  task,
  @HiveField(1)
  habit,
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}