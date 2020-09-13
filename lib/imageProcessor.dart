import 'editRoute.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';

import 'dart:ui';
import 'dart:async';

final Color disableColor=Colors.grey;
class SelectWordsRoute extends StatefulWidget {
  final File image;
  SelectWordsRoute(this.image);

  @override
  _SelectWordsRouteState createState() => new _SelectWordsRouteState(image);
}

class _SelectWordsRouteState extends State<SelectWordsRoute> {
  final widgetKey = GlobalKey();

  final File image;
  _SelectWordsRouteState(this.image);


  Size _imageSize;
  List<TextElement> _elements = [];
  String recognizedText = "Loading ...";

  void _initializeVision() async {
    final File imageFile = image;

    if (imageFile != null) {
      await _getImageSize(imageFile);

    }

    final FirebaseVisionImage visionImage =
    FirebaseVisionImage.fromFile(imageFile);

    final TextRecognizer textRecognizer =
    FirebaseVision.instance.textRecognizer();

    final VisionText visionText =
    await textRecognizer.processImage(visionImage);


    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        if (line.text.length>2) {
          for (TextElement element in line.elements) {
            if(element.text.length<2||!RegExp(r'^[a-zA-Z/,.?!;]+$').hasMatch(element.text))continue;
            _elements.add(element);
          }
        }
      }
    }

    if (this.mounted) {
      setState(() {
      });
    }
  }
  List<String>_getSelectedWords(){
    List<String>selectedList=new List();
    for(int i=0; i<_elements.length;i++)if(isSelected[i])selectedList.add(_elements[i].text.toLowerCase());
    return selectedList;
  }
  String _listToString(List<String>list){
    String str ="";
    list.forEach((elem) {str+=elem+ '\n';});
    return str;
  }
  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

  @override
  void initState() {
    _initializeVision();
    super.initState();
  }

  Offset globalOffset;
  Size imageSize;
  List<Color> colors;
  List<bool> isSelected;
  List<Widget> makeWidgetA(Size absoluteImageSize,List<TextElement> elements)
  { List<Widget> widgets=[Container()];
    if(elements.isEmpty)return widgets;
    if(imageSize==null)return widgets;
    if(globalOffset==null)return widgets;
    widgets.removeLast();

    final double scaleX = imageSize.width / absoluteImageSize.width;
    final double scaleY = imageSize.height / absoluteImageSize.height;
    print(globalOffset);
    print("${imageSize.width}:${absoluteImageSize.width}");
  print("${imageSize.height}:${absoluteImageSize.height}");

    if(colors==null) colors=new List.generate(elements.length, (i)=>Colors.blueGrey);
    if(isSelected==null) isSelected=new List.generate(elements.length, (i)=>false);

    for(int i=0; i<elements.length; i++) {
      Rect boundingBox = elements[i].boundingBox;
      widgets.add(Positioned(
        top: scaleY * boundingBox.top,
        left:  globalOffset.dx+scaleX * boundingBox.left,
        width: (boundingBox.left - boundingBox.right).abs() * scaleX*1.0,
        height: (boundingBox.bottom - boundingBox.top).abs() * scaleY*1.05,//すこし拡大
        child: GestureDetector(

          onTapDown:(detail){
          print("ontap!");
            setState(() {
              isSelected[i]=!isSelected[i];
              colors[i]=isSelected[i]?Colors.lightBlue:Colors.blueGrey;

          });
          print(colors[i]);},
          child: Container(
            decoration: BoxDecoration(/*border: Border.all(color:Colors.deepOrange,width: 0),*/color: colors[i]),
            alignment: Alignment(0.0, 0.0),
            child: FittedBox(fit: BoxFit.fitWidth,
              child: Text(elements[i].text.toLowerCase(),style: TextStyle(fontSize: 300,color: Colors.black),)),
          ),
        ),
      ));
    }
    return widgets;
  }


  var pastOrientation;
  @override
  Widget build(BuildContext context) {
    debugPrint("build!");
    if(pastOrientation==null)pastOrientation=MediaQuery.of(context).orientation;

    if(imageSize==null||pastOrientation!=MediaQuery.of(context).orientation){
      WidgetsBinding.instance.addPostFrameCallback((_){RenderBox box = widgetKey.currentContext.findRenderObject();
      globalOffset = box.localToGlobal(Offset.zero);
      imageSize= box.size;});
      setState(() {

      });
      pastOrientation=MediaQuery.of(context).orientation;}
    bool canNavigateNext =(isSelected!=null&&isSelected.contains(true));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Select Words"),
      ),
      body: _imageSize != null
          ? Stack(
        children: <Widget>[

          Align(alignment: Alignment.topCenter,
            child: Container(
              //color:Colors.black,
              child: Image.file(
                image,
                key: widgetKey,
              )
            ),
          ),
          Align(alignment:Alignment.topCenter,child: Stack(children:makeWidgetA(_imageSize, _elements))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              elevation: 10,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Selected:",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 80,
                      child: SingleChildScrollView(
                        child: Text(
                          _listToString(_getSelectedWords()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
          : Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: canNavigateNext ? FloatingActionButton.extended(
       onPressed: () {
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => EditAfterScan(_getSelectedWords()),
           ),
         );
        },
        icon: new Icon(Icons.navigate_next),
        label: Text("次へ"),
      )
          : FloatingActionButton.extended(
        onPressed:null,
        icon: new Icon(Icons.navigate_next),
        label: Text("単語をタップして選択"),
        backgroundColor: disableColor,
      )

    );

  }
}