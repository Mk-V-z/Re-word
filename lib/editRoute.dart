import 'package:flutter/material.dart';
import 'package:reword/processing.dart';
import 'dart:ui';
import 'dart:async';
import 'DictAndSQL.dart';
import 'models/word.dart';
import 'main.dart';
import 'dart:math';

final Color disableColor=Colors.grey;
class EditAfterScan extends StatefulWidget  {
  final List<String> selectedWords;
  EditAfterScan(this.selectedWords);

  @override
  _EditAfterScanState createState() => new _EditAfterScanState(selectedWords);

}

class _EditAfterScanState extends State<EditAfterScan> {
  final List<String> selectedWords;
  _EditAfterScanState(this.selectedWords);

  bool _canNavigateNext =false;

  List<String> meanings=new List();
  List<List<String>> bracketMeanings=new List();
  List<List<bool>> _meaningState=new List();
  List<TextEditingController>_controller= new List();

  Future<void> getMeanings () async{
  //selectedWords.forEach((element) async {meanings.add(await getMeaning(element));});
    if(meanings.isNotEmpty)return (){print(meanings[0]);};
    int len=selectedWords.length;
    meanings=[]..length = len;
    bracketMeanings=[]..length = len;
    _meaningState=[]..length = len;
    _controller= new List.generate(selectedWords.length,(i)=> new TextEditingController());
  for(int i=0;i<selectedWords.length; i++)meanings[i]=await getMeaning(selectedWords[i]);
  for(int i=0;i<selectedWords.length; i++)bracketMeanings[i]=getExtractionBrackets(meanings[i]);
  for(int i=0;i<selectedWords.length; i++)_meaningState[i]=new List.generate(bracketMeanings[i].length, (i)=> false);
  //print(extractionBrackets(meanings[0]));
  return (){print(meanings[0]);};
  }

  void _delWord(int ind){
    selectedWords.removeAt(ind);
    meanings.removeAt(ind);
    bracketMeanings.removeAt(ind);
    _meaningState.removeAt(ind);
    _controller.removeAt(ind);
    setState(() {});
  }

  void _addmeaning (int ind){
    if(_controller[ind].text=="")return;
    bracketMeanings[ind].add(_controller[ind].text);
    _meaningState[ind].add(true);
    _controller[ind].clear();
    setState((){});
  }

  void _addWordsToBox(){
    for(int i=0;i<selectedWords.length;i++)
      {String jpn= _makeJpn(i);
       Word newWord = Word(selectedWords[i], jpn,dataBox.get("lastID",defaultValue: 0)+1,0,0,null,0,0);
       addWord(newWord);}
  }

  String _makeJpn(int ind){
    String str="";
    List<int> list=new List();
    for(int i=0;i<_meaningState[ind].length;i++)if(_meaningState[ind][i])list.add(i);
    str+=bracketMeanings[ind][list.first];
    for(int i=1;i<list.length;i++)str+=",${bracketMeanings[ind][list[i]]}";
    return str;
  }


  void get_canNavigateNext()
  {_canNavigateNext=false;
   for(int i=0;i<_meaningState.length;i++)if(!_meaningState[i].contains(true))return;
   print("gettrue");
   _canNavigateNext=true;
   return;}

   void _changeWord(int ind,String newEng) async{
    selectedWords[ind]=newEng;
    //print("bracketMeanings[ind].length${bracketMeanings[ind].length}");
    for(int i=bracketMeanings[ind].length-1;0<=i; i--)
      {if(_meaningState[ind][i])continue;
        //print("[$ind][$i] (${bracketMeanings[ind][i]})del");
        bracketMeanings[ind].removeAt(i);
        _meaningState[ind].removeAt(i);
      }
     meanings[ind]=await getMeaning(newEng);
     bracketMeanings[ind]+=getExtractionBrackets(meanings[ind]);
     for(int i=0;i<getExtractionBrackets(meanings[ind]).length;i++)_meaningState[ind].add(false);

     setState(() {});
   }


 TextEditingController dialogInputController=new TextEditingController();

  Widget _editDialog(int index){
    return Column(
      children: <Widget>[
        AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("単語の変更"),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(selectedWords[index]),
                  Icon(Icons.arrow_downward),
                  TextField(controller: dialogInputController,textAlign: TextAlign.center,
                    decoration: InputDecoration(labelText: ("change to")),autofocus: true,)
                ],
              ),
            ),
            actions: <Widget>[

              Container(width:double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(margin:EdgeInsets.only(left: 16),
                      child: OutlineButton(
                        onPressed: (){_delWord(index);Navigator.pop(context);},child:Row(
                        children: <Widget>[
                          Icon(Icons.delete,color: Colors.red,),
                          Text("削除",style: TextStyle(color: Colors.red),)
                        ],),),
                    ),
                    Row(
                      children: <Widget>[
                        FlatButton(onPressed:(){Navigator.pop(context);},child: Text("Cancel"),),
                        FlatButton(onPressed: (){_changeWord(index,dialogInputController.text);Navigator.pop(context);},
                          child: Text("OK"),)
                      ],
                    ),
                  ],
                ),
              ),
            ]

        ),

      ],

    );
  }

  ListView makeWordwidget(){
    return ListView.builder(
        itemCount: selectedWords.length,
        shrinkWrap: true,
        itemBuilder: (context, int index) {
         return Card(
              child:Row(mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex:3,child: GestureDetector(
                      onTap:(){dialogInputController.text=selectedWords[index];
                        showDialog(
                          context: context,
                          builder: (context) {return  _editDialog(index);},
                    );
                  }, child: FittedBox(fit:BoxFit.scaleDown,
                        child:Text(selectedWords[index],style: TextStyle(fontSize: 30),textAlign: TextAlign.center,)))),


                  Expanded(flex:7,child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left:8.0),
                        child: Wrap( children: meaningWidget(index)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(height:35,decoration:BoxDecoration(border: Border.all(color:Colors.blue),borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: <Widget>[
                                Expanded(flex:9,child:TextField(decoration: InputDecoration(border: InputBorder.none)
                                  ,controller: _controller[index],onSubmitted:(str){ _addmeaning(index);},)),
                                Expanded(flex:1,child:Align(alignment:Alignment.centerRight,
                                          child:GestureDetector(onTap:(){_addmeaning(index);},child: Icon(Icons.add_circle_outline,),)))
                              ],
                            )),
                      )

                    ],
                  ))
                ],
              )
          );}
    );
  }

  List<Widget> meaningWidget(int index){
    List<Widget>list=[Container()];
    if(bracketMeanings[index]==null)return list;
    for(int i=0; i<bracketMeanings[index].length; i++)
    {Color _backgroundColor = _meaningState[index][i]? Colors.lightBlueAccent:Colors.white;
      debugPrint(_meaningState[index][i].toString()+i.toString());
      list.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0,top: 8.0),
          child: GestureDetector(
            onTap: (){setState(() {_meaningState[index][i]=!_meaningState[index][i];});},
            child: Container(decoration:BoxDecoration(border: Border.all(color:Colors.blue),borderRadius: BorderRadius.circular(10),color: _backgroundColor),
                child: Padding(
                   padding: const EdgeInsets.symmetric(vertical:0,horizontal: 5.0),
                   child: Text(bracketMeanings[index][i],style: TextStyle(fontSize: 19),),
                )),
          ),
        )
    );

    }
    return list;
  }


  @override
  Widget build(BuildContext context) {
    return  FutureBuilder(
        future: getMeanings(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData)
            {print("ok!");    get_canNavigateNext();
            //print(_canNavigateNext);

            return Scaffold(
                appBar: AppBar(title: Text("Image Details"),),
                body:makeWordwidget(),

                floatingActionButton: _canNavigateNext ? FloatingActionButton.extended(
                  onPressed: () {
                _addWordsToBox();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: new Icon(Icons.navigate_next),
              label: Text("次へ"),
            )
                : FloatingActionButton.extended(
              onPressed:  (){showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('入力してください'),
                      content: Text('和訳が指定されていない英単語があります。\n全ての単語に和訳を一つ以上指定してからもう一度お試しください。\n(＋の左側をタップすることで、任意の和訳を追加できます)'),
                      actions: <Widget>[
                        FlatButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(1),
                        ),
                      ],
                    );
                  });},
              icon: new Icon(Icons.navigate_next),
              label: Text("和訳をタップして選択"),
              backgroundColor: disableColor,
            ));
            }
          else
            {print("kkkk!");
              return Container();}
    },

      );
  }



}