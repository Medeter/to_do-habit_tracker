import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class AddEditTaskDialog extends StatefulWidget {
  final Task? task;
  final Function(Task) onSave;

  const AddEditTaskDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<AddEditTaskDialog> createState() => _AddEditTaskDialogState();
}

class _AddEditTaskDialogState extends State<AddEditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late TaskType _taskType;
  late TaskPriority _priority;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  
  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _taskType = widget.task!.type;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      // Extract time from existing due date if available
      if (_dueDate != null) {
        _dueTime = TimeOfDay.fromDateTime(_dueDate!);
      }
    } else {
      _taskType = TaskType.task;
      _priority = TaskPriority.medium;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'แก้ไข${_taskType == TaskType.task ? 'งาน' : 'นิสัย'}' : 'เพิ่ม${_taskType == TaskType.task ? 'งาน' : 'นิสัย'}'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // กำหนดความสูงสูงสุด
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // Task Type Selection
              SegmentedButton<TaskType>(
                segments: const [
                  ButtonSegment(
                    value: TaskType.task,
                    label: Text('งาน'),
                    icon: Icon(Icons.task),
                  ),
                  ButtonSegment(
                    value: TaskType.habit,
                    label: Text('นิสัย'),
                    icon: Icon(Icons.repeat),
                  ),
                ],
                selected: {_taskType},
                onSelectionChanged: (Set<TaskType> newSelection) {
                  setState(() {
                    _taskType = newSelection.first;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'กรุณาป้อนชื่อ';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'รายละเอียด (ไม่จำเป็น)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                minLines: 1,
              ),
              
              const SizedBox(height: 16),
              
              // Priority
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ความสำคัญ: '),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TaskPriority>(
                    value: _priority,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: TaskPriority.values.map((priority) {
                      return DropdownMenuItem(
                        value: priority,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getPriorityIcon(priority),
                              color: _getPriorityColor(priority),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _getPriorityText(priority),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (TaskPriority? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _priority = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Due Date and Time (only for tasks)
              if (_taskType == TaskType.task) ...[
                // Information about why habits don't have due dates
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'งาน: มีกำหนดเสร็จ | นิสัย: ทำทุกวันไม่มีกำหนดเสร็จ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Due Date
                Row(
                  children: [
                    const Text('วันกำหนด: '),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: _selectDueDate,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Theme.of(context).colorScheme.outline,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _dueDate != null
                                      ? '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year + 543}'
                                      : 'เลือกวันที่',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: _dueDate != null
                                      ? null
                                      : TextStyle(
                                          color: Theme.of(context).colorScheme.outline,
                                        ),
                                ),
                              ),
                              if (_dueDate != null)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _dueDate = null;
                                      _dueTime = null;
                                    });
                                  },
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Due Time (only if date is selected)
                if (_dueDate != null) ...[
                  Row(
                    children: [
                      const Text('เวลากำหนด: '),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: _selectDueTime,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: Theme.of(context).colorScheme.outline,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _dueTime != null
                                        ? _dueTime!.format(context)
                                        : 'เลือกเวลา (ไม่จำเป็น)',
                                    style: _dueTime != null
                                        ? null
                                        : TextStyle(
                                            color: Theme.of(context).colorScheme.outline,
                                          ),
                                  ),
                                ),
                                if (_dueTime != null)
                                  IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _dueTime = null;
                                      });
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
              ] else ...[
                // Information for habits
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'เกี่ยวกับนิสัย',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• นิสัยไม่มีกำหนดเสร็จ เพราะต้องทำซ้ำทุกวัน\n• ระบบจะติดตามการทำแต่ละวัน\n• เป้าหมายคือสร้างเป็นกิจวัตรประจำวัน',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(_isEditing ? 'อัปเดต' : 'สร้าง'),
        ),
      ],
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _dueDate = picked;
        // If no time is set, default to current time
        if (_dueTime == null) {
          _dueTime = TimeOfDay.now();
        }
      });
    }
  }

  Future<void> _selectDueTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time for tasks
      DateTime? finalDueDate;
      if (_taskType == TaskType.task && _dueDate != null) {
        if (_dueTime != null) {
          finalDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            _dueTime!.hour,
            _dueTime!.minute,
          );
        } else {
          // Default to end of day if no time specified
          finalDueDate = DateTime(
            _dueDate!.year,
            _dueDate!.month,
            _dueDate!.day,
            23,
            59,
          );
        }
      }

      final task = _isEditing
          ? Task(
              id: widget.task!.id,
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              createdAt: widget.task!.createdAt,
              dueDate: finalDueDate,
              type: _taskType,
              priority: _priority,
              isCompleted: widget.task!.isCompleted,
              completionDates: widget.task!.completionDates,
              metadata: widget.task!.metadata,
            )
          : Task(
              id: const Uuid().v4(),
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              createdAt: DateTime.now(),
              dueDate: finalDueDate,
              type: _taskType,
              priority: _priority,
            );
      
      widget.onSave(task);
      Navigator.of(context).pop();
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'สูง';
      case TaskPriority.medium:
        return 'ปานกลาง';
      case TaskPriority.low:
        return 'ต่ำ';
    }
  }
}