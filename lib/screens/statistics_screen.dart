import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  String _selectedPeriod = 'สัปดาห์นี้';
  final List<String> _periods = ['สัปดาห์นี้', 'เดือนนี้', 'ปีนี้'];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final stats = _getStatsForPeriod(taskProvider);
        final habits = taskProvider.allTasks.where((task) => task.type == TaskType.habit).toList();
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Card(
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
                                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.date_range_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'ช่วงเวลา:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedPeriod,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    items: _periods.map((period) {
                                      return DropdownMenuItem(
                                        value: period,
                                        child: Text(
                                          period,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedPeriod = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Overview Cards
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 100 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'งานทั้งหมด',
                              '${stats['totalTasks']}',
                              Icons.task_alt_rounded,
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'งานที่เสร็จ',
                              '${stats['completedTasks']}',
                              Icons.check_circle_rounded,
                              Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 12),
              
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 150 * (1 - _animationController.value)),
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'อัตราเสร็จ',
                              '${stats['completionRate']}%',
                              Icons.trending_up_rounded,
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'สตรีค',
                              '${stats['currentStreak']} วัน',
                              Icons.local_fire_department_rounded,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Completion Chart
              if (stats['completionRate'] > 0)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 200 * (1 - _animationController.value)),
                      child: Opacity(
                        opacity: _animationController.value,
                        child: Card(
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.pie_chart_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'สัดส่วนการทำงาน',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 200,
                                  child: PieChart(
                                    PieChartData(
                                      sections: _getPieChartSections(stats),
                                      centerSpaceRadius: 60,
                                      sectionsSpace: 4,
                                      startDegreeOffset: -90,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              
              const SizedBox(height: 24),
              
              // Habits Section
              if (habits.isNotEmpty)
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 250 * (1 - _animationController.value)),
                      child: Opacity(
                        opacity: _animationController.value,
                        child: Card(
                          elevation: 6,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.repeat_rounded,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'นิสัยและความต่อเนื่อง',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ...habits.map((habit) => _buildHabitCard(habit)).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHabitCard(Task habit) {
    final streak = _calculateStreak(habit);
    final completedThisWeek = _getCompletedThisWeek(habit);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    habit.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak วัน',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completedThisWeek / 7,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedThisWeek/7 วันในสัปดาห์นี้',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, dynamic> stats) {
    final completed = stats['completedTasks'] as int;
    final total = stats['totalTasks'] as int;
    final remaining = total - completed;

    return [
      PieChartSectionData(
        color: Theme.of(context).colorScheme.primary,
        value: completed.toDouble(),
        title: '$completed',
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 50,
      ),
      PieChartSectionData(
        color: Theme.of(context).colorScheme.surfaceVariant,
        value: remaining.toDouble(),
        title: '$remaining',
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        radius: 40,
      ),
    ];
  }

  Map<String, dynamic> _getStatsForPeriod(TaskProvider taskProvider) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'สัปดาห์นี้':
        startDate = now.subtract(Duration(days: now.weekday - 1));
        break;
      case 'เดือนนี้':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'ปีนี้':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }
    
    final allTasks = taskProvider.allTasks.where((task) {
      return task.createdAt.isAfter(startDate.subtract(const Duration(days: 1)));
    }).toList();
    
    final completedTasks = allTasks.where((task) {
      return task.completionDates.any((date) => 
        date.isAfter(startDate.subtract(const Duration(days: 1))) && 
        date.isBefore(now.add(const Duration(days: 1)))
      );
    }).length;
    
    final completionRate = allTasks.isEmpty ? 0 : (completedTasks / allTasks.length * 100).round();
    final currentStreak = _calculateCurrentStreak(taskProvider);
    
    return {
      'totalTasks': allTasks.length,
      'completedTasks': completedTasks,
      'completionRate': completionRate,
      'currentStreak': currentStreak,
    };
  }

  int _calculateStreak(Task habit) {
    if (habit.completionDates.isEmpty) return 0;
    
    final sortedDates = habit.completionDates.toList()
      ..sort((a, b) => b.compareTo(a));
    
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < sortedDates.length; i++) {
      final expectedDate = today.subtract(Duration(days: i));
      final completionDate = DateTime(
        sortedDates[i].year,
        sortedDates[i].month,
        sortedDates[i].day,
      );
      final expectedDateOnly = DateTime(
        expectedDate.year,
        expectedDate.month,
        expectedDate.day,
      );
      
      if (completionDate == expectedDateOnly) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  int _getCompletedThisWeek(Task habit) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return habit.completionDates.where((date) {
      return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             date.isBefore(now.add(const Duration(days: 1)));
    }).length;
  }

  int _calculateCurrentStreak(TaskProvider taskProvider) {
    final habits = taskProvider.allTasks.where((t) => t.type == TaskType.habit).toList();
    if (habits.isEmpty) return 0;
    
    int totalStreak = 0;
    for (final habit in habits) {
      totalStreak += _calculateStreak(habit);
    }
    
    return (totalStreak / habits.length).round();
  }
}