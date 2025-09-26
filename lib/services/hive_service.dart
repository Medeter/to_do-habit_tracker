import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../models/settings.dart';

class HiveService {
  static const String _tasksBoxName = 'tasks';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'app_settings';

  static Box<Task>? _tasksBox;
  static Box<AppSettings>? _settingsBox;

  // Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskTypeAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(TaskSortOrderAdapter());
    
    // Open boxes
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _settingsBox = await Hive.openBox<AppSettings>(_settingsBoxName);
    
    // Initialize default settings if they don't exist
    if (!_settingsBox!.containsKey(_settingsKey)) {
      await _settingsBox!.put(_settingsKey, AppSettings());
    }
  }

  // Tasks operations
  static Box<Task> get tasksBox {
    if (_tasksBox == null || !_tasksBox!.isOpen) {
      throw Exception('Tasks box is not initialized');
    }
    return _tasksBox!;
  }

  static Future<void> addTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  static Future<void> updateTask(Task task) async {
    await tasksBox.put(task.id, task);
  }

  static Future<void> deleteTask(String taskId) async {
    await tasksBox.delete(taskId);
  }

  static List<Task> getAllTasks() {
    return tasksBox.values.toList();
  }

  static List<Task> getTasksForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return getAllTasks().where((task) {
      // For habits, check if they were completed on this date
      if (task.isHabit) {
        return true; // Show all habits for any date
      }
      // For tasks, check if they are due on this date
      if (task.dueDate != null) {
        final taskDate = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        return taskDate.isAtSameMomentAs(normalizedDate) ||
               taskDate.isBefore(normalizedDate);
      }
      return false;
    }).toList();
  }

  static List<Task> getTasks({
    bool? isCompleted,
    TaskType? type,
    TaskPriority? priority,
  }) {
    var tasks = getAllTasks();
    
    if (isCompleted != null) {
      tasks = tasks.where((task) => task.isCompleted == isCompleted).toList();
    }
    
    if (type != null) {
      tasks = tasks.where((task) => task.type == type).toList();
    }
    
    if (priority != null) {
      tasks = tasks.where((task) => task.priority == priority).toList();
    }
    
    return tasks;
  }

  static List<Task> searchTasks(String query) {
    if (query.isEmpty) return getAllTasks();
    
    return getAllTasks().where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
             task.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Settings operations
  static Box<AppSettings> get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not initialized');
    }
    return _settingsBox!;
  }

  static AppSettings getSettings() {
    return settingsBox.get(_settingsKey, defaultValue: AppSettings())!;
  }

  static Future<void> updateSettings(AppSettings settings) async {
    await settingsBox.put(_settingsKey, settings);
  }

  // Statistics helpers
  static Map<DateTime, int> getCompletionCalendar() {
    final calendar = <DateTime, int>{};
    final tasks = getAllTasks();
    
    for (final task in tasks) {
      for (final date in task.completionDates) {
        final normalizedDate = DateTime(date.year, date.month, date.day);
        calendar[normalizedDate] = (calendar[normalizedDate] ?? 0) + 1;
      }
    }
    
    return calendar;
  }

  static Map<String, dynamic> getStatisticsForPeriod(DateTime start, DateTime end) {
    final tasks = getAllTasks();
    int totalTasks = 0;
    int completedTasks = 0;
    int totalHabits = 0;
    int totalHabitCompletions = 0;
    
    for (final task in tasks) {
      if (task.isHabit) {
        totalHabits++;
        // Count completions in the period
        final completionsInPeriod = task.completionDates.where((date) =>
          date.isAfter(start.subtract(const Duration(days: 1))) &&
          date.isBefore(end.add(const Duration(days: 1)))
        ).length;
        totalHabitCompletions += completionsInPeriod;
      } else {
        totalTasks++;
        if (task.isCompleted) completedTasks++;
      }
    }
    
    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'totalHabits': totalHabits,
      'totalHabitCompletions': totalHabitCompletions,
      'taskCompletionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
      'habitCompletionRate': totalHabits > 0 ? (totalHabitCompletions / (totalHabits * _getDaysInPeriod(start, end)) * 100).round() : 0,
    };
  }

  static int _getDaysInPeriod(DateTime start, DateTime end) {
    return end.difference(start).inDays + 1;
  }

  // Backup and restore
  static Map<String, dynamic> exportData() {
    final tasks = getAllTasks().map((task) => task.toJson()).toList();
    final settings = getSettings().toJson();
    
    return {
      'tasks': tasks,
      'settings': settings,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await tasksBox.clear();
    
    // Import tasks
    final tasksData = data['tasks'] as List<dynamic>?;
    if (tasksData != null) {
      for (final taskData in tasksData) {
        final task = Task.fromJson(taskData);
        await addTask(task);
      }
    }
    
    // Import settings
    final settingsData = data['settings'] as Map<String, dynamic>?;
    if (settingsData != null) {
      final settings = AppSettings.fromJson(settingsData);
      await updateSettings(settings);
    }
  }

  static Future<void> clearAllData() async {
    await tasksBox.clear();
    await settingsBox.clear();
    // Reset settings to default
    await updateSettings(AppSettings());
  }

  // Clean up
  static Future<void> close() async {
    await _tasksBox?.close();
    await _settingsBox?.close();
  }
}