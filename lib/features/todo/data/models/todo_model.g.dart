
part of 'todo_model.dart';


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
      status: fields[7] as TodoStatus,
      category: fields[8] as TodoCategory,
      priority: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TodoModel obj) {
    writer
      ..writeByte(10)
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
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.category)
      ..writeByte(9)
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

class TodoCategoryAdapter extends TypeAdapter<TodoCategory> {
  @override
  final int typeId = 4;

  @override
  TodoCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoCategory.work;
      case 1:
        return TodoCategory.personal;
      case 2:
        return TodoCategory.professional;
      case 3:
        return TodoCategory.family;
      case 4:
        return TodoCategory.fitness;
      case 5:
        return TodoCategory.other;
      default:
        return TodoCategory.work;
    }
  }

  @override
  void write(BinaryWriter writer, TodoCategory obj) {
    switch (obj) {
      case TodoCategory.work:
        writer.writeByte(0);
        break;
      case TodoCategory.personal:
        writer.writeByte(1);
        break;
      case TodoCategory.professional:
        writer.writeByte(2);
        break;
      case TodoCategory.family:
        writer.writeByte(3);
        break;
      case TodoCategory.fitness:
        writer.writeByte(4);
        break;
      case TodoCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TodoStatusAdapter extends TypeAdapter<TodoStatus> {
  @override
  final int typeId = 5;

  @override
  TodoStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TodoStatus.toDo;
      case 1:
        return TodoStatus.inProgress;
      case 2:
        return TodoStatus.inReview;
      case 3:
        return TodoStatus.done;
      case 4:
        return TodoStatus.blocked;
      case 5:
        return TodoStatus.onHold;
      case 6:
        return TodoStatus.rework;
      default:
        return TodoStatus.toDo;
    }
  }

  @override
  void write(BinaryWriter writer, TodoStatus obj) {
    switch (obj) {
      case TodoStatus.toDo:
        writer.writeByte(0);
        break;
      case TodoStatus.inProgress:
        writer.writeByte(1);
        break;
      case TodoStatus.inReview:
        writer.writeByte(2);
        break;
      case TodoStatus.done:
        writer.writeByte(3);
        break;
      case TodoStatus.blocked:
        writer.writeByte(4);
        break;
      case TodoStatus.onHold:
        writer.writeByte(5);
        break;
      case TodoStatus.rework:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
