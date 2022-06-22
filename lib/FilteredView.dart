library mylibrary;

import 'package:flutter/material.dart';
import 'package:tangpoem/db/model/ListItemPoem.dart';
import 'package:tangpoem/searchPage.dart';

import 'PoemView.dart';
import 'db/controller/PoemController.dart';

class FilteredView extends StatefulWidget {

  String appTitle;
  String filteredBy;
  String filteredValue;
  double fontSize;
  List<ListItemPoem> listing = [];
  FilteredView({Key? key, required this.appTitle, required this.filteredBy, required this.filteredValue,required this.fontSize}) : super(key: key);

  @override
  FilteredViewState createState() => FilteredViewState();
}

class FilteredViewState extends State<FilteredView> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListItemPoem>>(
        future: loadPoemsFiltered(),
        builder: (context, AsyncSnapshot<List<ListItemPoem>> snapshot) {
          if (snapshot.hasData) {
            widget.listing = snapshot.data as List<ListItemPoem>;
            return FilteredTitleScaffold(context, widget.appTitle+ " - " + widget.filteredValue, widget.listing, widget.fontSize);
          } else {
            return const CircularProgressIndicator();
          }
        }
    );
  }

  Future<List<ListItemPoem>> loadPoemsFiltered() async {
    print("loadPoemsFiltered");
    PoemController c = PoemController();
    final db = await c.initPoemsTable();
    return c.getPoemData(db, widget.filteredBy, widget.filteredValue);
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

                trailing: IconButton(
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
}

