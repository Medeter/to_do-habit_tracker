import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with TickerProviderStateMixin {
  late final ValueNotifier<List<Task>> _selectedTasks;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _selectedTasks = ValueNotifier(_getTasksForDay(_selectedDay));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _selectedTasks.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Task> _getTasksForDay(DateTime day) {
    return context.read<TaskProvider>().getTasksForDate(day);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Calendar Card
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 8,
                        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                                Theme.of(context).colorScheme.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: TableCalendar<Task>(
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            eventLoader: (day) => taskProvider.getTasksForDate(day),
                            onDaySelected: (selectedDay, focusedDay) {
                              if (!isSameDay(_selectedDay, selectedDay)) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });
                                _selectedTasks.value = _getTasksForDay(selectedDay);
                              }
                            },
                            onPageChanged: (focusedDay) {
                              _focusedDay = focusedDay;
                            },
                            calendarStyle: CalendarStyle(
                              outsideDaysVisible: false,
                              weekendTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                              holidayTextStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                              selectedDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              todayDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                shape: BoxShape.circle,
                              ),
                              defaultDecoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              weekendDecoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.tertiary,
                                shape: BoxShape.circle,
                              ),
                              markersMaxCount: 3,
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ) ?? const TextStyle(),
                              leftChevronIcon: Icon(
                                Icons.chevron_left_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              rightChevronIcon: Icon(
                                Icons.chevron_right_rounded,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              weekendStyle: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, tasks) {
                                if (tasks.isNotEmpty) {
                                  final taskList = tasks.cast<Task>();
                                  final completedCount = taskList.where((t) => t.completionDates.any((d) => isSameDay(d, date))).length;
                                  
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (completedCount > 0)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.tertiary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      if (completedCount < tasks.length)
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.symmetric(horizontal: 1),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // Selected Day Tasks
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: ValueListenableBuilder<List<Task>>(
                        valueListenable: _selectedTasks,
                        builder: (context, tasks, _) {
                          return Card(
                            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            elevation: 4,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Theme.of(context).colorScheme.primaryContainer,
                                        Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formatDate(_selectedDay),
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${tasks.length} งาน',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Task List - แยกออกเป็น Column ที่สามารถเลื่อนได้
                                tasks.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.task_alt_outlined,
                                              size: 40,
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              'ไม่มีงานในวันนี้',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'วันดีๆ เพื่อการพักผ่อน',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: tasks.map((task) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            child: Card(
                                              elevation: 2,
                                              child: TaskTile(
                                                task: task,
                                                onToggleComplete: () {
                                                  taskProvider.toggleTaskCompletion(
                                                    task.id,
                                                    date: _selectedDay,
                                                  );
                                                  _selectedTasks.value = _getTasksForDay(_selectedDay);
                                                },
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              
              // เพิ่ม Padding ล่างเพื่อให้เลื่อนได้สบาย
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    if (isSameDay(date, DateTime.now())) {
      return 'วันนี้';
    } else if (isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))) {
      return 'เมื่อวาน';
    } else if (isSameDay(date, DateTime.now().add(const Duration(days: 1)))) {
      return 'พรุ่งนี้';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}