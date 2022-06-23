import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:tangpoem/db/controller/PoemController.dart';
import 'package:tangpoem/db/model/Poem.dart';

import 'PoemView.dart';
import 'highlightText.dart';


class SearchPage extends StatefulWidget {

  double fontSize;
  SearchPage({Key? key, required this.fontSize}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {

  var _searchTextController = TextEditingController();

  List<Poem> poems = <Poem>[];
  String searchText="";
  String errorMessage="";

  @override
  void initState() {
    super.initState();
  }


  Future<List<Poem>> doSearch(String searchText) async {
    PoemController c = PoemController();
    Database db = await c.initPoemsTable();
    return await c.searchText(db, searchText);
  }

  bool ignoreCase=true;

  ListView poemListView(List<Poem> poem) {
    if (poems==null) {
      return ListView();
    };
    TextStyle normalTextStyle = TextStyle(fontSize: widget.fontSize);
    TextStyle highlightTextStyle = TextStyle(fontSize: widget.fontSize, backgroundColor: Colors.yellow);

    return
      ListView.separated(
          separatorBuilder: (context, index) =>
              Divider(
                color: Colors.black,
              ),
          itemCount: poems.length,
          itemBuilder: (context, index) {
            ListTile item = ListTile(
              title: Text(poems[index].title,style:normalTextStyle),
              subtitle: HighlightText(poems[index].searchResult,searchText,ignoreCase,normalTextStyle,highlightTextStyle,false),

              onTap: () {
                //_showToast(context, "somebody clicked "+chapters[index].title);

                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PoemView(highlightText:searchText,id:poems[index].id,fontSize:widget.fontSize)));
              }, // Handle your onTap here.
            );
            return item;
          });
  }



  int getTotalOccurences(List<Poem> poems) {
    int sum=0;
    for(Poem p in  poems) {
      sum+=p.occurence;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    //print("len: "+chapters.length.toString());;
    if (searchText.isNotEmpty && poems.isEmpty) {
      //errorMessage="Sorry, "+searchText+" not found";
      //errorMessage = getTextForLanguage(widget.languagePref,"Sorry, "+searchText+" not found",
      //    '抱歉，找不到 '+searchText,
      //    '抱歉，找不到 '+searchText);
      errorMessage = '抱歉，找不到 '+searchText;
    }
    int totalOccurences = getTotalOccurences(poems);
    return Scaffold(
        appBar: AppBar(
// The search area here
            title: Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child:

                Center(
                  child:

                  TextField(
                      controller: _searchTextController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _searchTextController.text = "";
                            },
                          ),
                          hintText: '搜索',
                          border: InputBorder.none),

                      onSubmitted: (String value) async {
                        //print("value="+value);

                        if (value.trim().isEmpty) {
                          setState(() {
                            errorMessage='請輸入搜索文字';
                          });
                          return;
                        }

                        var searchResults = await doSearch(value);

                        setState(() {
                          poems = searchResults;
                          searchText = value;
                          errorMessage="";
                        });
                      }
                  ),
                )

            )
        ),
        body:
        Container(
            padding: const EdgeInsets.all(12.0),


            //child: chapterListView(chapters)

            child: Column(
                children: <Widget>[
                  if (errorMessage.isNotEmpty) Text(errorMessage,style: TextStyle(fontStyle: FontStyle.italic,fontSize: widget.fontSize)),
                  if (poems.isNotEmpty) Text(
                      '找到 '+totalOccurences.toString()+" 句含有 '"+searchText+"'",style:TextStyle(fontSize: widget.fontSize)
                  ),
                  Expanded(
                      child:poemListView(poems)
                  )
                ]

            )

        )

    );
  }

}