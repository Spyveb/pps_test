import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ppsflutter/AppDrawer.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/databaseModel/Bookmark.dart';
import 'package:ppsflutter/databaseModel/BookmarkList.dart';
import 'package:ppsflutter/databaseModel/DrawerMenu.dart';
import 'package:ppsflutter/databaseModel/SpecialityModule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DatabaseHelper.dart';
import 'HomeScreen.dart';
import 'SizeConfig.dart';
import 'Utils.dart';
import 'appThemeData.dart';

class BookmarkScreen extends StatefulWidget {
  @override
  _BookmarkScreenState createState() => _BookmarkScreenState();
}

Future setInitialValues(String? objectid, String? sessionId,
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

class _BookmarkScreenState extends State<BookmarkScreen> {
  List<SpecialityModule> specialityModules = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            'Bookmarks',
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
        future: dbHelper.queryBookmark(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<BookmarkList> bookmarkList =
                snapshot.data as List<BookmarkList>;

            return ListView.separated(
              itemCount: bookmarkList.length,
              itemBuilder: (context, index) {
                print('CONTENT TYPE :: ' +
                    bookmarkList[index].ContentTypeId.toString());
                return bookmarkList[index].ContentTypeId !=
                        DatabaseHelper.contentTypeSteps
                    ? ListTile(
                        title: Text(
                          bookmarkList[index].ContentTypeId ==
                                  DatabaseHelper.contentTypeSpecialityModule
                              ? WebHelper.ultimateSurvival!.name!
                              : WebHelper.battleTested!.name!,
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'AppleGaramondItalic'),
                        ),
                        subtitle: Text(
                          bookmarkList[index].MenuTitle != null
                              ? HtmlUnescape()
                                  .convert(bookmarkList[index].MenuTitle!)
                              : "",
                          style: TextStyle(
                              color: Utils.getColorFromHex(
                                  appThemeData.appBarColor),
                              fontStyle: FontStyle.italic,
                              fontFamily: 'AppleGaramondBold'),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          dbHelper
                              .queryDrawerMenu(
                                  bookmarkList[index].ServerId, null)
                              .then((value) {
                            List<DrawerMenu> menus = value;

                            if (menus.isNotEmpty) {
                              tileTitle = menus[0].tileTitle;
                              expansionTileTitle = menus[0].expansionTileTitle;
                              subExpansionTitle =
                                  menus[0].subExpansionTileTitle;

                              print(
                                  '%%%%%%%%%%%%%%%%${tileTitle}  ${expansionTileTitle}  ${subExpansionTitle}');

                              setInitialValues(
                                      bookmarkList[index].ServerId.toString(),
                                      null,
                                      null,
                                      false)
                                  .then((value) => Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => HomeScreen())));
                            }
                          });
                        },
                      )
                    : ListTile(
                        title: Text(
                          bookmarkList[index].Title != null
                              ? bookmarkList[index].Title!
                              : "",
                          style: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'AppleGaramondItalic'),
                        ),
                        subtitle: Text(
                          HtmlUnescape().convert(bookmarkList[index].Subtitle!),
                          style: TextStyle(
                              color: Utils.getColorFromHex(
                                  appThemeData.appBarColor),
                              fontStyle: FontStyle.italic,
                              fontFamily: 'AppleGaramondBold'),
                        ),
                        trailing: Icon(Icons.keyboard_arrow_right),
                        onTap: () {
                          dbHelper
                              .queryDrawerMenu(bookmarkList[index].SessionId,
                                  bookmarkList[index].SubsessionId)
                              .then((value) {
                            List<DrawerMenu> menus = value;

                            if (menus.isNotEmpty) {
                              print(menus[0].expansionTileTitle);
                              tileTitle = menus[0].tileTitle;
                              expansionTileTitle = menus[0].expansionTileTitle;
                              subExpansionTitle =
                                  menus[0].subExpansionTileTitle;
                              print(
                                  '%%%%%%%%%%%%%%%%${tileTitle}  ${expansionTileTitle}  ${subExpansionTitle}');

                              setInitialValues(
                                      null,
                                      bookmarkList[index].SessionId.toString(),
                                      bookmarkList[index]
                                          .SubsessionId
                                          .toString(),
                                      true)
                                  .then((value) => Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                          builder: (context) => HomeScreen())));
                              print("PUSH");
                            }
                          });
                        },
                      );
              },
              separatorBuilder: (context, index) {
                return Divider();
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
}
