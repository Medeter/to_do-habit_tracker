// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 3;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      notificationsEnabled: fields[1] as bool,
      dailyReminderHour: fields[2] as int,
      dailyReminderMinute: fields[3] as int,
      language: fields[4] as String,
      showCompletedTasks: fields[5] as bool,
      taskSortOrder: fields[6] as TaskSortOrder,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.dailyReminderHour)
      ..writeByte(3)
      ..write(obj.dailyReminderMinute)
      ..writeByte(4)
      ..write(obj.language)
      ..writeByte(5)
      ..write(obj.showCompletedTasks)
      ..writeByte(6)
      ..write(obj.taskSortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskSortOrderAdapter extends TypeAdapter<TaskSortOrder> {
  @override
  final int typeId = 4;

  @override
  TaskSortOrder read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskSortOrder.createdDate;
      case 1:
        return TaskSortOrder.dueDate;
      case 2:
        return TaskSortOrder.priority;
      case 3:
        return TaskSortOrder.alphabetical;
      case 4:
        return TaskSortOrder.completed;
      default:
        return TaskSortOrder.createdDate;
    }
  }

  @override
  void write(BinaryWriter writer, TaskSortOrder obj) {
    switch (obj) {
      case TaskSortOrder.createdDate:
        writer.writeByte(0);
        break;
      case TaskSortOrder.dueDate:
        writer.writeByte(1);
        break;
      case TaskSortOrder.priority:
        writer.writeByte(2);
        break;
      case TaskSortOrder.alphabetical:
        writer.writeByte(3);
        break;
      case TaskSortOrder.completed:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskSortOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
