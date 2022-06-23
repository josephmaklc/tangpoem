library mylibrary;

import 'package:flutter/material.dart';

import 'db/controller/PoemController.dart';
import "db/model/Poem.dart";
import 'highlightText.dart';

class PoemView extends StatefulWidget {

  final String id;
  String highlightText;
  double fontSize;

  PoemView({Key? key, required this.id, this.highlightText="", required this.fontSize}) : super(key: key);
  //FilteredView({Key? key, required this.appTitle, required this.filteredBy, required this.filteredValue,required this.fontSize}) : super(key: key);

  @override
  PoemViewState createState() => PoemViewState();
}

class PoemViewState extends State<PoemView> {


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Poem>(
        future: loadChapter(),
        builder: (context, AsyncSnapshot<Poem> snapshot) {
          if (snapshot.hasData) {
            Poem poem = snapshot.data as Poem;
            return PoemScaffold(context,poem,widget.fontSize);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }

  Future<Poem> loadChapter() async {
    PoemController c = PoemController();
    final db = await c.initPoemsTable();
    return c.getPoemById(db, widget.id);
  }

  bool ignoreCase=true;

  Scaffold PoemScaffold(BuildContext context,Poem poem, double fontSize) {

    TextStyle normalTextStyle = TextStyle(fontSize: fontSize);
    TextStyle highlightTextStyle = TextStyle(fontSize: fontSize, backgroundColor: Colors.yellow);

    bool favorite = poem.favorite=="Y";

    String text = "\t"+poem.text.replaceAll("            ", "\t");
    print(text);

    return Scaffold(
        appBar:
        AppBar(title: Text(poem.title+' - '+poem.author),
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: [

              IconButton(
                  color: (favorite?Colors.red:Colors.white),

                  icon: Icon(favorite?Icons.favorite: Icons.favorite_border_outlined),
                  onPressed: () async {

                    setState(() {
                      favorite = !favorite;
                    });

                    PoemController c = PoemController();
                    final db = await c.initPoemsTable();
                    c.setFavoritePoem(db, poem.id, favorite?"Y":"N");
                  })

            ]
        ),

        body:
        Container(
            padding: const EdgeInsets.all(12.0),

            child: SingleChildScrollView(
                child: //Text(chapter.text,style: normalTextStyle)
                HighlightText(text,
                    widget.highlightText,true,normalTextStyle,highlightTextStyle,true)
            )
        )
    );
  }
}