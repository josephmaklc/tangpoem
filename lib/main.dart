import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tangpoem/FilteredView.dart';
import 'package:tangpoem/searchPage.dart';
import 'package:xml/xml.dart';
import 'PoemView.dart';
import 'aboutDialog.dart';
import 'configDialog.dart';

import 'db/controller/PoemController.dart';

import 'dart:async';
import 'package:flutter/services.dart' show rootBundle;

import 'db/model/ListItemPoem.dart';
import 'db/model/Poem.dart';
import 'package:intl/intl.dart';

const String appTitle = "唐詩三百首";
const String author = "Joseph Mak";
const String version = "v 2.0";
const String appDate = "June 9, 2022";
double fontSize=18;

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyApp(),
    ),
  );
}

String listingBy="詩體";

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class PoemLists {
  List<ListItemPoem> categoryList = <ListItemPoem>[];
  List<ListItemPoem> authorList = <ListItemPoem>[];
  List<ListItemPoem> titleList = <ListItemPoem>[];
}

class _MyAppState extends State<MyApp> {

  // default states
  String title=appTitle;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // initialize database. This FutureBuilder will call a _getThingsOnStartup,
    // once done, return the scaffold widget, before then, show the progress indicator
    return FutureBuilder<PoemLists>(
        future: _getThingsOnStartup(),
        builder: (context, AsyncSnapshot<PoemLists> snapshot) {
          if (snapshot.hasData) {
            PoemLists poemlists = snapshot.data as PoemLists;
            List<ListItemPoem> listing=<ListItemPoem>[];

            listing = poemlists.categoryList; //"詩體", "作者", "詩題","我的心愛"

            if (listingBy=="詩體") listing = poemlists.categoryList;
            if (listingBy=="作者") listing = poemlists.authorList;
            if (listingBy=="詩題") listing = poemlists.titleList;


            //for (String s in listing) {
            //  print("s: "+s);
            //}

            return listingScaffold(context,listing);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );

  }

  Future<String> selectListingBy() async {
    String result="";
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text('排列',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            children: <Widget>[
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text('詩體',style: TextStyle(fontSize: 18.0)),
                ],
              ),onPressed: () {
                result= "詩體";
                Navigator.pop(context);
              },),
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text('作者',style: TextStyle(fontSize: 18.0))
                ],
              ),onPressed: () {
                  result= "作者";
                  Navigator.pop(context);
              },),
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text('詩題',style: TextStyle(fontSize: 18.0))
                ],
              ),onPressed: () {
                result= "詩題";
                Navigator.pop(context);
              },),
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text('我的心愛',style: TextStyle(fontSize: 18.0)),
                ],
              ),onPressed: () {
                result = "我的心愛";
                Navigator.pop(context);
              },),

            ],
          );
        }
    );
    return result;

  }

  Scaffold listingScaffold(BuildContext context, List<ListItemPoem> listing) {
    return Scaffold(
        appBar: AppBar(

            title: Text(title+' - '+listingBy),
            actions: [

              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => SearchPage(fontSize:fontSize))))

            ]
        ),

        drawer:
        Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[

              DrawerHeader(
                child: Text(title,style: TextStyle(color: Colors.white,fontSize:fontSize)),
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: Text('排列',style:TextStyle(fontSize: fontSize)),
                onTap: () async {
                  String result = await selectListingBy();
                  setState(() {
                    listingBy = result;
                    print("setting listingBy: "+result);
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text('設定',style:TextStyle(fontSize: fontSize)),
                onTap: () async {
                  ConfigInfo result = await showConfigurationDialog(context, listingBy, fontSize);
                  setState(() {
                    listingBy = result.listingBy;
                    fontSize = result.fontSize;

                  });
                  Navigator.pop(context);

                },
              ),

              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text('關於',style:TextStyle(fontSize: fontSize)),
                onTap: () {
                  myShowAboutDialog(context, appTitle, author, version, appDate);
                },
              ),

            ],
          ),
        ),

        body:

        ListView.separated(
          separatorBuilder: (context, index) => Divider(
            color: Colors.black,
          ),
          itemCount: listing.length,
          itemBuilder: (context, index) {

            ListTile item = ListTile(
              title: Text(listing[index].displayText,style:TextStyle(fontSize: fontSize)),
              onTap: () {

                //"詩體", "作者", "詩題","我的心愛"
                if (listingBy=="詩體" || listingBy=="作者") {
                  String filteredBy="";
                  if (listingBy=="詩體") filteredBy="category";
                  if (listingBy=="作者") filteredBy="author";

                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilteredView(appTitle:appTitle,filteredBy:filteredBy, filteredValue:listing[index].displayText,fontSize:fontSize)));

                }
                else {

                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PoemView(highlightText:"",id:listing[index].id,fontSize:fontSize)));

                }

              }, // Handle your onTap here.
            );
            return item;
          },
        )


    );
  }

  Future<String> loadAsset(String name) async {
    print("trying to load asset: "+name);
    try {
      return await rootBundle.loadString(name);
    }
    catch (e) {
      print ("exception: "+e.toString());
      return "bam cannot load file: "+name;
    }
  }

  Future<PoemLists> _getThingsOnStartup() async {

    print("getThingsOnStartup");

    PoemController c = PoemController();

    final db = await c.initPoemsTable();

   //await c.clearPoemTable(db);

    PoemLists poemLists = PoemLists();
    poemLists.categoryList = await c.getCategories(db);
    poemLists.titleList = await c.getTitles(db);
    poemLists.authorList = await c.getAuthors(db);

    print("about to be done with getThingsOnStartup");
    return poemLists;

  }
}