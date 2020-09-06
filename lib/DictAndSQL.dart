import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

Future<String>getMeaning(String engword) async{
  var databasesPath = await getDatabasesPath();
  var path = join(databasesPath, "localdict.db");

// Check if the database exists
  var exists = await databaseExists(path);

  if (!exists) {
    // Should happen only the first time you launch your application
    //print("Creating new copy from asset");

    // Make sure the parent directory exists

    try {
      await Directory(dirname(path)).create(recursive: true);
    } catch (_) {}

    // Copy from asset
    ByteData data = await rootBundle.load(join("assets", "ejdict.sqlite3"));
    List<int> bytes =
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // Write and flush the bytes written
    await File(path).writeAsBytes(bytes, flush: true);

  } else {
    //print("Opening existing database");
  }
// open the database
  String str="";
  var db = await openDatabase(path, readOnly: true);
  var list = await db.rawQuery('SELECT * FROM items WHERE word=?', [engword]);
  list.forEach((element) {
    str+=element["mean"];
    //print(element["mean"]);
  });
  print("輝き;明るさ;(自の)あざやかさ".replaceAll(' / ', '\n'));
  str=str.replaceAll(' / ', '\n');
  //print(str);
 return str;
}

 List<String> getExtractionBrackets(String str){
   final exp = RegExp(r'(?<=『).*?(?=』)');
   final abcexp = RegExp(r'[A-Za-z]');
   List<String> list=exp?.allMatches(str).map((match) => match.group(0)).toList();
   List<int>delList=new List();
   for(int i=0;i<list.length; i++){
     if(list[i].contains(abcexp)){delList.add(i); continue;}
     if(list[i]=="名")delList.add(i);
   }
   for(int i=delList.length-1; i>=0; i--)list.removeAt(delList[i]);
   return list;
 }