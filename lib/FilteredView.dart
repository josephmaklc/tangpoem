library mylibrary;

import 'package:flutter/material.dart';
import 'package:tangpoem/db/model/ListItemPoem.dart';
import 'package:tangpoem/searchPage.dart';

import 'PoemView.dart';
import 'db/controller/PoemController.dart';

class FilteredView extends StatelessWidget {
  String appTitle;
  String filteredBy;
  String filteredValue;
  double fontSize;

  FilteredView(
      {Key? key, required this.appTitle, required this.filteredBy, required this.filteredValue, required this.fontSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListItemPoem>>(
        future: loadPoemsFiltered(),
        builder: (context, AsyncSnapshot<List<ListItemPoem>> snapshot) {
          if (snapshot.hasData) {
            List<ListItemPoem> listing = snapshot.data as List<ListItemPoem>;
            return FilteredTitleScaffold(context, appTitle+ " - " + filteredValue, listing, fontSize);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }

  Future<List<ListItemPoem>> loadPoemsFiltered() async {
    PoemController c = PoemController();
    final db = await c.initPoemsTable();
    return c.getPoemData(db, filteredBy, filteredValue);
  }

}

Scaffold FilteredTitleScaffold(BuildContext context, String appTitle, List<ListItemPoem> listing, double fontSize) {
  return Scaffold(
      appBar: AppBar(

          title: Text(appTitle),
          actions: [

            IconButton(
                icon: Icon(Icons.search),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SearchPage(fontSize:fontSize))))

          ]
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
              //print("somebody clicked "+listing[index].displayText);

              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PoemView(highlightText:"",id:listing[index].id,fontSize:fontSize)));
            }, // Handle your onTap here.
          );
          return item;
        },
      )


  );
}