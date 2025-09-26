import 'package:flutter/material.dart';
import '../models/task.dart';
import 'add_edit_task_dialog.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskTile extends StatefulWidget {
  final Task task;
  final VoidCallback onToggleComplete;
  final VoidCallback? onTap;
  final DateTime? dateContext;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggleComplete,
    this.onTap,
    this.dateContext,
  });

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              isCompletedToday
                  ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                  : theme.colorScheme.surface,
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isCompletedToday
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _handleTaskTap(context),
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Title + Priority + Date
                  Row(
                    children: [
                      // Title
                      Expanded(
                        flex: 3,
                        child: Text(
                          widget.task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: isCompletedToday 
                                ? TextDecoration.lineThrough 
                                : null,
                            color: isCompletedToday
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(widget.task.priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getPriorityColor(widget.task.priority).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPriorityIcon(widget.task.priority),
                              size: 12,
                              color: _getPriorityColor(widget.task.priority),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPriorityText(widget.task.priority),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _getPriorityColor(widget.task.priority),
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Date & Time
                      if (widget.task.dueDate != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getDueDateColor(widget.task.dueDate!).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getDueDateColor(widget.task.dueDate!).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${widget.task.dueDate!.day.toString().padLeft(2, '0')}/${widget.task.dueDate!.month.toString().padLeft(2, '0')}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: _getDueDateColor(widget.task.dueDate!),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              // Show time if available
                              if (widget.task.isTask && _hasTime())
                                Text(
                                  _getTimeString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _getDueDateColor(widget.task.dueDate!),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 9,
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            'ไม่กำหนด',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bottom Row: Description + Complete Button + Edit Button
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description Section
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.task.description.isNotEmpty)
                                Text(
                                  widget.task.description,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    decoration: isCompletedToday 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              else
                                Text(
                                  'ไม่มีรายละเอียด',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              
                              // Badges Row
                              const SizedBox(height: 4),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // Task Type Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(widget.task.type).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _getTypeColor(widget.task.type).withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        _getTypeText(widget.task.type),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: _getTypeColor(widget.task.type),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                    
                                    // Overdue Warning
                                    if (widget.task.dueDate != null && _isOverdue()) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.warning_rounded,
                                              size: 10,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'เกิน ${_getDaysOverdue()} วัน',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 9,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // Action Buttons
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                            // Complete Button
                            GestureDetector(
                              onTap: () => _handleToggleComplete(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isCompletedToday 
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceVariant,
                                  border: Border.all(
                                    color: isCompletedToday 
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  boxShadow: isCompletedToday ? [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isCompletedToday
                                      ? Icon(
                                          Icons.check_rounded,
                                          key: const ValueKey('completed'),
                                          size: 20,
                                          color: theme.colorScheme.onPrimary,
                                        )
                                      : Icon(
                                          Icons.radio_button_unchecked,
                                          key: const ValueKey('uncompleted'),
                                          size: 20,
                                          color: theme.colorScheme.outline,
                                        ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Edit Button
                            GestureDetector(
                              onTap: isCompletedToday ? null : () => _showEditDialog(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: !isCompletedToday
                                      ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                      : theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                  border: Border.all(
                                    color: !isCompletedToday
                                        ? theme.colorScheme.primary.withOpacity(0.3)
                                        : theme.colorScheme.outline.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: !isCompletedToday
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withOpacity(0.5),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 8),
                            
                            // Delete Button
                            GestureDetector(
                              onTap: () => _showDeleteConfirmDialog(context),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.errorContainer.withOpacity(0.3),
                                  border: Border.all(
                                    color: theme.colorScheme.error.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_rounded,
                                  size: 18,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(TaskType type) {
    switch (type) {
      case TaskType.task:
        return Colors.blue;
      case TaskType.habit:
        return Colors.green;
    }
  }

  IconData _getTypeIcon(TaskType type) {
    switch (type) {
      case TaskType.task:
        return Icons.task_alt_rounded;
      case TaskType.habit:
        return Icons.repeat_rounded;
    }
  }

  String _getTypeText(TaskType type) {
    switch (type) {
      case TaskType.task:
        return 'งาน';
      case TaskType.habit:
        return 'นิสัย';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down_rounded;
      case TaskPriority.medium:
        return Icons.drag_handle_rounded;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up_rounded;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'ต่ำ';
      case TaskPriority.medium:
        return 'กลาง';
      case TaskPriority.high:
        return 'สูง';
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (due.isBefore(today)) {
      return Colors.red; // Overdue
    } else if (due == today) {
      return Colors.orange; // Due today
    } else {
      return Colors.blue; // Future due date
    }
  }

  bool _isOverdue() {
    if (widget.task.dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      widget.task.dueDate!.year, 
      widget.task.dueDate!.month, 
      widget.task.dueDate!.day
    );
    return due.isBefore(today) && !widget.task.isCompleted;
  }

  int _getDaysOverdue() {
    if (widget.task.dueDate == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      widget.task.dueDate!.year, 
      widget.task.dueDate!.month, 
      widget.task.dueDate!.day
    );
    return today.difference(due).inDays;
  }

  bool _hasTime() {
    if (widget.task.dueDate == null) return false;
    // Check if the time is not midnight (00:00:00)
    return widget.task.dueDate!.hour != 0 || widget.task.dueDate!.minute != 0;
  }

  String _getTimeString() {
    if (widget.task.dueDate == null) return '';
    final hour = widget.task.dueDate!.hour.toString().padLeft(2, '0');
    final minute = widget.task.dueDate!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _handleToggleComplete(BuildContext context) {
    // Show confirmation dialog before marking as complete
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isCompletedToday ? 'ยกเลิกการทำเสร็จ' : 'ทำเสร็จแล้ว',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Text(
            isCompletedToday 
                ? 'คุณต้องการยกเลิกการทำเสร็จของงาน "${widget.task.title}" หรือไม่?'
                : 'คุณต้องการทำเครื่องหมายว่า "${widget.task.title}" เสร็จแล้วหรือไม่?',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onToggleComplete();
              },
              child: Text(isCompletedToday ? 'ยกเลิก' : 'เสร็จแล้ว'),
            ),
          ],
        );
      },
    );
  }

  void _handleTaskTap(BuildContext context) {
    // If task is not completed, allow editing
    if (!isCompletedToday) {
      widget.onTap?.call();
    } else {
      // If completed, just show details or do nothing
      widget.onTap?.call();
    }
  }

  bool get isCompletedToday {
    if (widget.task.isHabit) {
      final checkDate = widget.dateContext ?? DateTime.now();
      return widget.task.isCompletedOnDate(checkDate);
    } else {
      return widget.task.isCompleted;
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddEditTaskDialog(
        task: widget.task,
        onSave: (editedTask) {
          // Update task using provider
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          taskProvider.updateTask(editedTask);
        },
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'ลบ${widget.task.isHabit ? 'นิสัย' : 'งาน'}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'คุณต้องการลบ${widget.task.isHabit ? 'นิสัย' : 'งาน'} "${widget.task.title}" หรือไม่?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'การดำเนินการนี้ไม่สามารถยกเลิกได้',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _handleDeleteTask(context);
              },
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteTask(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    taskProvider.deleteTask(widget.task.id);
    
    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ลบ${widget.task.isHabit ? 'นิสัย' : 'งาน'} "${widget.task.title}" แล้ว'),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'เรียบร้อย',
          onPressed: () {},
          textColor: Theme.of(context).colorScheme.onError,
        ),
      ),
    );
  }
}