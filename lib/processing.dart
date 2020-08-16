import 'dart:math';

import 'main.dart';
import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'models/word.dart';


void addWord(Word word) {
 // print('Name: ${contact.name}, Age: ${contact.age}');
  final wordBox=Hive.box('words');
  wordBox.put(word.id, word);

  todaywords.add(word.id);
  dailyBox.put(nowDate.toIso8601String(), todaywords);


}
void deleteWord(dynamic key)
{
  wordBox.deleteAt(key);
}

int calcPriority(Word word)
{
  int dif=(word.latestSolveDate.difference(nowDate).inDays).abs();
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
{
  List<int> forgetCurve=[0,1,5,23];
  for(int i=0; i<todaywords.length; i++)
    { var word=wordBox.get(todaywords[i]);
      int curveCount = word.curveCount++;
      int nextDuration= curveCount<4 ? forgetCurve[curveCount] : 23*pow(5, curveCount-2);
      DateTime date = nowDate.add(new Duration(days: nextDuration));
      var dailywords= dailyBox.get(date);
      if(dailywords!=null)
        {dailywords.push(todaywords[i]);
         dailyBox.put(date, dailywords);
        }
      else {
         List<int>dailywords=[todaywords[i]];
         dailyBox.put(date.toIso8601String(), dailywords);
      }

    }

}