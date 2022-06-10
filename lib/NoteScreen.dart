import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/databaseModel/NoteList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AppDrawer.dart';
import 'DatabaseHelper.dart';
import 'HomeScreen.dart';
import 'SizeConfig.dart';
import 'Utils.dart';
import 'appThemeData.dart';
import 'databaseModel/DrawerMenu.dart';
import 'databaseModel/SpecialityModule.dart';

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

Future setInitialValues(String objectid, String? sessionId,
    String? subSessionId, bool isStepsEnabled) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('tileTitle', tileTitle!);
  await prefs.setString('expansionTileTitle',
      expansionTileTitle == null ? '' : expansionTileTitle!);
  await prefs.setString(
      'subExpansionTitle', subExpansionTitle == null ? '' : subExpansionTitle!);
  await prefs.setString('objectid', objectid == null ? '' : objectid);
  await prefs.setString('sessionId', sessionId == null ? '' : sessionId);
  await prefs.setString(
      'subSessionId', subSessionId == null ? '' : subSessionId);
  await prefs.setBool("isStepsEnabled", isStepsEnabled);
  print('Values Setted');
}

class _NoteScreenState extends State<NoteScreen> {
  final dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    dbHelper.queryNotes(null, null).then((value) {
      print(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            'Notes',
            style: TextStyle(
                fontSize: SizeConfig.isMobilePortrait
                    ? SizeConfig.textMultiplier * 2.2
                    : SizeConfig.textMultiplier * 1.5),
          ),
        ),
        titleSpacing: 0.0,
        backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
      ),
      drawer: AppDrawer(null),
      body: FutureBuilder(
        future: dbHelper.queryNotes(null, null),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<NoteList> noteList = snapshot.data as List<NoteList>;
            return ListView.separated(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                print(noteList[index].SubTitle);
                return noteList[index].ContentType ==
                            DatabaseHelper.contentTypeSpecialityModule ||
                        noteList[index].ContentType ==
                            DatabaseHelper.contentTypeExpertSeries
                    ? Container(
                        padding: EdgeInsets.only(bottom: 8.0),
                        decoration:
                            BoxDecoration(color: Colors.grey.withOpacity(0.1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                noteList[index].ContentType ==
                                        DatabaseHelper
                                            .contentTypeSpecialityModule
                                    ? WebHelper.ultimateSurvival!.name!
                                    : WebHelper.battleTested!.name!,
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'AppleGaramondBold'),
                              ),
                              subtitle: Text(
                                noteList[index].MenuTitle != null
                                    ? HtmlUnescape()
                                        .convert(noteList[index].MenuTitle!)
                                    : "",
                                style: TextStyle(
                                    color: Utils.getColorFromHex(
                                        appThemeData.appBarColor),
                                    fontFamily: 'AppleGaramondItalic'),
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onTap: () {
                                print('ID :::: ' +
                                    noteList[index].ServerId.toString());
                                dbHelper
                                    .queryDrawerMenu(
                                        noteList[index].ServerId, null)
                                    .then((value) {
                                  List<DrawerMenu> menus = value;

                                  if (menus.isNotEmpty) {
                                    tileTitle = menus[0].tileTitle;
                                    expansionTileTitle =
                                        menus[0].expansionTileTitle;
                                    subExpansionTitle =
                                        menus[0].subExpansionTileTitle;

                                    setInitialValues(
                                            noteList[index]
                                                .SubsessionId
                                                .toString(),
                                            null,
                                            null,
                                            false)
                                        .then((value) => Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen())));
                                  }
                                });
                              },
                              onLongPress: () =>
                                  _deleteNoteDialog(context, noteList, index),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: InkWell(
                                onLongPress: () =>
                                    _deleteNoteDialog(context, noteList, index),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black12.withOpacity(0.05),
                                    border: Border.all(color: Colors.black54),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Text(
                                    noteList[index].Note!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'OpenSans-Regular'),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(bottom: 8.0),
                        decoration:
                            BoxDecoration(color: Colors.grey.withOpacity(0.1)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              title: Text(
                                noteList[index].SubTitle != null
                                    ? HtmlUnescape()
                                        .convert(noteList[index].SubTitle!)
                                    : "",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic,
                                    fontFamily: 'AppleGaramondBold'),
                              ),
                              subtitle: Text(
                                noteList[index].Title != null
                                    ? HtmlUnescape()
                                        .convert(noteList[index].Title!)
                                    : "",
                                style: TextStyle(
                                    color: Utils.getColorFromHex(
                                        appThemeData.appBarColor),
                                    fontFamily: 'AppleGaramondItalic'),
                              ),
                              trailing: Icon(Icons.keyboard_arrow_right),
                              onLongPress: () =>
                                  _deleteNoteDialog(context, noteList, index),
                              onTap: () {
                                dbHelper
                                    .queryDrawerMenu(noteList[index].SessionId,
                                        noteList[index].SubsessionId)
                                    .then((value) {
                                  List<DrawerMenu> menus = value;
                                  if (menus.isNotEmpty) {
                                    tileTitle = menus[0].tileTitle;
                                    expansionTileTitle =
                                        menus[0].expansionTileTitle;
                                    subExpansionTitle =
                                        menus[0].subExpansionTileTitle;

                                    setInitialValues(
                                            '',
                                            noteList[index]
                                                .SessionId
                                                .toString(),
                                            noteList[index]
                                                .SubsessionId
                                                .toString(),
                                            true)
                                        .then((value) => Navigator.of(context)
                                            .pushReplacement(MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen())));
                                  }
                                });
                              },
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: InkWell(
                                onLongPress: () =>
                                    _deleteNoteDialog(context, noteList, index),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.black12.withOpacity(0.05),
                                    border: Border.all(color: Colors.black54),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                  ),
                                  child: Text(
                                    noteList[index].Note!,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontFamily: 'OpenSans-Regular'),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  height: double.minPositive,
                  color: Colors.black26,
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _deleteNoteDialog(context, List<NoteList> notes, int index) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete Note"),
              content: Text('Are you sure you want to delete this note?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    return Navigator.of(context).pop(false);
                  },
                  child: Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    dbHelper.querySelectTables();
                    WebHelper.postDeleteNote(
                        context, notes[index].SubsessionId);
                    dbHelper.deleteNotes(
                        notes[index].SubsessionId!, notes[index].ContentType!);
                    Navigator.of(context).pop(false);
                    setState(() {
                      notes.remove(index);
                    });
                  },
                  child: Text(
                    'YES',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ));
  }
}
