import 'package:hive/hive.dart';
//import '../main.dart';
part 'word.g.dart';
// /Users/mkv/Development/flutter/bin/flutter packages pub run build_runner build
@HiveType()
class Word {
  @HiveField(0)
   String eng;

  @HiveField(1)
   String jpn;

  @HiveField(2)
   int id;

  @HiveField(3)
   int count;

  @HiveField(4)
  int curveCount;

  @HiveField(5)
  DateTime latestSolveDate;

  @HiveField(6)
  int score;

  @HiveField(7)
  int priority;


  Word(this.eng, this.jpn,this.id,this.count,this.curveCount,this.latestSolveDate,this.score,this.priority);
  /* 同じ意味のはずだけど、下記だとfinalに代入すんの？みたいなエラーがでる。てかなんでfinalで定義してるんだろう
  Contact(String name, int age)
  {
    this.name=name;
    this.age=age;
  }*/
}