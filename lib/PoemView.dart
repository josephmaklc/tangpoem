library mylibrary;

import 'package:flutter/material.dart';

import 'db/controller/PoemController.dart';
import "db/model/Poem.dart";
import 'highlightText.dart';

class PoemView extends StatelessWidget {
  final String id;
  String highlightText;
  double fontSize;

  PoemView({Key? key, required this.id, this.highlightText="", required this.fontSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Poem>(
        future: loadChapter(),
        builder: (context, AsyncSnapshot<Poem> snapshot) {
          if (snapshot.hasData) {
            Poem poem = snapshot.data as Poem;
            return PoemScaffold(context,poem,fontSize);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }

  Future<Poem> loadChapter() async {
    PoemController c = PoemController();
    final db = await c.initPoemsTable();
    return c.getPoemById(db, id);
  }

  bool ignoreCase=true;



  Scaffold PoemScaffold(BuildContext context,Poem poem, double fontSize) {

    TextStyle normalTextStyle = TextStyle(fontSize: fontSize);
    TextStyle highlightTextStyle = TextStyle(fontSize: fontSize, backgroundColor: Colors.yellow);

    return Scaffold(
        appBar:
        AppBar(title: Text(poem.title+' - '+poem.author),
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
                HighlightText(poem.text,
                    highlightText,true,normalTextStyle,highlightTextStyle,true)
            )
        )
    );
  }
}