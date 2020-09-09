import 'dart:math';

import 'main.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'models/word.dart';

DateTime now = new DateTime.now();
DateTime nowDate = new DateTime(now.year, now.month, now.day);


void addWord(Word word) {
  print(nowDate.toIso8601String());
 // print('Name: ${contact.name}, Age: ${contact.age}');

  final wordBox=Hive.box('words');
  wordBox.put(word.id, word);
  todaywords.add(word.id);


  var dailywords= dailyBox.get(nowDate.toIso8601String());
  if(dailywords==null)
  {
    List<int> list=[word.id];
    dailyBox.put(nowDate.toIso8601String(), list);
  }
  else {
    dailywords.add(word.id);
    dailyBox.put(nowDate.toIso8601String(), dailywords);
  }
  dataBox.put("lastID",dataBox.get("lastID",defaultValue: 0)+1 );

}
void deleteWord(dynamic key)
{
  wordBox.deleteAt(key);
}

int calcPriority(Word word)
{DateTime now = new DateTime.now();
DateTime nowDate = new DateTime(now.year, now.month, now.day);

  int dif=word.latestSolveDate==null? 0: (word.latestSolveDate.difference(nowDate).inDays).abs();
  int priority=word.score+(dif)*300;

  return priority;
}

void calcPriorityWithDate()
{
// List<Word> words = wordBox.values.toList();
  if(wordBox.isEmpty)return;
  Word word=wordBox.getAt(0);
  if(word.priority==calcPriority(word))return;
  //もしすでに今日の日付で計算していたら、ここから下の処理は実行しない

  for(int i=0;i<wordBox.length;i++)
 {Word word=wordBox.getAt(i);
  word.priority=calcPriority(word);
  wordBox.putAt(i, word);
 }
  debugPrint("culcPriorityWithDate!4/success");
}

void calcScore(List<int> tenProblems,List<int> answerTimer,List<IconData> answerState)
{
  int countSum=dataBox.get("countSum",defaultValue: 0);
  dataBox.put("countSum", countSum+tenProblems.length);
 /* int minTime=1e9.floor();
  for(int i=0;i<answerTimer.length;i++)minTime=min(minTime,answerTimer[i]);*/
  for(int i=0;i<answerTimer.length;i++)
  { Word word=wordBox.get(tenProblems[i]);
    var score=word.score;

    if(score==0){score=min(10000,answerTimer[i]);}
    else{score=(min(10000,answerTimer[i])*2/3+score/3).floor();}
    //10秒以上は10秒とする処理をした時間を2/3,今までのスコアを1/3で調合
    if(answerState[i]==Icons.close)score*=2;

    word.score=score;
    word.count++;
    word.latestSolveDate=nowDate;
    word.priority=calcPriority(word);

    wordBox.put(tenProblems[i], word);

  }

}

void assignToCurve ()
{print("assignToCurve called${todaywords.length}");
  //todo:wordboxにputしてない問題
  List<int> forgetCurve=[0,1,5,23];
  for(int i=0; i<todaywords.length; i++)
    { var word=wordBox.get(todaywords[i]);
      //IDから単語を取得

      word.curveCount++;

     //print("$i:${todaywords[i]}:${word.eng}");
      wordBox.put(todaywords[i], word);
      //（忘却曲線における）解いた回数を一つ足した上でBoxに保存（上書き）

      int curveCount=word.curveCount;
      int nextDuration= curveCount<4 ? forgetCurve[curveCount] : 23*pow(5, curveCount-2);
      DateTime date = nowDate.add(new Duration(days: nextDuration));
      print("${date.toIso8601String()}+|+$curveCount}");
      var dailywords= dailyBox.get(date.toIso8601String());
      if(dailywords==null)
        {
          List<int> list=[todaywords[i]];
          dailyBox.put(date.toIso8601String(), list);
        }
      else {
        dailywords.add(todaywords[i]);
        dailyBox.put(date.toIso8601String(), dailywords);
      }

    }
todaywords=List<int>();
}