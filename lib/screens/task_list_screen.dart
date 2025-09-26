import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../widgets/add_edit_task_dialog.dart';
import '../widgets/task_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  TaskType? _filterType;
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
    _searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              // Search and Filter Section
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - _animationController.value)),
                      child: Opacity(
                        opacity: _animationController.value,
                        child: Card(
                          elevation: 6,
                          shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.surface,
                                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Filter chips row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            flex: 4,
                                            child: _buildFilterChip(
                                              'ทั้งหมด',
                                              _filterType == null,
                                              () {
                                                setState(() {
                                                  _filterType = null;
                                                });
                                                taskProvider.setFilter(type: null);
                                              },
                                              Icons.list_rounded,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            flex: 3,
                                            child: _buildFilterChip(
                                              'งาน',
                                              _filterType == TaskType.task,
                                              () {
                                                setState(() {
                                                  _filterType = _filterType == TaskType.task ? null : TaskType.task;
                                                });
                                                taskProvider.setFilter(type: _filterType);
                                              },
                                              Icons.task_alt_rounded,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            flex: 3,
                                            child: _buildFilterChip(
                                              'นิสัย',
                                              _filterType == TaskType.habit,
                                              () {
                                                setState(() {
                                                  _filterType = _filterType == TaskType.habit ? null : TaskType.habit;
                                                });
                                                taskProvider.setFilter(type: _filterType);
                                              },
                                              Icons.repeat_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                // Show completed toggle
                                Container(
                                  decoration: BoxDecoration(
                                    color: taskProvider.showCompleted
                                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                        : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      taskProvider.showCompleted
                                          ? Icons.visibility_rounded
                                          : Icons.visibility_off_rounded,
                                      size: 20,
                                    ),
                                    color: taskProvider.showCompleted
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.onSurfaceVariant,
                                    onPressed: () {
                                      taskProvider.setFilter(
                                        showCompleted: !taskProvider.showCompleted,
                                      );
                                    },
                                    tooltip: taskProvider.showCompleted
                                        ? 'ซ่อนงานที่เสร็จแล้ว'
                                        : 'แสดงงานที่เสร็จแล้ว',
                                  ),
                                ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Task List
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 100 * (1 - _animationController.value)),
                      child: Opacity(
                        opacity: _animationController.value,
                        child: taskProvider.tasks.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: taskProvider.tasks.length,
                                itemBuilder: (context, index) {
                                  final task = taskProvider.tasks[index];
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: TaskTile(
                                      task: task,
                                      onToggleComplete: () => taskProvider.toggleTaskCompletion(task.id),
                                    ),
                                  );
                                },
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, IconData icon) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 10 : 8, 
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isSelected ? 16 : 14,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: isSelected ? 11 : 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_alt_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีงานหรือนิสัย',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                'เริ่มต้นสร้างความมีประสิทธิภาพในชีวิตของคุณ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(Task? task) {
    showDialog(
      context: context,
      builder: (context) => AddEditTaskDialog(
        task: task,
        onSave: (savedTask) {
          if (task == null) {
            Provider.of<TaskProvider>(context, listen: false).addTask(savedTask);
          } else {
            Provider.of<TaskProvider>(context, listen: false).updateTask(savedTask);
          }
        },
      ),
    );
  }

  void _showDeleteDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบ "${task.title}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}