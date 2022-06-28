import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:package_info/package_info.dart';
import 'package:ppsflutter/AssetsManager.dart';
import 'package:ppsflutter/AudioSettings.dart';
import 'package:ppsflutter/BookmarkScreen.dart';
import 'package:ppsflutter/DatabaseHelper.dart';
import 'package:ppsflutter/DrawerCallBacks.dart';
import 'package:ppsflutter/FreeIntroWebinar.dart';
import 'package:ppsflutter/HomeScreen.dart';
import 'package:ppsflutter/NoteScreen.dart';
import 'package:ppsflutter/SizeConfig.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/databaseModel/Session.dart';
import 'package:ppsflutter/databaseModel/Subsession.dart';
import 'package:ppsflutter/webModel/LoginModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'DocumentsScreen.dart';
import 'Interactive.dart';
import 'PDFFileViewer.dart';
import 'Utils.dart';
import 'login.dart';

double? drawerWidth;

class AppDrawer extends StatefulWidget {
  DrawerCallBacks? drawerCallBacks;

  AppDrawer(this.drawerCallBacks);

  @override
  _AppDrawerState createState() => _AppDrawerState(drawerCallBacks);
}

late SharedPreferences sharedPreferences;
int selectedSessionIndex = 0;
int selectedSubSessionIndex = 0;
List<Session>? sessions;
List<String> sessionTitles = [];
List<String> subSessionTitles = [];
String? tileTitle, expansionTileTitle, subExpansionTitle = '';
bool isStepsEnabled = false;
List<Subsession>? subSessionList = [];
int prevIndex = -1;
int subPrevIndex = -1;
int? stepSesionId;
late PackageInfo packageInfo;

void setInitialValues(String? objectid, String? sessionId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('tileTitle', tileTitle!);
  await prefs.setString('expansionTileTitle',
      expansionTileTitle == null ? '' : expansionTileTitle!);
  await prefs.setString(
      'subExpansionTitle', subExpansionTitle == null ? '' : subExpansionTitle!);
  await prefs.setString('objectid', objectid == null ? '' : objectid);
  await prefs.setString('sessionId', sessionId == null ? '' : sessionId);
  await prefs.setBool("isStepsEnabled", isStepsEnabled);
  print('Values Setted');
}

class _AppDrawerState extends State<AppDrawer> {
  DrawerCallBacks? drawerCallBacks;

  _AppDrawerState(this.drawerCallBacks);

  initialValues() async {
    sharedPreferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    tileTitle = sharedPreferences.getString('tileTitle');
    expansionTileTitle = sharedPreferences.getString('expansionTileTitle');
    subExpansionTitle = sharedPreferences.getString('subExpansionTitle');
  }

  @override
  void initState() {
    super.initState();
    initialValues();
  }

  List<Map<int, bool>> expansionChangedMap = [];
  List<Map<int, bool>> subExpansionChangedMap = [];
  bool _isFirst = true;
  String objectID = "15835";
  int i = -1;
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    drawerWidth = SizeConfig.widthMultiplier * 80.0;
    return SafeArea(
      child: Container(
        width: drawerWidth,
        height: double.infinity,
        child: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 0,
                child: DrawerHeader(
                  padding: EdgeInsets.zero,
                  child: Container(
                    transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(color: Color(0xFF442d53)),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  'Positive Parenting Solutions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConfig.textMultiplier * 1.6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Align(
                                  alignment: Alignment.topCenter,
                                  child: Image.asset(
                                      'assets/images/banner_img.png')),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0.0, left: 16.0),
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Welcome ' + WebHelper.login!.nameF!,
                                          style: TextStyle(
                                              color: Color(0xFF442d53),
                                              fontWeight: FontWeight.bold,
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      2),
                                        )),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(
                                  //       top: 4.0, left: 16.0, bottom: 8.0),
                                  //   child: HtmlWidget(
                                  //     "<p style=font-size: 2vw;>"
                                  //     "<a href='https://www.positiveparentingsolutions.com/amember/profile.php?amember_login=${WebHelper.login!.login}'>Edit Profile</a>"
                                  //     "</p>",
                                  //     hyperlinkColor: Colors.grey,
                                  //     textStyle: TextStyle(
                                  //         fontSize:
                                  //             SizeConfig.textMultiplier * 1.7,
                                  //         color: Colors.grey),
                                  //   ),
                                  // ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Container(
                transform: Matrix4.translationValues(0.0, -27.0, 0.0),
                child: FutureBuilder(
                    future: dbHelper.querySessions(1),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        i = -1;
                        int j = -1;
                        int k = -1;
                        int tileIndex = -1;
                        sessions = snapshot.data as List<Session>;
                        List<Widget> tiles = [];
                        List<Widget> expansionList = [];
                        List<Widget> subTiles = [];
                        List<Widget> subExpansionList = [];

                        sessions!.forEach((items) {
                          tiles.add(createTiles(
                              HtmlUnescape().convert(items.title!),
                              tileIndex += 1));
                        });

                        /*for(int i = 1; i<=sessions!.length; i++){
                            tiles.add(createTiles(HtmlUnescape().convert(sessions![i-1].title!.replaceAll('STEP $i', 'STEP $i of 7')), tileIndex += 1));
                          }*/

                        expansionList.add(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            createExpansionTile(i += 1, tiles, "Steps 1-7")
                          ],
                        ));

                        expansionList.add(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            createSimpleTitle(
                                i += 1, "Parent Personality Assessment")
                          ],
                        ));

                        tiles = [];
                        tileIndex = -1;
                        WebHelper.ultimateSurvival!.items!.forEach((items) {
                          tiles.add(createTiles(
                              HtmlUnescape().convert(items.title!),
                              tileIndex += 1));
                        });
                        expansionList.add(createExpansionTile(
                            i += 1, tiles, WebHelper.ultimateSurvival!.name!));

                        WebHelper.battleTested!.items!.forEach((items) {
                          subTiles = [];
                          k = -1;
                          items.children!.forEach((child) {
                            subTiles.add(createSubTiles(
                                HtmlUnescape().convert(child.title!), k += 1));
                          });

                          subExpansionList.add(createSubExpansionTile(
                              j += 1, subTiles, items.title!));
                        });

                        expansionList.add(createExpansionTile(i += 1,
                            subExpansionList, WebHelper.battleTested!.name!));

                        if (WebHelper.quickStartTutorial != null &&
                            WebHelper.quickStartTutorial!.items!.isNotEmpty) {
                          tiles = [];
                          tileIndex = -1;
                          WebHelper.quickStartTutorial!.items!.forEach((items) {
                            tiles.add(createTiles(
                                HtmlUnescape().convert(items.title!),
                                tileIndex += 1));
                          });
                          expansionList.add(createExpansionTile(i += 1, tiles,
                              WebHelper.quickStartTutorial!.name!));
                        }
                        expansionList.add(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                                transform:
                                    Matrix4.translationValues(0.0, 0.0, 0.0),
                                child: createSimpleTitle(
                                    i += 1, "Free Intro Webinar"))
                          ],
                        ));

                        expansionList.add(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            createSimpleTitle(i += 1, "Backtalk Battles Guide")
                          ],
                        ));

                        if (WebHelper.login!.categories!.userLevel!.keys
                            .contains('6')) {
                          expansionList.add(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              createSimpleTitle(i += 1, "Coaching Support")
                            ],
                          ));
                        } else {
                          createBlankTile(i += 1, "Coaching Support");
                        }

                        if (WebHelper.login!.categories!.userLevel!.keys
                            .contains('1')) {
                          expansionList.add(Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              createSimpleTitle(
                                  i += 1, "Join Gold Facebook Page")
                            ],
                          ));
                        } else {
                          createBlankTile(i += 1, "Gold Facebook Page");
                        }

                        expansionList.add(createSimpleTitle(i += 1, "Notes"));

                        expansionList
                            .add(createSimpleTitle(i += 1, "Bookmarks"));

                        expansionList
                            .add(createSimpleTitle(i += 1, "Documents"));

                        expansionList.add(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            createSimpleTitle(i += 1, "Contact Us")
                          ],
                        ));

                        expansionList
                            .add(createSimpleTitle(i += 1, "Instructions"));

                        if (WebHelper.login!.categories!.userLevel!.keys
                                .contains('2') ||
                            LoginModel.isSubscriptionForAudio) {
                          createBlankTile(i += 1, "Settings");
                        } else {
                          expansionList
                              .add(createSimpleTitle(i += 1, "Settings"));
                        }

                        expansionList.add(createSimpleTitle(i += 1, "Logout"));

                        expansionList.add(Padding(
                          padding:
                              const EdgeInsets.only(top: 16.0, right: 16.0),
                          child: Align(
                            child: Text('v${packageInfo.version}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: SizeConfig.textMultiplier * 1.4)),
                            alignment: Alignment.bottomRight,
                          ),
                        ));

                        return ListView.builder(
                            itemCount: expansionList.length,
                            itemBuilder: (context, index) {
                              return expansionList[index];
                            });
                      } else {
                        return Container();
                      }
                    }),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget createTiles(String title, int index) {
    return Container(
      decoration: BoxDecoration(
        color: tileTitle == title
            ? Utils.getColorFromHex('#e6e6e6')
            : Colors.white,
        border: Border(
          top: BorderSide(color: Utils.getColorFromHex("#f0f0f0")),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          if (drawerCallBacks != null) {
            drawerCallBacks!.onTileTapped(
                sessionTitles, title, sessions, index, selectedSessionIndex);
          } else {
            if (sessionTitles[selectedSessionIndex] ==
                WebHelper.ultimateSurvival!.name) {
              isStepsEnabled = false;
              setInitialValues(
                  WebHelper.ultimateSurvival!.items![index].objectId.toString(),
                  null);
            } else {
              isStepsEnabled = true;
              setInitialValues(null, sessions![index].id.toString());
            }
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          }

          setState(() {
            tileTitle = title;
            subExpansionTitle = '';
            expansionTileTitle = sessionTitles[selectedSessionIndex];
          });
        },
        child: Container(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.widthMultiplier * 7,
                right: SizeConfig.widthMultiplier,
                top: SizeConfig.heightMultiplier,
                bottom: SizeConfig.heightMultiplier),
            child: Text(
              title,
              style: TextStyle(
                  fontFamily: 'OpenSans-Regular',
                  fontWeight: FontWeight.w300,
                  fontSize: SizeConfig.textMultiplier * 1.8,
                  color: Color(0xFF8c8c8c)),
            ),
          ),
        ),
      ),
    );
  }

  Widget createSubTiles(String title, int index) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tileTitle == title
            ? Utils.getColorFromHex('#e6e6e6')
            : Colors.white,
        border: Border(
          top: BorderSide(color: Utils.getColorFromHex("#f0f0f0")),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          String objectid = WebHelper.battleTested!
              .items![selectedSubSessionIndex].children![index].objectId
              .toString();
          isStepsEnabled = false;
          if (drawerCallBacks != null) {
            drawerCallBacks!.onSubTileTapped(sessionTitles, title, sessions,
                index, selectedSessionIndex, selectedSubSessionIndex);
          } else {
            setInitialValues(objectid, null);
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          }

          setState(() {
            tileTitle = title;
            headerTitle = null;
            expansionTileTitle = sessionTitles[selectedSessionIndex];
            subExpansionTitle = subSessionTitles[selectedSubSessionIndex];
          });
        },
        child: Padding(
          padding: EdgeInsets.only(
              left: SizeConfig.widthMultiplier * 9,
              right: SizeConfig.widthMultiplier,
              top: SizeConfig.heightMultiplier,
              bottom: SizeConfig.heightMultiplier),
          child: Text(
            title,
            style: TextStyle(
                fontFamily: 'OpenSans-Regular',
                fontWeight: FontWeight.w300,
                fontSize: SizeConfig.textMultiplier * 1.8,
                color: Color(0xFF8c8c8c)),
          ),
        ),
      ),
    );
  }

  Widget createExpansionTile(int index, List<Widget> tiles, String title) {
    if (_isFirst) {
      expansionChangedMap.add(Map.of({index: false}));
      sessionTitles.add(title);
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: expansionTileTitle == title
            ? Utils.getColorFromHex('#f8f7f7')
            : Colors.white,
        border: Border(
          bottom: BorderSide(color: Utils.getColorFromHex("#f0f0f0")),
        ),
      ),
      child: ConfigurableExpansionTile(
        key: GlobalKey(),
        initiallyExpanded: index == prevIndex,
        header: Container(
          width: drawerWidth,
          child: Container(
            child: Padding(
              padding: EdgeInsets.only(
                  left: SizeConfig.widthMultiplier * 4,
                  right: SizeConfig.widthMultiplier * 2,
                  bottom: SizeConfig.heightMultiplier,
                  top: SizeConfig.heightMultiplier),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.asset(
                          AssetsManager.drawerIconsList[index],
                          width: SizeConfig.widthMultiplier * 5,
                        ),
                      )),
                  Expanded(
                      flex: 2,
                      child: Text(
                        title,
                        style: TextStyle(
                            fontFamily: 'OpenSans-Regular',
                            fontSize: SizeConfig.textMultiplier * 1.8,
                            color: Color(0xFF8c8c8c)),
                      )),
                  Expanded(flex: 0, child: Icon(Icons.keyboard_arrow_right)),
                ],
              ),
            ),
          ),
        ),
        headerExpanded: tiles != null
            ? Container(
                width: drawerWidth,
                child: Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConfig.widthMultiplier * 4,
                        right: SizeConfig.widthMultiplier * 2,
                        bottom: SizeConfig.heightMultiplier,
                        top: SizeConfig.heightMultiplier),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.asset(
                                AssetsManager.drawerIconsList[index],
                                width: SizeConfig.widthMultiplier * 5,
                              ),
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                              title,
                              style: TextStyle(
                                  fontFamily: 'OpenSans-Regular',
                                  fontSize: SizeConfig.textMultiplier * 1.8,
                                  color: Color(0xFF8c8c8c)),
                            )),
                        Expanded(
                            flex: 0, child: Icon(Icons.keyboard_arrow_down)),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        children: tiles != null ? tiles : [Container()],
        onExpansionChanged: (i) {
          if (i) {
            setState(() {
              _isFirst = false;
              expansionChangedMap[index][index] = i;
              prevIndex = index;
              subPrevIndex = -1;
              selectedSessionIndex = index;
            });
          } else {
            setState(() {
              _isFirst = false;
              expansionChangedMap[index][index] = i;
              prevIndex = -1;
              subPrevIndex = -1;
            });
          }
        },
      ),
    );
  }

  Widget createSubExpansionTile(int index, List<Widget> tiles, String title) {
    if (_isFirst) {
      subExpansionChangedMap.add(Map.of({index: false}));
      subSessionTitles.add(title);
    }
    //print('${subExpansionTitle} ::: ${title}');
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: subExpansionTitle == title
            ? Utils.getColorFromHex('#f8f7f7')
            : Colors.white,
        border: Border(
          top: BorderSide(color: Utils.getColorFromHex("#f0f0f0")),
        ),
      ),
      child: ConfigurableExpansionTile(
        key: GlobalKey(),
        initiallyExpanded: index == subPrevIndex,
        header: Container(
          width: drawerWidth,
          child: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.widthMultiplier * 7,
                right: SizeConfig.widthMultiplier,
                top: SizeConfig.heightMultiplier,
                bottom: SizeConfig.heightMultiplier),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      fontFamily: 'OpenSans-Regular',
                      fontSize: SizeConfig.textMultiplier * 1.7,
                      color: Color(0xFF8c8c8c)),
                ),
                Icon(Icons.keyboard_arrow_right)
              ],
            ),
          ),
        ),
        headerExpanded: Container(
          width: drawerWidth,
          child: Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.widthMultiplier * 7,
                right: SizeConfig.widthMultiplier,
                top: SizeConfig.heightMultiplier,
                bottom: SizeConfig.heightMultiplier),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                      fontFamily: 'OpenSans-Regular',
                      fontSize: SizeConfig.textMultiplier * 1.7,
                      color: Color(0xFF8c8c8c)),
                ),
                Icon(Icons.keyboard_arrow_down)
              ],
            ),
          ),
        ),
        children: tiles,
        onExpansionChanged: (i) {
          if (i) {
            setState(() {
              _isFirst = false;
              subExpansionChangedMap[index][index] = i;
              subPrevIndex = index;
              selectedSubSessionIndex = index;
            });
          } else {
            setState(() {
              _isFirst = false;
              subExpansionChangedMap[index][index] = i;
              subPrevIndex = -1;
            });
          }
        },
      ),
    );
  }

  Widget createSimpleTitle(int index, String title) {
    if (_isFirst) {
      expansionChangedMap.add(Map.of({index: false}));
      sessionTitles.add(title);
    }

    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: expansionTileTitle == title
              ? Utils.getColorFromHex('#f8f7f7')
              : Colors.white,
          border: Border(
            bottom: BorderSide(color: Utils.getColorFromHex("#f0f0f0")),
          ),
        ),
        child: ConfigurableExpansionTile(
          key: GlobalKey(),
          initiallyExpanded: index == prevIndex,
          header: Container(
            width: drawerWidth,
            child: Container(
              child: Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.widthMultiplier * 4,
                    right: SizeConfig.widthMultiplier * 2,
                    bottom: SizeConfig.heightMultiplier,
                    top: SizeConfig.heightMultiplier),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.asset(
                            AssetsManager.drawerIconsList[index],
                            fit: BoxFit.fill,
                            width: SizeConfig.widthMultiplier * 5,
                          ),
                        )),
                    Expanded(
                        child: Text(
                      title,
                      style: TextStyle(
                          fontFamily: 'OpenSans-Regular',
                          fontSize: SizeConfig.textMultiplier * 1.8,
                          color: Color(0xFF8c8c8c)),
                    )),
                    Expanded(
                        flex: 0,
                        child: title == 'Parent Personality Assessment'
                            ? Icon(Icons.keyboard_arrow_right)
                            : Container()),
                  ],
                ),
              ),
            ),
          ),
          headerExpanded: Container(
            width: drawerWidth,
            child: Container(
              child: Padding(
                padding: EdgeInsets.only(
                    left: SizeConfig.widthMultiplier * 4,
                    right: SizeConfig.widthMultiplier * 2,
                    bottom: SizeConfig.heightMultiplier,
                    top: SizeConfig.heightMultiplier),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.asset(
                            AssetsManager.drawerIconsList[index],
                            width: SizeConfig.widthMultiplier * 5,
                          ),
                        )),
                    Expanded(
                        flex: 2,
                        child: Text(
                          title,
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.8,
                              color: Color(0xFF8c8c8c)),
                        )),
                    Expanded(
                        flex: 0,
                        child: title == 'Parent Personality Assessment'
                            ? Icon(Icons.keyboard_arrow_right)
                            : Container()),
                  ],
                ),
              ),
            ),
          ),
          onExpansionChanged: (i) {
            print(title + "  " + index.toString());
            /*if (i) {*/
            if (title != 'Contact Us' && title != 'Instructions') {
              //setInitialValues(null, null);
              setState(() {
                _isFirst = false;
                expansionChangedMap[index][index] = i;
                prevIndex = index;
                subPrevIndex = -1;
                selectedSessionIndex = index;
                expansionTileTitle = title;
                tileTitle = "";
                subExpansionTitle = "";
              });
            }
            if (title == 'Logout') {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => Login(null)));
              Utils.isLoginFromSharedPreference = false;
              sharedPreferences.remove('username');
              sharedPreferences.remove('password');
            } else if (title == 'Bookmarks') {
              // Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => BookmarkScreen()));
            } else if (title == 'Documents') {
              // Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DocumentsScreen()));
            } else if (title == 'Free Intro Webinar') {
              // Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => FreeIntroWebinar()));
            } else if (title == 'Notes') {
              // Navigator.of(context).pop();
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => NoteScreen()));
            } else if (title == 'Contact Us') {
              // Navigator.of(context).pop();
              launch('mailto:Help@PositiveParentingSolutions.com');
            } else if (title == 'Instructions') {
              // Navigator.of(context).pop();

              if (drawerCallBacks != null) {
                drawerCallBacks!.onSimpleTileTapped("Instructions");
              } else {
                isAppOpenFirstTime = true;
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
                //drawerCallBacks.onSimpleTileTapped("Instructions");
              }
            } else if (title == 'Parent Personality Assessment') {
              // Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Interactive(1, 1, 'interactive',
                      'TAKE THE PARENT PERSONALITY ASSESSMENT')));
            } else if (title == 'Backtalk Battles Guide') {
              // Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PDFFileViewer('Backtalk Battles Guide',
                      'https://www.positiveparentingsolutions.com/app/content/pdf/backtalk-survival-guide.pdf')));
            } else if (title == 'Join Gold Facebook Page') {
              // Navigator.of(context).pop();
              Utils.showFacebookGoldDialog(context);
              //drawerCallBacks.onSimpleTileTapped("Gold Facebook Page");
            } else if (title == 'Coaching Support') {
              // Navigator.of(context).pop();
              Utils.showCoachingSupportDialog(context);
            } else if (title == 'Settings') {
              // Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AudioSettings()));
            }

            /*} else {
              setState(() {
                _isFirst = false;
                expansionChangedMap[index][index] = i;
                prevIndex = -1;
                subPrevIndex = -1;
              });
            }*/
          },
        ),
      ),
    );
  }

  createBlankTile(int index, String title) {
    if (_isFirst) {
      expansionChangedMap.add(Map.of({index: false}));
      sessionTitles.add(title);
    }
  }
}
