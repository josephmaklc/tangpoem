import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tangpoem/FilteredView.dart';
import 'package:tangpoem/searchPage.dart';

import 'PoemView.dart';
import 'aboutDialog.dart';
import 'configDialog.dart';
import 'db/controller/PoemController.dart';
import 'db/model/ListItemPoem.dart';

const String appTitle = "唐詩三百首";
const String author = "Joseph Mak";
const String version = "v 2.0";
const String appDate = "June 9, 2022";

const String LISTING_BY_TITLE = "詩題";
const String LISTING_BY_AUTHOR = "作者";
const String LISTING_BY_CATEGORY = "詩體";
const String LISTING_BY_FAVORITES = "我的心愛";

// default values
double fontSize=18;
String listingBy=LISTING_BY_CATEGORY;

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyApp(),
    ),
  );
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class PoemLists {
  List<ListItemPoem> categoryList = <ListItemPoem>[];
  List<ListItemPoem> authorList = <ListItemPoem>[];
  List<ListItemPoem> titleList = <ListItemPoem>[];
  List<ListItemPoem> favoritesList = <ListItemPoem>[];
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

            listing = poemlists.categoryList;

            if (listingBy==LISTING_BY_CATEGORY) listing = poemlists.categoryList;
            if (listingBy==LISTING_BY_AUTHOR) listing = poemlists.authorList;
            if (listingBy==LISTING_BY_TITLE) listing = poemlists.titleList;
            if (listingBy==LISTING_BY_FAVORITES) {
              listing = poemlists.favoritesList;
              if (listing.isEmpty) {
             //   _showToast(context, "Cannot find My Favorites");
              }
            }


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
                  Text(LISTING_BY_CATEGORY,style: TextStyle(fontSize: 18.0)),
                ],
              ),onPressed: () {
                result= LISTING_BY_CATEGORY;
                Navigator.pop(context);
              },),
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text(LISTING_BY_AUTHOR,style: TextStyle(fontSize: 18.0))
                ],
              ),onPressed: () {
                  result= LISTING_BY_AUTHOR;
                  Navigator.pop(context);
              },),
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text(LISTING_BY_TITLE,style: TextStyle(fontSize: 18.0))
                ],
              ),onPressed: () {
                result= LISTING_BY_TITLE;
                Navigator.pop(context);
              },),
              SimpleDialogOption(child: Column(
                children: <Widget>[
                  Text(LISTING_BY_FAVORITES,style: TextStyle(fontSize: 18.0)),
                ],
              ),onPressed: () {
                result = LISTING_BY_FAVORITES;
                Navigator.pop(context);
              },),

            ],
          );
        }
    );
    return result;

  }

/*  void _showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message)

      ),
    );
  }
*/

  Future<List<ListItemPoem>> loadUpdatedListing(String listingBy) async {
    print("loadUpdatedListing");
    PoemController c = PoemController();
    final db = await c.initPoemsTable();
    if (listingBy==LISTING_BY_FAVORITES) return c.getFavoritePoems(db);
    if (listingBy==LISTING_BY_TITLE) return c.getTitles(db);
    return c.getCategories(db);
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
                    //print("setting listingBy: "+result);
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
              onTap: () async {

                if (listingBy==LISTING_BY_CATEGORY || listingBy==LISTING_BY_AUTHOR) {
                  String filteredBy="";
                  if (listingBy==LISTING_BY_CATEGORY) filteredBy="category";
                  if (listingBy==LISTING_BY_AUTHOR) filteredBy="author";

                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FilteredView(appTitle:appTitle,filteredBy:filteredBy, filteredValue:listing[index].displayText,fontSize:fontSize)));

                }
                else {

                  // Favorites may be updated so need to reload
                  await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PoemView(highlightText:"",id:listing[index].id,fontSize:fontSize)));

                  List<ListItemPoem> listingUpdated = await loadUpdatedListing(listingBy);

                  setState(() {
                    listing = listingUpdated;
                  });

                }
              },
              trailing: listingBy!=LISTING_BY_TITLE?null: IconButton(
                    onPressed: () async {
                      setState(() {
                        listing[index].favorite = !listing[index].favorite;
                      });

                      String YN = listing[index].favorite?"Y":"N";

                      PoemController c = PoemController();
                      final db = await c.initPoemsTable();
                      c.setFavoritePoem(db, listing[index].id, YN);

                    },
                    icon: Icon(
                        Icons.favorite_rounded,
                        color: listing[index].favorite? Colors.red: Colors.black12)
                )
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
    poemLists.favoritesList = await c.getFavoritePoems(db);

    print("about to be done with getThingsOnStartup");
    return poemLists;

  }
}