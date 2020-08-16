// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordAdapter extends TypeAdapter<Word> {
  @override
  Word read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Word(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as int,
      fields[4] as int,
      fields[5] as DateTime,
      fields[6] as int,
      fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.eng)
      ..writeByte(1)
      ..write(obj.jpn)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.count)
      ..writeByte(4)
      ..write(obj.curveCount)
      ..writeByte(5)
      ..write(obj.latestSolveDate)
      ..writeByte(6)
      ..write(obj.score)
      ..writeByte(7)
      ..write(obj.priority);
  }
}
