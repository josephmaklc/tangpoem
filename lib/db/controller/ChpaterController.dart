import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/Chapter.dart';

class ChapterController {


  Future<Database> initChaptersTable() async {
//    print("init chapters table");
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();

    //print("dbPath: " + await getDatabasesPath());
    // Open the database and store the reference.
    var database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'chapter_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        print("on create...");
        return db.execute(
          'CREATE TABLE chapter(id INTEGER, title TEXT, text TEXT, language TEXT) ',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
  }

  Future<void> clearChapterTable(var db) async {
    print("clear chapters table");
    try {
      db.execute("DROP TABLE chapter");
      db.execute(
          'CREATE TABLE chapter(id INTEGER, title TEXT, text TEXT, language TEXT) ');
    } catch (e) {
      print(e.toString());
    }
  }

  // Define a function that insert chapter into the database
  Future<void> insertChapter(var db,Chapter chapter) async {

    //print("inserting chapter: "+chapter.toString());
    await db.insert(
      'chapter',
      chapter.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getAllChaptersForLanguage(var db, String language) async {
    // Get a reference to the database.

    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM chapter WHERE language=?",[language]);

    List<Chapter> chapters = List.generate(maps.length, (i) {
      return Chapter(
          id: maps[i]['id'],
          title: maps[i]['title'],
          text: maps[i]['text'],
          language: maps[i]['language']
      );
    });

    List<String> result = <String>[];
    for(Chapter c in chapters) {
      result.add(c.title);
    }
    return result;
  }

  // A method that retrieves all chapters
  Future<List<Chapter>> getAllChapters(var db) async {
    // Get a reference to the database.

    final List<Map<String, dynamic>> maps = await db.query('chapter');

    return List.generate(maps.length, (i) {
      return Chapter(
          id: maps[i]['id'],
          title: maps[i]['title'],
          text: maps[i]['text'],
          language: maps[i]['language']
      );
    });
  }

  Future<Chapter> getChapter(var db, int i, String language) async {
    //print("Trying to get chapter... "+i.toString()+" language="+language);
    try {
      List<Map> result = await db.rawQuery("SELECT * FROM chapter WHERE id=? AND language=?",[i,language]);

      return Chapter(
          id: result[0]['id'],
          title: result[0]['title'],
          text: result[0]['text']+"\n\n",
          language: result[0]['language']
      ); }
    catch (e) {
      print ("Error getChapter: "+e.toString());
      return Chapter(id:i,title:'bad',text:'badbad',language:'English');
    }
  }

  Future<void> updateChapter(var db,Chapter chapter) async {
    // Get a reference to the database.

    // Update the given Dog.
    await db.update(
      'chapter',
      chapter.toMap(),
      // Ensure that the Dog has a matching id.
      where: 'id = ?',
      whereArgs: [chapter.id],
    );
  }

  Future<void> deleteChapter(var db,int id) async {
    // Get a reference to the database.

    // Remove the Dog from the database.
    await db.delete(
      'chapter',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      whereArgs: [id],
    );
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
    String result="";
    do {
      // System.out.println("start: "+start);
      int i = sourceText.indexOf(textToSearch, start);
      if (i < 0) {
        //System.out.println("Did not find "+textToSearch+" beginning at "+start);
        // not found
        break;
      }
      if (i > start) {
        // normal text before highlight
        String ddd= dotdotdot(sourceText,textToSearch,i);
        //System.out.println(ddd);
        result+=ddd+"\n";
        start =i + textToSearch.length+chars;
      }
    } while (true);
    return result;
  }

  Future<List<Chapter>> searchText(var db, String textToSearch, String language) async {
    print("Trying to get search for text... "+textToSearch+" language="+language);

    var result =  await db.rawQuery("SELECT distinct id, title,text,language FROM chapter WHERE text like '%$textToSearch%' AND language=? order by id",[language]);


    return List.generate(result.length, (i)
    {
      String searchTextSnippet = getSnippet(result[i]['text'],textToSearch);
      int occurence = countOccurrences(result[i]['text'], textToSearch, 0);
      return Chapter(
          id: result[i]['id'],
          title: result[i]['title'],
          text:"",
          searchResult: searchTextSnippet,
          occurence: occurence,
          language: result[i]['language']
      );
    });
  }

}