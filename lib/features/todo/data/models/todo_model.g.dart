// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TodoModelAdapter extends TypeAdapter<TodoModel> {
  @override
  final int typeId = 0;

  @override
  TodoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TodoModel(
      id: fields[0] as String,
      description: fields[1] as String,
      isComplete: fields[2] as bool,
      addedDate: fields[3] as DateTime,
      dueDate: fields[4] as DateTime?,
      reminderTime: fields[5] as DateTime?,
      startReminder: fields[6] as DateTime?,
        priority: (fields[7] as int?) ?? 2    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.isComplete)
      ..writeByte(3)
      ..write(obj.addedDate)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.reminderTime)
      ..writeByte(6)
      ..write(obj.startReminder)
      ..writeByte(7)
      ..write(obj.priority);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
