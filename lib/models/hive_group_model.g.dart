// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_group_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveGroupAdapter extends TypeAdapter<HiveGroup> {
  @override
  final int typeId = 0;

  @override
  HiveGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveGroup(
      id: fields[0] as String,
      name: fields[1] as String,
      subject: fields[2] as String,
      inviteCode: fields[3] as String,
      isSynced: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveGroup obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.inviteCode)
      ..writeByte(4)
      ..write(obj.isSynced);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
