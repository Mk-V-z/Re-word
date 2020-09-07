import 'package:flutter/material.dart';
import './main.dart';
import 'dart:math' as math;
//import 'package:hive/hive.dart';
import 'models/word.dart';
import 'processing.dart';
import 'dart:math';
var random = new math.Random();



var questionNumber = 0;
var questionCounter = 0;
var answerState = [Icons.panorama_fish_eye,Icons.close];
var answerTimer = List<int>();


class Quiz1 extends StatefulWidget{

  @override
  State<StatefulWidget> createState(){
    return new Quiz1State();
  }

}


var onchoise= [0,1,2,3];
void updateChoiceText(){// questionNumber
  var a=[0,0,0,0];
  questionNumber=tenProblems[questionCounter];
  Word word=wordBox.get(questionNumber);
  bool containsA=word.jpn.contains('A');
  bool containsB=word.jpn.contains('B');
  //todo:wordbox.getの関係で稀にエラーが出る　要修正
  /*The following NoSuchMethodError was thrown building Builder:
The getter 'jpn' was called on null.
Receiver: null
Tried calling: jpn

The relevant error-causing widget was:
  MaterialApp file:///Users/mkv/AndroidStudioProjects/StudyWords/lib/main.dart:60:34
When the exception was thrown, this was the stack:
#0      Object.noSuchMethod (dart:core-patch/object_patch.dart:53:5)
#1      updateChoiceText (package:StudyWords/quiz1.dart:31:23)
#2      Quiz1State.reset (package:StudyWords/quiz1.dart:76:5)
#3      Quiz1State.initState (package:StudyWords/quiz1.dart:85:5)
#4      StatefulElement._firstBuild (package:flutter/src/widgets/framework.dart:4640:58)
...
════════════════════════════════════════════════════════════════════════════════════════════════════
*/
  List<Word> listA;
  List<Word> listBandA=List<Word>();
  if(containsA){listA=wordBox.values.where((word) => word.jpn.contains('A')).toList().cast<Word>();
                listA.sort((a, b) => b.priority.compareTo(a.priority));}
  if(containsA&&containsB) {listBandA=listA.where((word) => word.jpn.contains('B')).toList().cast<Word>();}
  do{

    for(int i=0; i<=3;i++){
      a[i] = wordBox.keyAt(random.nextInt(wordBox.length));}
    if(containsA && 2<=listA.length){
                    if(2<=listBandA.length)listA=listBandA;
                    int max=math.min(listA.length,4);
                   for(int i=0;i<max;i++)
                   {a[random.nextInt(4)]=listA[i].id;}
                 }
    a[random.nextInt(4)]=questionNumber;
    print("選択肢作成");
    //random.nextInt(4)は、0以上４未満の乱数を生成（0は含み、4は含まない）
  }while(a[0]==a[1]||a[1]==a[2]||a[2]==a[0]||a[0]==a[3]||a[1]==a[3]||a[2]==a[3]);
  onchoise=a;

}
List<int> tenProblems=new List();//出題する英単語の番号が入ってる のちに、classのnameにしてもいいかもね これは要素数10の配列を生成するコード
void make10problems()
{print(todaywords.isEmpty.toString()+"make10");
  if(todaywords.isEmpty) {

    tenProblems=new List();
    List problems = wordBox.values.toList();
    int problemSum=min(problems.length,10);
    problems.sort((a, b) => b.priority.compareTo(a.priority));
    for(int i=0; i<problemSum; i++)tenProblems.add(problems[i].id);
  }//tenProblems = wordBox.values.where((word) => word.eng.startsWith('c')).toList();
  else{
    tenProblems=todaywords;
  }
}


class Quiz1State extends State<Quiz1>{
  //var btncolor = [Colors.lightBlue];

  var stopwatch;
  void reset(){
    make10problems();
    updateChoiceText();
    resetAnswerState();
    answerState=List<IconData>(tenProblems.length);
    answerTimer=List<int>(tenProblems.length);
    stopwatch = new Stopwatch()..start();
  }
  var btncolor= new List.filled((4), Colors.lightBlue);
  @override
  void initState(){
    reset();
    print("reset");
    super.initState();

  }

  @override
  Widget build(BuildContext context){

    return new WillPopScope(
        onWillPop: ()async => false,

        child: Scaffold(
            body:Container(decoration: new BoxDecoration(color: Colors.lightBlue),
              child:SafeArea(


                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  verticalDirection: VerticalDirection.up,
                  children: [
                    new Padding(padding: EdgeInsets.only(top:47.0)),
                    Container( color: Colors.white70, width: 10000, height:1.5 ),
                    new SizedBox(
                      width: double.infinity,
                      height: 47.0,
                      child: new FlatButton(

                        color: btncolor[0],
                        onPressed: (){
                          if(wordBox.get(onchoise[0]).jpn == wordBox.get(questionNumber).jpn){
                            debugPrint("Correct");
                            memoryAnswerState("correct");

                            updateQuestion();
                          }else{
                            debugPrint("Wrong");
                            setState(() { btncolor[0] = Colors.grey; });
                            memoryAnswerState("wrong");

                            //setState(() {  });

                          }

                        },
                        child: new Text(wordBox.get(onchoise[0]).jpn,
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white
                          ),),
                      ),
                    ),
                    Container( color: Colors.white70, width: 10000, height:1.5 ),
                    new SizedBox(
                      width: double.infinity,
                      height: 47.0,
                      child: new FlatButton(

                        color: btncolor[1],
                        onPressed: (){
                          if(wordBox.get(onchoise[1]).jpn== wordBox.get(questionNumber).jpn){
                            debugPrint("Correct");
                            memoryAnswerState("correct");
                            updateQuestion();
                          }else{
                            debugPrint("Wrong");
                            setState(() { btncolor[1] = Colors.grey; });
                            memoryAnswerState("wrong");

                          }

                        },
                        child: new Text(wordBox.get(onchoise[1]).jpn,
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white
                          ),),
                      ),
                    ),
                    Container( color: Colors.white70, width: 10000, height:1.5 ),
                    new SizedBox(
                      width: double.infinity,
                      height: 47.0,
                      child: new FlatButton(

                        color: btncolor[2],
                        onPressed: (){
                          if(wordBox.get(onchoise[2]).jpn == wordBox.get(questionNumber).jpn){
                            debugPrint("Correct");
                            memoryAnswerState("correct");
                            updateQuestion();
                          }else{
                            debugPrint("Wrong");
                            setState(() { btncolor[2] = Colors.grey; });
                            memoryAnswerState("wrong");
                          }

                        },
                        child: new Text(wordBox.get(onchoise[2]).jpn,
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white
                          ),),
                      ),
                    ),

                    Container( color: Colors.white70, height:1.5 ),
                    new SizedBox(
                      width: double.infinity,
                      height: 47.0,
                      child: new FlatButton(

                        color: btncolor[3],
                        onPressed: (){
                          if(wordBox.get(onchoise[3]).jpn== wordBox.get(questionNumber).jpn){
                            debugPrint("Correct");
                            memoryAnswerState("correct");
                            updateQuestion();
                          }else{
                            debugPrint("Wrong");
                            setState(() { btncolor[3] = Colors.grey; });
                            memoryAnswerState("wrong");
                          }

                        },
                        child: new Text(wordBox.get(onchoise[3]).jpn,
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.white
                          ),),
                      ),
                    ),
                    Container( color: Colors.white70, width: 10000, height:1.5 ),
                    new Padding(padding: EdgeInsets.only(bottom:300.0)),
                    Text(wordBox.get(questionNumber).eng,style: new TextStyle(
                        fontSize: 40.0,
                        color: Colors.white
                    ),)
                  ],
                ),
              ),
            )));

  }

  void updateQuestion(){//正解時に呼び出される
    //debugPrint(stopwatch.elapsedMicroseconds.toString());
    answerTimer[questionCounter]=stopwatch.elapsedMilliseconds;
    //stopwatch.stop();
    setState((){
      if(questionCounter == tenProblems.length -1){
        //終了処理
        Navigator.push(context, new MaterialPageRoute(builder:(context)=> new Summary(/*score: 12345,*/)));
        if(tenProblems.isNotEmpty) assignToCurve();
        calcScore(tenProblems,answerTimer,answerState);


      }
      else{
        stopwatch.reset();
        stopwatch.start();
        questionCounter++;
        btncolor= new List.filled(4, Colors.lightBlue);
        updateChoiceText();//fixed20200619
        resetAnswerState();
      }
    });


  }

  void resetAnswerState(){

    if(questionCounter>=answerState.length){answerState.add(Icons.panorama_fish_eye);}
    answerState[questionCounter]=Icons.panorama_fish_eye;

  }
  void memoryAnswerState(var state){
    //answerState[0]=1;answerState[questionNumber] = "null";
    //debugPrint("num:$questionNumber");
    //debugPrint(answerState[questionNumber]);

    switch(state) {
      case "wrong": {
        state=Icons.close;
      }
      break;

      case "correct": {
        state=Icons.panorama_fish_eye;
      }
      break;

    }
    if(answerState[questionCounter]!=Icons.close) {
      //debugPrint("inIF");
      answerState[questionCounter] = state;
      //debugPrint("inIF");
    }//一度答えた（そして不正解だった）問題のanswerStateを上書きしないようにしている
    //  debugPrint(answerState[questionNumber]);

  }

}


class Summary extends StatelessWidget{

  // final int score;
  //Summary({Key key,@required this.score}) : super(key: key);
  @override
  Widget build(BuildContext context){
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(

          persistentFooterButtons:<Widget>[
              new MaterialButton(
                minWidth: 200,
                height: 50.0,
                color: Colors.white,
                shape: Border.all(width: 1.0, color:Colors.lightBlue[400]),
                onPressed: () {
                  //クイズの後のサマリー画面終了時のリセット reset
                  todaywords=List<int>();
                  answerState[0] = Icons.panorama_fish_eye;
                  questionNumber = 0;
                  questionCounter = 0;
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: new Text("ホームへ戻る",
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.lightBlue[400]
                  ),),
              ),

            ],



          body: ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black38),
                    ),
                  ),
                  child: ListTile(
                    leading:  Icon(answerState[index]),
                    title: Text(wordBox.get(tenProblems[index]).eng),
                    subtitle: Text(wordBox.get(tenProblems[index]).jpn),
                    //trailing: Text(answerTimer[index].toString()+"ms"),
                    onTap: () { /* react to the tile being tapped */ },
                  ));},
            itemCount: answerState.length,
          ),



        )

    );

  }


}
