import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tangpoem/db/model/ListItemPoem.dart';
import 'package:xml/xml.dart';

import '../model/Poem.dart';

import 'package:flutter/services.dart' show rootBundle;

class PoemController {

final String DATABASE_TABLE = "poems";
final String COLUMN_ROWID = "id";
final String COLUMN_TITLE = "title";
final String COLUMN_AUTHOR = "author";
final String COLUMN_CATEGORY = "category";
final String COLUMN_TEXT = "text";
final String COLUMN_FAVORITE = "favorite";
final String COLUMN_AUTHOR_ORDER = "authorOrder";
final String COLUMN_TITLE_ORDER = "titleOrder";


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

Future<void> populatePoemsTable(var db) async {

  String data = await loadAsset('assets/data.xml');
  var root = XmlDocument.parse(data).getElement('poems');
  if (root!=null) {
    for (XmlElement e in root.childElements) {
      if (e!=null) {
        String id = e.getElement("id")!.text;
        String title= e.getElement("title")!.text;
        String author = e.getElement("author")!.text;
        String category = e.getElement("category")!.text;
        String text = e.getElement('text')!.text;
        int authorOrder = int.parse(e.getElement('authorOrder')!.text);
        int titleOrder = int.parse(e.getElement('titleOrder')!.text);

        //print("I see e: "+e.toString());

        Poem p = Poem(title: title, id: id, author: author, category: category, favorite: "", text:text,
            authorOrder:authorOrder,titleOrder:titleOrder);
        insertPoem(db, p);
      }
      else {
        print("cannot find poems in file");
      }

    }
  }
}

  Future<Database> initPoemsTable() async {
    print("init poems table");
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();

    //print("dbPath: " + await getDatabasesPath());
    // Open the database and store the reference.
    bool isNew=false;
    var database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'poem_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        print("on create...");
        isNew=true;

        String DATABASE_CREATE =
            "create table "+DATABASE_TABLE+" (id text not null, "
                + COLUMN_TITLE+" text not null, "+COLUMN_AUTHOR+" text not null,"
                + COLUMN_TITLE_ORDER+" INTEGER not null, "+COLUMN_AUTHOR_ORDER+" INTEGER not null,"
                + COLUMN_CATEGORY+" text not null, "+COLUMN_TEXT+" text not null," + COLUMN_FAVORITE+" text not null);";

        return db.execute(DATABASE_CREATE);
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    print ("isNew: "+isNew.toString());
    if (isNew) {
      await populatePoemsTable(database);
    }
    return database;

  }

  Future<void> clearPoemTable(var db) async {
    print("clear "+DATABASE_TABLE+" table");
    try {
      db.execute("DROP TABLE "+DATABASE_TABLE);

      String DATABASE_CREATE =
          "create table "+DATABASE_TABLE+" (id text not null, "
              + COLUMN_TITLE+" text not null, "+COLUMN_AUTHOR+" text not null,"
              + COLUMN_TITLE_ORDER+" INTEGER not null, "+COLUMN_AUTHOR_ORDER+" INTEGER not null,"
              + COLUMN_CATEGORY+" text not null, "+COLUMN_TEXT+" text not null," + COLUMN_FAVORITE+" text not null);";


      db.execute(DATABASE_CREATE);
      await populatePoemsTable(db);


    } catch (e) {
      print(e.toString());
    }
  }

  // Define a function that insert chapter into the database
  Future<void> insertPoem(var db,Poem poem) async {

    print("inserting poem: "+poem.toString());
    await db.insert(
      DATABASE_TABLE,
      poem.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

Future<List<ListItemPoem>>  getCategories(var db) async {
  String sql = "SELECT distinct category FROM poems ORDER by category";
  print("sql="+sql);

  List<ListItemPoem> result = <ListItemPoem>[];
  var resultSet = await db.rawQuery(sql);
  for (var r in resultSet) {
    //print("I see : "+r['category']);
    ListItemPoem li = ListItemPoem(id: "0", displayText: r['category']);
    result.add(li);
  }
  return result;

}


Future<List<ListItemPoem>>  getTitles(var db) async {
  String sql = "SELECT title, author, id, favorite FROM poems ORDER by authorOrder, titleOrder";
  print("sql="+sql);
  List<ListItemPoem> result = <ListItemPoem>[];
  var resultSet = await db.rawQuery(sql);
  for (var r in resultSet) {
    String title = r['title']+' - '+r['author'];
    ListItemPoem li = ListItemPoem(id: r['id'], displayText: title);
    li.favorite=r['favorite']=='Y';
    result.add(li);
  }
  return result;

}


Future<List<ListItemPoem>> getAuthors(var db) async {
  String sql = "SELECT distinct author FROM poems ORDER by authorOrder ASC";
  print("sql="+sql);
  List<ListItemPoem> result = <ListItemPoem>[];
  var resultSet = await db.rawQuery(sql);
  for (var r in resultSet) {
    //print("I see : "+r['author']);
    ListItemPoem li = ListItemPoem(id: '0', displayText: r['author']);
    result.add(li);

  }
  return result;
}

Future<List<ListItemPoem>> getPoemData(var db, String field, String value) async
{
  String q = "SELECT id,author, title, favorite FROM poems WHERE "+field+" = '"+value+"' ORDER BY authorOrder";
  print("q="+q);
  List<ListItemPoem> result = <ListItemPoem>[];
  var resultSet = await db.rawQuery(q);
  for (var r in resultSet) {
//    print("I see : "+r['author']+" "+r['title']+" favorite: "+r['favorite']);
    String displayText="";
    if (field=="author") displayText=r['title'];
    if (field=="category" || (field=="favorite")) displayText=r['title']+" - "+r['author'];

    ListItemPoem li = ListItemPoem(id: r['id'], displayText: displayText);
    li.favorite=r['favorite']=='Y';
    result.add(li);
  }
  return result;

}

Future<List<ListItemPoem>> getFavoritePoems(var db) async
{
  return getPoemData(db, "favorite", "Y");
}

Future<void> setFavoritePoem(var db, String id, String YN) async
{
 String q = "UPDATE poems set favorite='"+YN+"' where id='"+id+"'";
  print("q="+q);

  await db.rawQuery(q);
}

Future<Poem> getPoemById(var db, String id) async
{
    String q = "SELECT * FROM poems WHERE id='"+id+"'";
    print("q="+q);
    List<Map<String, dynamic>> maps = await db.rawQuery(q);
    int i=0;
    return Poem(
        id: maps[i][COLUMN_ROWID],
        title: maps[i][COLUMN_TITLE],
        author:maps[i][COLUMN_AUTHOR],
        text: maps[i][COLUMN_TEXT],
        category: maps[i][COLUMN_CATEGORY],
        favorite: maps[i][COLUMN_FAVORITE],
        authorOrder: maps[i][COLUMN_AUTHOR_ORDER],
        titleOrder: maps[i][COLUMN_TITLE_ORDER]);
}


  int chars=10;
  String dotdotdot(String sourceText, String textToSearch, int pos) {
    int i=1;
    String leftChunk="";
    String rightChunk="";
    bool dotleft = true;
    bool dotright = true;
    while (i <= chars) {
      int n=pos-i;
      if (n<0) {
        dotleft=false;
        break;
      }

      if (n>=0 && sourceText[n]!='\n') {
        leftChunk = sourceText[n] + leftChunk;
      }
      if (n==0 || sourceText[n]=='\n') {
        dotleft=false;
        break;
      }
      i++;
    }

    pos+=textToSearch.length-1;
    i=1;
    while (i <= chars) {
      int n=pos+i;
      i++;
      if (n<sourceText.length && sourceText[n]!='\n') {
        rightChunk = rightChunk+sourceText[n];
      }
      if (n==sourceText.length || sourceText[n]=='\n') {
        dotright=false;
        break;
      }

    }
    String result="";
    if (dotleft) result = result+"...";
    result+=leftChunk;
    result+=textToSearch;
    result+=rightChunk;
    if (dotright) result = result+"...";
    return result;

  }

  int countOccurrences(String sourceText, String textToSearch, int start) {
    int i=sourceText.indexOf(textToSearch,start);
    if (i<0) return 0;
    return 1+countOccurrences(sourceText, textToSearch, i+textToSearch.length);
  }

  String getSnippet(String sourceText, String textToSearch) {
    int start = 0;
    int j=0;
    String result="";
    do {
      if (start >= sourceText.length) {
        // not found
        break;
      }
      // System.out.println("start: "+start);
      int i = sourceText.indexOf(textToSearch, start);
      if (i < 0) {
        //System.out.println("Did not find "+textToSearch+" beginning at "+start);
        // not found
        break;
      }
      if (i >= start) {
        // normal text before highlight
        String ddd= dotdotdot(sourceText,textToSearch,i);
        //System.out.println(ddd);
        result+=ddd+"\n";
        start =i + textToSearch.length+chars;
      }

      j++;
      //print("...j="+j.toString());

      if (j > 10) {
        //print("breaking!");
        break;
      } // prevent infinite loop
    } while (true);
    return result;
  }

  Future<List<Poem>> searchText(var db, String textToSearch) async {
    print("Trying to get search for text... "+textToSearch);

    String sql = "SELECT id, title,text,author FROM poems WHERE author like '%"+textToSearch+"%'"
    + " or title  like '%"+textToSearch+"%'"
    + " or text like '%"+textToSearch+"%'";
    var result =  await db.rawQuery(sql);
    print("sql="+sql);
    print("result length:"+result.length.toString());

    List<Poem> poems = <Poem>[];
    for (int i=0; i < result.length; i++) {

      //print("i="+i.toString()+" title="+result[i]["title"]);

      String searchTextSnippet="";
      int occurence=0;
      if (result[i]['author'].toString().contains(textToSearch)) {
        searchTextSnippet = getSnippet(result[i]['author'],textToSearch);
        occurence = countOccurrences(result[i]['author'], textToSearch, 0);
      }
      if (result[i]['title'].toString().contains(textToSearch)) {
        searchTextSnippet = getSnippet(result[i]['title'],textToSearch);
        occurence = countOccurrences(result[i]['title'], textToSearch, 0);
      }
      if (result[i]['text'].toString().contains(textToSearch)) {
        searchTextSnippet = getSnippet(result[i]['text'],textToSearch);
        occurence = countOccurrences(result[i]['text'], textToSearch, 0);
      }

      /*
      String searchTextSnippet = getSnippet(result[i]['text'],textToSearch);
      print("searchTextSnippet: "+searchTextSnippet);

      int occurence = countOccurrences(result[i]['text'], textToSearch, 0);
      print("occurance:"+occurence.toString());
      */

      Poem p = Poem(
          id: result[i]['id'],
          title: result[i]['title'],
          text:"",
          searchResult: searchTextSnippet,
          occurence: occurence,
          authorOrder: 0,
          author: '',
          category: '',
          titleOrder: 0,
          favorite: ''

      );
      poems.add(p);
    }
    return poems;

    /*
    return List.generate(result.length, (i)
    {
      print(i);
      String searchTextSnippet = getSnippet(result[i]['text'],textToSearch);
      print("searchTextSnippet: "+searchTextSnippet);

      int occurence = countOccurrences(result[i]['text'], textToSearch, 0);
      print("occurance:"+occurence.toString());

      return Poem(
          id: result[i]['id'],
          title: result[i]['title'],
          text:"",
          searchResult: searchTextSnippet,
          occurence: occurence,
          authorOrder: 0,
          author: '',
          category: '',
          titleOrder: 0,
          favorite: ''
          
      );
    });
    */
  }

}