import 'editRoute.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'dart:io';

import 'dart:ui';
import 'dart:async';

import 'DictAndSQL.dart';
final Color disableColor=Colors.grey;
class DetailScreen extends StatefulWidget {
  final File image;
  DetailScreen(this.image);

  @override
  _DetailScreenState createState() => new _DetailScreenState(image);
}

class _DetailScreenState extends State<DetailScreen> {
  final widgetKey = GlobalKey();

  final File image;
  _DetailScreenState(this.image);


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

    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regEx = RegExp(pattern);
    //RegExp regEX_aZ =RegExp(r'^[a-zA-Z]+$');
    String mailAddress = "";
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        if (line.text.length>2) {
          for (TextElement element in line.elements) {
            if(element.text.length<2||!RegExp(r'^[a-zA-Z]+$').hasMatch(element.text))continue;
            _elements.add(element);
            mailAddress += element.text + '\n';
          }
        }
      }
    }

    if (this.mounted) {
      setState(() {
        recognizedText = mailAddress;
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

    if(colors==null) colors=new List.generate(elements.length, (i)=>Colors.blueGrey);
    if(isSelected==null) isSelected=new List.generate(elements.length, (i)=>false);

    for(int i=0; i<elements.length; i++) {
      Rect boundingBox = elements[i].boundingBox;
      widgets.add(Positioned(
        top: scaleY * boundingBox.top,
        left: scaleX * boundingBox.left,
        width: (boundingBox.left - boundingBox.right).abs() * scaleX,
        height: (boundingBox.bottom - boundingBox.top).abs() * scaleY,
        child: GestureDetector(
          onTapDown:(detail){
          print("ontap!");
            setState(() {
              isSelected[i]=!isSelected[i];
              colors[i]=isSelected[i]?Colors.lightBlue:Colors.blueGrey;

          });
          print(colors[i]);},
          child: Container(
            alignment: Alignment(0.0, 0.0),
            color: colors[i],
            child: FittedBox(fit: BoxFit.fitWidth,
              child: Text(elements[i].text.toLowerCase()),),
          ),
        ),
      ));
    }
    return widgets;
  }



  @override
  Widget build(BuildContext context) {
    debugPrint("build!");
    if(imageSize==null){
      WidgetsBinding.instance.addPostFrameCallback((_){RenderBox box = widgetKey.currentContext.findRenderObject();
      globalOffset = box.localToGlobal(Offset.zero);
      imageSize= box.size;});
      setState(() {

      });}
    bool canNavigateNext =(isSelected!=null&&isSelected.contains(true));

    return Scaffold(
      appBar: AppBar(
        title: Text("Image Details"),
      ),
      body: _imageSize != null
          ? Stack(
        children: <Widget>[

          Align(alignment: Alignment.topCenter,
            child: Container(
              width: double.maxFinite,
              color: Colors.black,
              child: CustomPaint(
                foregroundPainter:
                TextDetectorPainter(_imageSize, _elements),
                child: AspectRatio(
                  aspectRatio: _imageSize.aspectRatio,
                  child: Image.file(
                    image,
                    key: widgetKey,
                  ),
                ),
              ),
            ),
          ),
          Align(alignment:Alignment.topCenter,child: Stack(children:makeWidgetA(_imageSize, _elements))),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              elevation: 8,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Selected words",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 60,
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



class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.elements);

  final Size absoluteImageSize;
  final List<TextElement> elements;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.red
      ..strokeWidth = 2.0;

    for (TextElement element in elements) {
      canvas.drawRect(scaleRect(element), paint);
    }
  }

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return true;
  }
}