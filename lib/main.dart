import 'package:flutter/material.dart';
import './quiz1.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:hive/hive.dart';
import 'models/word.dart';
import 'processing.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'image_detail.dart';



List<int> todaywords=new List();
List wordPriority;

final wordBox=Hive.box('words');
final dataBox=Hive.box('data');
final dailyBox=Hive.box('daily');


DateTime now = new DateTime.now();
DateTime nowDate = new DateTime(now.year, now.month, now.day);

void main() async{
  //debugPrint(questions[0]+"main");
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);

  Future<void> _checkDaily() async{
    DateTime now = new DateTime.now();
    nowDate = new DateTime(now.year, now.month, now.day);
    //List<int> todaydaily=dailyBox.get(nowDate.toIso8601String(),defaultValue: List<int>());
    List<int> todaydaily=dailyBox.get(nowDate.toIso8601String(),defaultValue: List<int>()).cast<int>();
    print("GOOOO!");
    if(todaydaily.isNotEmpty)//todaywords=todaydaily;
    {for(int i=0;i<todaydaily.length; i++)if(wordBox.containsKey(todaydaily[i]))todaywords.add(todaydaily[i]);
      //ループを回し、今も削除されていないものだけ今日の単語に追加
    }
  }

  Future<void> _openBoxes() async {
    debugPrint("point1");
   await Hive.openBox("words");
   await Hive.openBox("data");
   await Hive.openBox("daily");
   debugPrint("point2");
   _checkDaily();
   calcPriorityWithDate();
   return;
  }

  runApp(
      FutureBuilder(
      future: _openBoxes(),
          builder: (context,snapshot){
         if(snapshot.connectionState == ConnectionState.done)
         { if(snapshot.hasError)return Text(snapshot.error.toString(),textDirection: TextDirection.ltr);
           else{
                      return new MaterialApp(debugShowCheckedModeBanner: false,
                                //flutter_localizationsで中華フォントから日本語フォントに
                                localizationsDelegates: [
                                  GlobalMaterialLocalizations.delegate,
                                  GlobalWidgetsLocalizations.delegate,
                                  GlobalCupertinoLocalizations.delegate,
                                  ],
                                supportedLocales: [
                                  Locale('ja', 'JP'),
                                   ],
                                //theme: ThemeData( textTheme: GoogleFonts.notoSansTextTheme()),
                                home: new EnglishQuiz(),
                                title: 'StudyWords'
                                );}}
         else return Container(
           color: Colors.white,
           child: Center(child:  CircularProgressIndicator()),
         );
      }
  )
  );
  Hive.registerAdapter(WordAdapter(),0);
}

class EnglishQuiz extends StatefulWidget  {
  // This widget is the root of your application.
  @override
  State<StatefulWidget> createState(){
    return new EnglishQuizState();
  }
}

class EnglishQuizState extends State<EnglishQuiz> {
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _textFieldController2 = TextEditingController();




  String _text= todaywords.isNotEmpty ? "Words of Today!" : "Start Quiz";
  void initState() {
    super.initState();
   }



  Widget getInfopage() {
    return Container(color: Colors.lightBlueAccent,
      child: Scaffold(
        backgroundColor: Colors.lightBlue[300],
        body:
            Center(
              child: new MaterialButton(
                minWidth: 200,
                height: 50.0,
                color: Colors.white,
                onPressed: startQuiz,
                child: new Text(_text,
                  style: new TextStyle(
                      fontSize: 20.0,
                      color: Colors.lightBlue[400]
                  ),),
              ),
            ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () async {
           await _takePicture().then((File image) {
             print(image==null);
            if (image != null) {
              Navigator.push(
              context, MaterialPageRoute(
            builder: (context) => DetailScreen(image),
        ),).then((value) =>  setState((){}));
            }});
      }),));
  }

  Widget getImportpage() {
    //return Container(color: Colors.lightBlue,);
    return Scaffold(
      backgroundColor: Colors.lightBlue[400],
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add_photo_alternate),
          onPressed: () async {
            await _pickPicture().then((File image) {
              print(image==null);
              if (image != null) {
                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context) => DetailScreen(image),
                ),).then((value) =>  setState((){}));
              }});
          }),
      body: Center(
        child: SingleChildScrollView(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Padding(
                 padding: EdgeInsets.only(bottom: 40.0),
                 child:Text(_textFieldController.text+" / "+_textFieldController2.text, textAlign: TextAlign.center, style: TextStyle(fontSize: 22.0,color: Colors.white),),),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                alignment: Alignment.center,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'English',
                  ),
                  style: TextStyle(fontSize: 20.0,color: Colors.white),
                  controller: _textFieldController,

                  onChanged: (String value){
                    setState(() {

                    });
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                alignment: Alignment.center,
                child: TextField(
                  decoration: InputDecoration(
                      hintText: 'Japanese',


                  ),
                  style: TextStyle(fontSize: 20.0,color: Colors.white),
                  controller: _textFieldController2,
                    onChanged: (String value){
                      setState(() {

                      });
                    }
                ),

              ),
           Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: new MaterialButton(
                  minWidth: 200,
                  height: 50.0,
                  color: Colors.white,
                  onPressed: adddata,
                  child: new Text("Add",
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: Colors.lightBlue[400]
                    ),),
                )),

              ],

          ),
        ),

      ),
);
  }

  Widget getDatapage() {
    TextEditingController dialogEngController=new TextEditingController();
    TextEditingController dialogJpnController=new TextEditingController();
    return Scaffold(
        backgroundColor: Colors.lightBlue,
        body:ListView.builder(

          itemBuilder: (BuildContext context, int index) {
            Word word=wordBox.getAt(index);

            return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white70),

                  ),
                ),
                child: ListTile(
                  leading:  Text((index+1).toString(),
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white
                    ),),
                  trailing: Text(word.priority.toString()+":"+word.score.toString()),
                  title: Text(word.eng,style: TextStyle(fontSize: 18,
                      color: Colors.white)),
                  subtitle: Text(word.jpn,style: TextStyle(
                      color: Colors.white70)),

                  onTap: () {print(word.id); print(dataBox.get("lastID"));

                  dialogEngController.text=word.eng;
                  dialogJpnController.text=word.jpn;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return  Column(
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
                                    TextField(controller: dialogEngController,textAlign: TextAlign.center,decoration: InputDecoration(labelText: ("English")),),
                                    TextField(controller: dialogJpnController,textAlign: TextAlign.center,decoration: InputDecoration(labelText: ("Japanese")),)
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
                                          onPressed: (){showDialog(
                                                  context: context,
                                                   barrierDismissible: true,
                                                  builder: (BuildContext context) {

                                                      return AlertDialog(
                                                         title: Text('削除しますか？'),
                                                         content: Text("”"+(index+1).toString()+" : "+word.eng+'”を削除しますか？'),
                                                        actions: <Widget>[
                                                        FlatButton(
                                                         child: Text('Cancel'),
                                                          onPressed: () => Navigator.of(context).pop(1),
                                                         ),
                                                        FlatButton(
                                                           child: Text('OK'),
                                                          onPressed: (){Navigator.of(context).pop(1); dellist(index);}, //correctAnswers.removeAt(index),
                                                        ),],
                                                       );
                                                  });Navigator.pop(context);}
                                              ,child:Row(
                                          children: <Widget>[
                                            Icon(Icons.delete,color: Colors.red,),
                                            Text("削除",style: TextStyle(color: Colors.red),)
                                          ],),),
                                      ),
                                      Row(
                                        children: <Widget>[
                                          FlatButton(child: Text("Cancel"),onPressed:(){Navigator.pop(context);},),
                                          FlatButton(child: Text("OK"),onPressed: (){
                                            word.eng=dialogEngController.text;
                                            word.jpn=dialogJpnController.text;
                                            wordBox.putAt(index, word);
                                            setState(() {});
                                            Navigator.pop(context);},
                                            )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]

                          ),

                        ],

                      );
                    },
                  );


                  /*showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {

                        return AlertDialog(
                          title: Text('削除しますか？'),
                          content: Text("”"+(index+1).toString()+" : "+word.eng+'”を削除しますか？'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop(1),
                            ),
                            FlatButton(
                              child: Text('OK'),
                              onPressed: (){Navigator.of(context).pop(1); dellist(index);}, //correctAnswers.removeAt(index),
                            ),
                          ],
                        );
                      });*/ },
                ));},
          itemCount:wordBox.length, //questions.length,
        ));



  }
  dellist (int num){

    deleteWord(num);
    setState(() {

    });
  }
    //return Container(color: Colors.lightBlue[600],);

  Future<File> _takePicture() async {
    File image;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: ImageSource.camera,maxHeight: 1000,maxWidth: 2000 );

      setState(() {
        image = File(pickedFile.path);
      });
    } catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return image;
  }
  Future<File> _pickPicture() async {
    File image;
    try {

      final picker = ImagePicker();
      final pickedFile = await picker.getImage(source: ImageSource.gallery,maxHeight: 1000,maxWidth: 2000 );

      setState(() {
        image = File(pickedFile.path);
      });
    } catch (e) {
      print("Camera Exception: $e");
      return null;
    }

    return image;
  }

  Widget build(BuildContext context) {
    //debugPrint("BUILD!!");
    //print("build!");print(Hive.box('config').get("lastID"));

    _text= todaywords.isNotEmpty? "Words of Today!" : "Start Quiz";
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: new Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TabBar(
                  tabs: <Widget>[
                    Tab(icon: Icon(Icons.info),),
                    Tab(icon: Icon(Icons.playlist_add,),),//Icons.camera_alt
                    Tab(icon: Icon(Icons.format_list_numbered,),),
                  ],
                ),
              ]),),
        body: TabBarView(
            children: <Widget>[
              getInfopage(),
              getImportpage(),
              getDatapage(),
            ]),
      ),
    );

  }

  void startQuiz() {
    if(wordBox.length>=4){

    setState(() {
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new Quiz1())).then((value) =>  setState((){}));}
    );}
    else{
      showDialog<int>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('入力してください'),
              content: Text('登録されている英単語の数が少ないため開始できません。\n4つ以上登録してからもう一度お試しください。'),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(1),
                ),
              ],
            );
          });
    }
  }



   void adddata (){if(_textFieldController.text==""||_textFieldController2.text=="")
                  {

                      // ダイアログを表示------------------------------------
                      showDialog<int>(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('入力してください'),
                              content: Text('空欄の箇所があります。\n入力してからもう一度追加してください。'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('OK'),
                                  onPressed: () => Navigator.of(context).pop(1),
                                ),
                              ],
                            );
                          });
                          }


                  else{
                   final newWord = Word(_textFieldController.text, _textFieldController2.text,dataBox.get("lastID",defaultValue: 0)+1,0,0,null,0,0);
                   addWord(newWord);
                   //dataBox.put("lastID",dataBox.get("lastID",defaultValue: 0)+1 );
                   //addWord内に移動


                   setState(() {_textFieldController.text=""; _textFieldController2.text="";});}
  }
  @override
  void dispose(){
    Hive.close();
    super.dispose();
  }
}
