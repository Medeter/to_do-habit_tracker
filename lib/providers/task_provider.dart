import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/settings.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  TaskType? _filterType;
  bool _showCompleted = false;
  TaskSortOrder _sortOrder = TaskSortOrder.createdDate;

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  String get searchQuery => _searchQuery;
  TaskType? get filterType => _filterType;
  bool get showCompleted => _showCompleted;
  TaskSortOrder get sortOrder => _sortOrder;

  // Initialize and load tasks
  Future<void> loadTasks() async {
    try {
      _tasks = HiveService.getAllTasks();
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  // Add task
  Future<void> addTask(Task task) async {
    try {
      // Generate unique notification ID for tasks with due date and time
      if (task.isTask && task.dueDate != null) {
        // Generate a safe 32-bit integer ID based on hash code
        task.notificationId = task.id.hashCode.abs() % 2147483647;
        
        // Schedule notification 1 minute before due date
        await NotificationService().scheduleTaskReminder(
          id: task.notificationId!,
          title: task.title,
          description: task.description,
          scheduledDate: task.dueDate!,
        );
      }
      
      await HiveService.addTask(task);
      _tasks.add(task);
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      final oldTask = _tasks.firstWhere((t) => t.id == task.id);
      
      // Cancel old notifications if exists (both reminder and due time)
      if (oldTask.notificationId != null) {
        await NotificationService().cancelTaskNotifications(oldTask.notificationId!);
      }
      
      // Schedule new notifications if task has due date and time AND is not completed
      if (task.isTask && task.dueDate != null && !task.isCompleted) {
        if (task.notificationId == null) {
          // Generate a safe 32-bit integer ID based on hash code
          task.notificationId = task.id.hashCode.abs() % 2147483647;
        }
        
        await NotificationService().scheduleTaskReminder(
          id: task.notificationId!,
          title: task.title,
          description: task.description,
          scheduledDate: task.dueDate!,
        );
      } else if (oldTask.notificationId != null) {
        // If task is completed or no longer has due date, ensure notifications are cancelled
        task.notificationId = null;
      }
      
      await HiveService.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _applyFiltersAndSort();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      
      // Cancel notifications if exists (both reminder and due time)
      if (task.notificationId != null) {
        await NotificationService().cancelTaskNotifications(task.notificationId!);
      }
      
      await HiveService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _applyFiltersAndSort();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId, {DateTime? date}) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final checkDate = date ?? DateTime.now();
      
      if (task.isHabit) {
        // For habits, toggle completion for specific date
        if (task.isCompletedOnDate(checkDate)) {
          task.markNotCompletedOnDate(checkDate);
        } else {
          task.markCompletedOnDate(checkDate);
        }
      } else {
        // For tasks, toggle overall completion
        task.isCompleted = !task.isCompleted;
        if (task.isCompleted) {
          task.markCompletedOnDate(checkDate);
        }
      }
      
      await updateTask(task);
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  // Search and filter methods
  void searchTasks(String query) {
    _searchQuery = query;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setFilter({TaskType? type, bool? showCompleted}) {
    if (type != null) _filterType = type;
    if (showCompleted != null) _showCompleted = showCompleted;
    _applyFiltersAndSort();
    notifyListeners();
  }

  void clearFilter() {
    _filterType = null;
    _showCompleted = false;
    _searchQuery = '';
    _applyFiltersAndSort();
    notifyListeners();
  }

  void setSortOrder(TaskSortOrder sortOrder) {
    _sortOrder = sortOrder;
    _applyFiltersAndSort();
    notifyListeners();
  }

  // Get tasks for specific date
  List<Task> getTasksForDate(DateTime date) {
    return HiveService.getTasksForDate(date);
  }

  // Private methods
  void _applyFiltersAndSort() {
    var filteredTasks = _tasks.where((task) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!task.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !task.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Type filter
      if (_filterType != null && task.type != _filterType) {
        return false;
      }

      // Completion filter
      if (!_showCompleted && task.isCompleted) {
        return false;
      }

      return true;
    }).toList();

    // Sort tasks
    filteredTasks.sort((a, b) {
      switch (_sortOrder) {
        case TaskSortOrder.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case TaskSortOrder.priority:
          return b.priority.index.compareTo(a.priority.index);
        case TaskSortOrder.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSortOrder.completed:
          return a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1);
        case TaskSortOrder.createdDate:
        default:
          return b.createdAt.compareTo(a.createdAt);
      }
    });

    _filteredTasks = filteredTasks;
  }

  // Statistics methods
  Map<String, dynamic> getStatisticsForPeriod(DateTime start, DateTime end) {
    return HiveService.getStatisticsForPeriod(start, end);
  }

  Map<DateTime, int> getCompletionCalendar() {
    return HiveService.getCompletionCalendar();
  }
}

class SettingsProvider extends ChangeNotifier {
  AppSettings _settings = AppSettings();

  AppSettings get settings => _settings;
  bool get isDarkMode => _settings.isDarkMode;
  bool get notificationsEnabled => _settings.notificationsEnabled;
  bool get showCompletedTasks => _settings.showCompletedTasks;
  TaskSortOrder get taskSortOrder => _settings.taskSortOrder;

  // Initialize settings
  Future<void> loadSettings() async {
    try {
      _settings = HiveService.getSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Update settings
  Future<void> updateSettings(AppSettings settings) async {
    try {
      await HiveService.updateSettings(settings);
      _settings = settings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  // Convenience methods for individual settings
  Future<void> toggleDarkMode() async {
    final newSettings = AppSettings(
      isDarkMode: !_settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      dailyReminderHour: _settings.dailyReminderHour,
      dailyReminderMinute: _settings.dailyReminderMinute,
      language: _settings.language,
      showCompletedTasks: _settings.showCompletedTasks,
      taskSortOrder: _settings.taskSortOrder,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleNotifications() async {
    final newSettings = AppSettings(
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: !_settings.notificationsEnabled,
      dailyReminderHour: _settings.dailyReminderHour,
      dailyReminderMinute: _settings.dailyReminderMinute,
      language: _settings.language,
      showCompletedTasks: _settings.showCompletedTasks,
      taskSortOrder: _settings.taskSortOrder,
    );
    await updateSettings(newSettings);
  }

  Future<void> setDailyReminderTime(int hour, int minute) async {
    final newSettings = AppSettings(
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      dailyReminderHour: hour,
      dailyReminderMinute: minute,
      language: _settings.language,
      showCompletedTasks: _settings.showCompletedTasks,
      taskSortOrder: _settings.taskSortOrder,
    );
    await updateSettings(newSettings);
  }

  Future<void> toggleShowCompletedTasks() async {
    final newSettings = AppSettings(
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      dailyReminderHour: _settings.dailyReminderHour,
      dailyReminderMinute: _settings.dailyReminderMinute,
      language: _settings.language,
      showCompletedTasks: !_settings.showCompletedTasks,
      taskSortOrder: _settings.taskSortOrder,
    );
    await updateSettings(newSettings);
  }

  Future<void> setTaskSortOrder(TaskSortOrder sortOrder) async {
    final newSettings = AppSettings(
      isDarkMode: _settings.isDarkMode,
      notificationsEnabled: _settings.notificationsEnabled,
      dailyReminderHour: _settings.dailyReminderHour,
      dailyReminderMinute: _settings.dailyReminderMinute,
      language: _settings.language,
      showCompletedTasks: _settings.showCompletedTasks,
      taskSortOrder: sortOrder,
    );
    await updateSettings(newSettings);
  }
}