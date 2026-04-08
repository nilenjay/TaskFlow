
part of 'focus_model.dart';


class SessionLogAdapter extends TypeAdapter<SessionLog> {
  @override
  final int typeId = 2;

  @override
  SessionLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionLog(
      id: fields[0] as String,
      sessionName: fields[1] as String,
      focusType: fields[2] as FocusType,
      plannedMinutes: fields[3] as int,
      actualFocusMinutes: fields[4] as int,
      breaksCompleted: fields[5] as int,
      rating: fields[6] as int,
      date: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SessionLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.sessionName)
      ..writeByte(2)
      ..write(obj.focusType)
      ..writeByte(3)
      ..write(obj.plannedMinutes)
      ..writeByte(4)
      ..write(obj.actualFocusMinutes)
      ..writeByte(5)
      ..write(obj.breaksCompleted)
      ..writeByte(6)
      ..write(obj.rating)
      ..writeByte(7)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FocusTypeAdapter extends TypeAdapter<FocusType> {
  @override
  final int typeId = 1;

  @override
  FocusType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FocusType.study;
      case 1:
        return FocusType.deepWork;
      case 2:
        return FocusType.creative;
      default:
        return FocusType.study;
    }
  }

  @override
  void write(BinaryWriter writer, FocusType obj) {
    switch (obj) {
      case FocusType.study:
        writer.writeByte(0);
        break;
      case FocusType.deepWork:
        writer.writeByte(1);
        break;
      case FocusType.creative:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
