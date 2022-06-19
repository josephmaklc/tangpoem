library mylibrary;

import 'package:flutter/material.dart';

import 'db/controller/ChpaterController.dart';
import "db/model/Chapter.dart";
import 'highlightText.dart';

class ChapterView extends StatelessWidget {
  final int chapterNumber;
  final String language;
  String highlightText;
  double fontSize;

  ChapterView({Key? key, required this.chapterNumber, required this.language, this.highlightText="", required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Chapter>(
        future: loadChapter(),
        builder: (context, AsyncSnapshot<Chapter> snapshot) {
          if (snapshot.hasData) {
            Chapter chapter = snapshot.data as Chapter;
            return chapterScaffold(context,chapter, language,fontSize);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }

  Future<Chapter> loadChapter() async {
    ChapterController c = ChapterController();
    final db = await c.initChaptersTable();
    return c.getChapter(db, chapterNumber,language);
  }

  bool ignoreCase=true;



  Scaffold chapterScaffold(BuildContext context,Chapter chapter, String language, double fontSize) {
    //print("chapperScaffold: "+fontSize.toString());



    TextStyle normalTextStyle = TextStyle(fontSize: fontSize);
    TextStyle highlightTextStyle = TextStyle(fontSize: fontSize, backgroundColor: Colors.yellow);

    return Scaffold(
        appBar:
        AppBar(title: Text(chapter.title),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                })
        ),

        body:
        Container(
            padding: const EdgeInsets.all(12.0),

            child: SingleChildScrollView(
                child: //Text(chapter.text,style: normalTextStyle)
                HighlightText(chapter.text,highlightText,true,normalTextStyle,highlightTextStyle,true)
            )
        )
    );
  }
}