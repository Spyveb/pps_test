import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info/package_info.dart';
import 'package:ppsflutter/AppDrawer.dart';
import 'package:ppsflutter/DatabaseHelper.dart';
import 'package:ppsflutter/DrawerCallBacks.dart';
import 'package:ppsflutter/Interactive.dart';
import 'package:ppsflutter/PDFTextContent.dart';
import 'package:ppsflutter/PlayAudio.dart';
import 'package:ppsflutter/PlayVideo.dart';
import 'package:ppsflutter/SizeConfig.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:ppsflutter/color_utils.dart';
import 'package:ppsflutter/databaseModel/NoteList.dart';
import 'package:ppsflutter/databaseModel/Notes.dart';
import 'package:ppsflutter/progress.dart';
import 'package:ppsflutter/store_content_offline.dart';
import 'package:ppsflutter/webModel/LoginModel.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:rect_getter/rect_getter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart' as video_player;

import 'AppDrawer.dart';
import 'FileOperationCallBacks.dart';
import 'PDFFileViewer.dart';
import 'Utils.dart';
import 'databaseModel/Bookmark.dart';
import 'databaseModel/Course.dart';
import 'databaseModel/Subsession.dart';

double? drawerWidth;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

void loadPreference() async {
  sharedPreferences = await SharedPreferences.getInstance();
}

void setInitialValues(
    String? objectid, String? sessionId, String? subSessionId) async {
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
  await prefs.setBool("isStepsEnabled", isStepsEnabled!);
  print('Values Setted');
}

late SharedPreferences sharedPreferences;
String? webUrl = "https://www.google.com/";
String? imageURL = "";
String? appMp3 = "";
String? appVideo = "";
String? appHelpfulresources = "";
String? appNoteTakingGuide = "";
bool? isStepsEnabled = false;
bool _isBookmarked = false;
bool isAppOpenFirstTime = true;
String? headerTitle;
String? headerSubTitle;
Rect? bookmarkButtonRect;
Rect? bookmarkRect;
Rect? floatButtonRect;
Rect? drawerIconRect;
bool _isLastPage = false;
int? currentSubSessionIndex = 0;
PreloadPageController? _pageController;
int pageViewPrevIndex = 0;

class _HomeScreenState extends State<HomeScreen>
    implements DrawerCallBacks, FileOperationCallBacks {
  bool _isLoading = true;
  int i = -1;
  final dbHelper = DatabaseHelper.instance;
  ScrollController? _listViewScrollController;
  dynamic prevScrollPosition = 0;

  final InAppReview inAppReview = InAppReview.instance;
  List<video_player.VideoPlayerController> _controllerList = [];
  var bookmarkButtonKey = RectGetter.createGlobalKey();
  var bookmarkKey = RectGetter.createGlobalKey();
  var floatingButtonKey = RectGetter.createGlobalKey();
  var drawerIconKey = RectGetter.createGlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  ValueNotifier pageValue = ValueNotifier(0);

  Future<Null> runInitialProcess() async {
    if (sharedPreferences.getBool('_isAudioPlayContinuously') == null) {
      sharedPreferences.setBool('_isAudioPlayContinuously', true);
    }

    if (sharedPreferences.getBool('_isPopupOptionEnabled') == null) {
      sharedPreferences.setBool('_isPopupOptionEnabled', true);
    }

    if (sharedPreferences.getBool('offlineOption') == null) {
      sharedPreferences.setBool('offlineOption', true);
    }

    tileTitle = sharedPreferences.getString('tileTitle');
    expansionTileTitle = sharedPreferences.getString('expansionTileTitle');
    subExpansionTitle = sharedPreferences.getString('subExpansionTitle');
    isStepsEnabled = sharedPreferences.getBool('isStepsEnabled') == null
        ? false
        : sharedPreferences.getBool('isStepsEnabled');

    if (sharedPreferences.getString('objectid') != null &&
        sharedPreferences.getString('objectid') != '') {
      sharedPreferences.setBool('isAppOpenFirstTime', false);
      dbHelper
          .queryBookmarkById(
              int.parse(sharedPreferences.getString('objectid')!), 0)
          .then((value) {
        if (value.isNotEmpty) {
          _isBookmarked = true;
        } else {
          _isBookmarked = false;
        }

        WebHelper.fetchSpecialityModule(
                sharedPreferences.getString('objectid')!)
            .then((onValue) {
          setState(() {
            subSessionList = null;
            imageURL = onValue!.acf!.appImage!.url;
            webUrl = onValue.acf!.appContent;
            headerTitle = null;
            headerSubTitle = onValue.title!.rendered;
            appMp3 = onValue.acf!.appMp3;
            appVideo = onValue.acf!.appVideo;
            appNoteTakingGuide = onValue.acf!.appNoteTakingGuide;
            appHelpfulresources = onValue.acf!.appHelpfulResources;
            _isLoading = false;
          });
        });
      });
    } else {
      if ((sharedPreferences.getString('sessionId') != null &&
              sharedPreferences.getString('sessionId') != '') ||
          Utils.isLoginFromSharedPreference) {
        sharedPreferences.setBool('isAppOpenFirstTime', false);
        print("Pages : 0  " + sharedPreferences.getInt("pageIndex").toString());
        isStepsEnabled = true;
        if ((sharedPreferences.getString('sessionId') == null ||
                sharedPreferences.getString('sessionId') == '') &&
            Utils.isLoginFromSharedPreference) {
          currentSubSessionIndex = 0;
          sharedPreferences.setString('sessionId', '2');
          sharedPreferences.setString('subSessionId', '2');
        } else {
          currentSubSessionIndex =
              int.parse(sharedPreferences.getString('sessionId')!) - 2;
        }

        dbHelper.querySessions(1).then((value) {
          sessions = value;
        });

        dbHelper
            .querySubSessions(
                int.parse(sharedPreferences.getString('sessionId')!), null)
            .then((onValue) {
          for (int i = 0; i < onValue.length; i++) {
            if (dbHelper.stepsSessionId == onValue[i].id ||
                headerSubTitle == onValue[i].subtitle) {
              dbHelper
                  .queryBookmarkById(
                      int.parse(sharedPreferences.getString('sessionId')!),
                      onValue[i].id)
                  .then((value) {
                if (value.isNotEmpty) {
                  _isBookmarked = true;
                } else {
                  _isBookmarked = false;
                }
              });

              break;
            }
          }

          dbHelper.querySessionById(onValue[0].sessionId).then((value) {
            expansionTileTitle = value[0].title;

            setState(() {
              subSessionList = onValue;
              _isLoading = false;
              _isLastPage = false;
              appMp3 = null;
              appVideo = null;
              appNoteTakingGuide = null;
              appHelpfulresources = null;
              headerSubTitle = onValue[0].subtitle;
              headerTitle = expansionTileTitle;
            });

            WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
              int id = int.parse(sharedPreferences.getString('subSessionId')!);

              for (int i = 0; i < onValue.length; i++) {
                if (onValue[i].id == id) {
                  imageURL = onValue[i].imageUrl;
                  _pageController!.jumpToPage(i);
                  break;
                }
              }
            });
          });
        });
        //});
      } else {
        print('First Time');
        setState(() {
          isStepsEnabled = true;
          _isLoading = false;
          expansionTileTitle = "Start Course";
        });
      }
    }
  }

  Future<Null> _refreshModule() async {
    var value = await dbHelper.queryBookmarkById(
        int.parse(sharedPreferences.getString('objectid')!), 0);

    if (value.isNotEmpty) {
      _isBookmarked = true;
    } else {
      _isBookmarked = false;
    }

    var onValue = await WebHelper.fetchSpecialityModule(
        sharedPreferences.getString('objectid')!);

    setState(() {
      subSessionList = null;
      imageURL = onValue!.acf!.appImage!.url;
      webUrl = onValue.acf!.appContent;
      headerTitle = null;
      headerSubTitle = onValue.title!.rendered;
      appMp3 = onValue.acf!.appMp3;
      appVideo = onValue.acf!.appVideo;
      appNoteTakingGuide = onValue.acf!.appNoteTakingGuide;
      appHelpfulresources = onValue.acf!.appHelpfulResources;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    Utils.setFileOperationCallBacks(this);
    _isLoading = true;
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
      runInitialProcess();

      if ((sharedPreferences.containsKey('neverAsk') &&
              !sharedPreferences.getBool('neverAsk')!) ||
          !sharedPreferences.containsKey('neverAsk')) {
        if (sharedPreferences.containsKey('cacheValidTill')) {
          int days = DateTime.now()
              .difference(DateTime.parse(
                  sharedPreferences.getString('cacheValidTill')!))
              .inDays;
          if (days >= 29) {
            DefaultCacheManager().emptyCache();
          }
        } else {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            showOfflineContentDialog();
          });
        }
      }
    });
  }

  void showOfflineContentDialog() {
    final neverAskNotifier = ValueNotifier<bool>(false);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Offline Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Do you want to enable offline access?'),
              ValueListenableBuilder(
                valueListenable: neverAskNotifier,
                builder: (context, dynamic value, child) {
                  sharedPreferences.setBool('neverAsk', value);
                  return Row(
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        alignment: Alignment.centerRight,
                        child: Checkbox(
                          value: value,
                          visualDensity: VisualDensity.compact,
                          onChanged: (value) {
                            neverAskNotifier.value = value!;
                          },
                        ),
                      ),
                      Text('Never ask again'),
                    ],
                  );
                },
              )
            ],
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No')),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(StoreContentOffline.route())
                      .then((value) {
                    if (value != null && value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Content successfully stored.'),
                        duration: Duration(seconds: 2),
                      ));
                      sharedPreferences.setString(
                          'cacheValidTill', DateTime.now().toString());
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Check you internet connection and try again'),
                        duration: Duration(seconds: 3),
                      ));
                    }
                  });
                },
                child: Text('Yes'))
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    print('onDispose');
  }

  @override
  void deactivate() {
    super.deactivate();
    print('deactivate');
  }

  nextStep() {
    currentSubSessionIndex = currentSubSessionIndex! + 1;
    dbHelper
        .querySubSessions(sessions![currentSubSessionIndex!].id, null)
        .then((onValue) {
      dbHelper
          .queryBookmarkById(0, sessions![currentSubSessionIndex!].id)
          .then((value) {
        if (value.isNotEmpty) {
          _isBookmarked = true;
        } else {
          _isBookmarked = false;
        }

        dbHelper.insertDrawerMenuItem(
            sessions![currentSubSessionIndex!].id,
            onValue[0].id,
            "Steps 1-7",
            sessions![currentSubSessionIndex!].title,
            null);
        setState(() {
          isStepsEnabled = true;
          _isLoading = false;
          subSessionList = onValue;
          headerSubTitle = onValue[0].subtitle;
          tileTitle = sessions![currentSubSessionIndex!].title;
          headerTitle = tileTitle;
          setInitialValues(
              null, sessions![currentSubSessionIndex!].id.toString(), null);
          appMp3 = null;
          appVideo = null;
          appNoteTakingGuide = null;
          appHelpfulresources = null;
          setInitialValues(
              null, sessions![currentSubSessionIndex!].id.toString(), null);
          if (_pageController!.hasClients) _pageController!.jumpTo(0.0);
        });
      });
    });
  }

  Future<bool> _onWillPop() async {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      return (Platform.isAndroid)
          ? (await (showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("You're about to exit the application"),
                  content: Text('Are you sure?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        }
                      },
                      child: Text(
                        'YES',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ) as FutureOr<bool>?)) ??
              false
          : false;
    } else {
      _scaffoldKey.currentState!.openDrawer();
      return Future.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height;
    final appDrawer = AppDrawer(this);
    drawerWidth = SizeConfig.widthMultiplier * 60.0;
    _pageController = PreloadPageController(initialPage: 0, keepPage: true);
    _listViewScrollController = ScrollController();

    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if ((bookmarkButtonRect == null ||
              floatButtonRect == null ||
              drawerIconRect == null) &&
          isAppOpenFirstTime) {
        setState(() {
          bookmarkButtonRect = RectGetter.getRectFromKey(bookmarkButtonKey);
          floatButtonRect = RectGetter.getRectFromKey(floatingButtonKey);
          drawerIconRect = RectGetter.getRectFromKey(drawerIconKey);
          bookmarkRect = RectGetter.getRectFromKey(bookmarkKey);
        });
      }

      SharedPreferences.getInstance().then((value) {
        sharedPreferences = value;
        checkForUpdate();
        checkAppReview();
      });
    });

    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeConfig().init(constraints, orientation);
        height = SizeConfig.heightMultiplier * 12;

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Stack(
            children: <Widget>[
              Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    elevation: 10.0,
                    leading: isAppOpenFirstTime
                        ? Icon(
                            Icons.menu,
                            key: drawerIconKey,
                          )
                        : null,
                    title: FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        appThemeData.appName.replaceAll('The ', ''),
                        style: TextStyle(
                            fontSize: SizeConfig.isMobilePortrait
                                ? SizeConfig.textMultiplier * 1.6
                                : SizeConfig.textMultiplier * 1.5),
                      ),
                    ),
                    titleSpacing: 0.0,
                    backgroundColor:
                        Utils.getColorFromHex(appThemeData.appBarColor),
                    bottom: PreferredSize(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            height: height,
                            child: Image.asset(
                              app_images.SPLASH_IMAGE,
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: SizeConfig.widthMultiplier * 3,
                                    right: SizeConfig.widthMultiplier * 1.5,
                                  ),
                                  child: _isLoading
                                      ? Container()
                                      : Container(
                                          height: height,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                headerTitle != null ||
                                                        isAppOpenFirstTime
                                                    ? Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 8.0),
                                                        child: Text(
                                                          !isAppOpenFirstTime
                                                              ? HtmlUnescape()
                                                                  .convert(
                                                                      headerTitle!)
                                                              : 'Steps 1-7',
                                                          maxLines: 3,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  height / 5.8,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              fontFamily:
                                                                  'AppleGaramondItalic'),
                                                        ),
                                                      )
                                                    : Container(),
                                                headerSubTitle != null
                                                    ? Padding(
                                                        padding: EdgeInsets.only(
                                                            top: headerTitle !=
                                                                    null
                                                                ? 0.0
                                                                : 4.0),
                                                        child: Text(
                                                          (headerSubTitle == 'Parent Personality Assessment' &&
                                                                      LoginModel
                                                                          .isBonus) ||
                                                                  (headerSubTitle ==
                                                                          'Your Parenting Style and Why It Matters' &&
                                                                      LoginModel
                                                                          .isBonus)
                                                              ? 'BONUS: ' +
                                                                  HtmlUnescape()
                                                                      .convert(
                                                                          headerSubTitle!)
                                                              : HtmlUnescape()
                                                                  .convert(
                                                                      headerSubTitle!),
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  headerTitle !=
                                                                          null
                                                                      ? height /
                                                                          5.3
                                                                      : height /
                                                                          4.5,
                                                              fontFamily:
                                                                  'AppleGaramondBold'),
                                                        ),
                                                      )
                                                    : Container()
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                  flex: 0,
                                  child: !_isLoading || isAppOpenFirstTime
                                      ? Container(
                                          transform: Matrix4.translationValues(
                                              0.0, -5.0, 0.0),
                                          key: bookmarkButtonKey,
                                          child: IconButton(
                                              key: bookmarkKey,
                                              icon: Image.asset(
                                                _isBookmarked
                                                    ? 'assets/images/ic_bookmark_white_24dp.png'
                                                    : 'assets/images/ic_bookmark_border_white_24dp.png',
                                                scale: 3.2,
                                              ),
                                              onPressed: () async {
                                                int? objectId,
                                                    sessionId,
                                                    subsessionId,
                                                    contentType;

                                                objectId = sharedPreferences
                                                                .getString(
                                                                    'objectid') !=
                                                            null &&
                                                        sharedPreferences
                                                                .getString(
                                                                    'objectid') !=
                                                            ''
                                                    ? int.parse(
                                                        sharedPreferences
                                                            .getString(
                                                                'objectid')!)
                                                    : null;

                                                sessionId = sharedPreferences
                                                                .getString(
                                                                    'sessionId') !=
                                                            null &&
                                                        sharedPreferences
                                                                .getString(
                                                                    'sessionId') !=
                                                            ''
                                                    ? int.parse(
                                                        sharedPreferences
                                                            .getString(
                                                                'sessionId')!)
                                                    : null;

                                                subsessionId =
                                                    subSessionList != null
                                                        ? subSessionList![
                                                                pageValue.value]
                                                            .id
                                                        : null;

                                                contentType = subSessionList !=
                                                        null
                                                    ? DatabaseHelper
                                                        .contentTypeSteps
                                                    : (subExpansionTitle ==
                                                                    null ||
                                                                subExpansionTitle ==
                                                                    '') &&
                                                            sharedPreferences
                                                                    .getString(
                                                                        'objectid') !=
                                                                null &&
                                                            sharedPreferences
                                                                    .getString(
                                                                        'objectid') !=
                                                                ''
                                                        ? DatabaseHelper
                                                            .contentTypeSpecialityModule
                                                        : DatabaseHelper
                                                            .contentTypeExpertSeries;

                                                if (_isBookmarked) {
                                                  WebHelper.postDeleteBookmark(
                                                      context,
                                                      subsessionId ?? objectId);
                                                  dbHelper
                                                      .deleteBookmark(
                                                          objectId,
                                                          sessionId,
                                                          subsessionId)
                                                      .then((value) {
                                                    setState(() {
                                                      _isBookmarked = false;
                                                    });
                                                  });
                                                } else {
                                                  WebHelper.postAddBookmark(
                                                    context,
                                                    [
                                                      Bookmark(
                                                          sessionId,
                                                          subsessionId,
                                                          contentType,
                                                          objectId ?? -1)
                                                    ],
                                                  );
                                                  dbHelper
                                                      .insertBookmark(
                                                          objectId,
                                                          sessionId,
                                                          subsessionId,
                                                          contentType)
                                                      .then((value) {
                                                    setState(() {
                                                      _isBookmarked = true;
                                                    });
                                                  });
                                                }
                                              }))
                                      : Container())
                            ],
                          ),
                        ],
                      ),
                      preferredSize: Size(double.infinity, height),
                    ),
                    actions: <Widget>[
                      Image.asset(
                        app_images.LOGO_ICON,
                        scale: 3,
                      ),
                    ],
                  ),
                  drawer: appDrawer,
                  body: SafeArea(
                    child: isStepsEnabled!
                        ? !_isLoading
                            ? Column(
                                children: [
                                  Expanded(child: stepsWidget()),
                                  Expanded(
                                      flex: 0,
                                      child: _isLastPage &&
                                              tileTitle != null &&
                                              !tileTitle!.startsWith('STEP 7')
                                          ? TextButton(
                                              style: TextButton.styleFrom(
                                                  backgroundColor:
                                                      Color(0xFFED4F38),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.zero),
                                                  minimumSize: Size(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      48.0)),
                                              onPressed: () {
                                                nextStep();
                                              },
                                              child: Text(
                                                'GO TO STEP ${int.parse(headerTitle!.split(' ')[1]) + 1}',
                                                style: TextStyle(
                                                    color: Color(0xFFFFFFFF),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: SizeConfig
                                                            .textMultiplier *
                                                        2),
                                              ),
                                            )
                                          : Container())
                                ],
                              )
                            : Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                ))
                        : RefreshIndicator(
                            onRefresh: _refreshModule,
                            child: Stack(
                              children: <Widget>[
                                ListView(
                                  children: <Widget>[
                                    Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 8.0,
                                            top: 8.0,
                                            bottom: 8.0),
                                        child: imageURL != null &&
                                                imageURL != ''
                                            ? Container(
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.2),
                                                      spreadRadius: 5,
                                                      blurRadius: 7,
                                                      offset: Offset(0,
                                                          1), // changes position of shadow
                                                    ),
                                                  ],
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: imageURL!,
                                                  httpHeaders: {
                                                    'User-Agent': 'Mozilla/5.0'
                                                  },
                                                  fit: BoxFit.contain,
                                                  progressIndicatorBuilder:
                                                      (context, url, progress) {
                                                    return Container(
                                                      width: SizeConfig
                                                              .widthMultiplier *
                                                          30,
                                                      height: SizeConfig
                                                              .heightMultiplier *
                                                          30,
                                                      child: Center(
                                                        child: SizedBox(
                                                          width: 40.0,
                                                          height: 40.0,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth: 1.0,
                                                              value: progress
                                                                  .progress,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : Container()),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          top: 8.0,
                                          bottom: 24.0),
                                      child: HtmlWidget(
                                        webUrl!.contains("h3")
                                            ? webUrl!.replaceAll("h3", "h3")
                                            : webUrl!,
                                        webView: false,
                                        textStyle: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 2.0,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    appVideo != null && appVideo != ''
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Row(
                                              children: [
                                                createGradientButton(
                                                    'Video',
                                                    ColorUtils
                                                        .loginButtonGradient,
                                                    'assets/images/video.png',
                                                    appVideo,
                                                    'video',
                                                    null),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    appMp3 != null &&
                                            appMp3 != '' &&
                                            LoginModel.userAbleToPlayAudio
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Row(
                                              children: [
                                                createGradientButton(
                                                    'Audio',
                                                    ColorUtils
                                                        .greenButtonGradient,
                                                    'assets/images/audio.png',
                                                    appMp3,
                                                    'audio',
                                                    null),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    appNoteTakingGuide != null &&
                                            appNoteTakingGuide != ''
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Row(
                                              children: [
                                                createGradientButton(
                                                    'Note Taking Guide',
                                                    ColorUtils
                                                        .orangeButtonGradient,
                                                    'assets/images/article.png',
                                                    appNoteTakingGuide,
                                                    'pdf',
                                                    null),
                                              ],
                                            ),
                                          )
                                        : Container(),
                                    appHelpfulresources != null &&
                                            appHelpfulresources != ""
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 32.0,
                                                bottom: 24.0),
                                            child: HtmlWidget(
                                              appHelpfulresources!
                                                      .contains("h3")
                                                  ? appHelpfulresources!
                                                      .replaceAll("h3", "h3")
                                                  : appHelpfulresources!,
                                              webView: true,
                                              /*onTapUrl: (url){
                                                _launchURL(url);
                                              },*/
                                              textStyle: TextStyle(
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        2.0,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0,
                                                right: 8.0,
                                                top: 8.0,
                                                bottom: 24.0),
                                            child: Container(),
                                          ),
                                  ],
                                  controller: _listViewScrollController,
                                ),
                                _isLoading
                                    ? Container(
                                        decoration:
                                            BoxDecoration(color: Colors.white),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                          ),
                                        ))
                                    : Container(),
                              ],
                            ),
                          ),
                  ),
                  floatingActionButton: expansionTileTitle != "Start Course" &&
                          !isAppOpenFirstTime
                      ? Padding(
                          key: floatingButtonKey,
                          padding: _isLastPage &&
                                  tileTitle != null &&
                                  !tileTitle!.startsWith('STEP 7')
                              ? EdgeInsets.only(
                                  bottom: SizeConfig.heightMultiplier * 4)
                              : const EdgeInsets.only(bottom: 0.0),
                          child: FloatingActionButton(
                            child: Image.asset(
                              'assets/images/ic_notes.png',
                              scale: 4.5,
                            ),
                            backgroundColor: Color(0xFF442d53),
                            onPressed: () {
                              addNotes();
                            },
                          ),
                        )
                      : expansionTileTitle != "Start Course" &&
                              isAppOpenFirstTime
                          ? Padding(
                              key: floatingButtonKey,
                              padding: _isLastPage &&
                                      tileTitle != null &&
                                      !tileTitle!.startsWith('STEP 7')
                                  ? EdgeInsets.only(
                                      bottom: SizeConfig.heightMultiplier * 4)
                                  : const EdgeInsets.only(bottom: 0.0),
                              child: FloatingActionButton(
                                child: Image.asset(
                                  'assets/images/ic_notes.png',
                                  scale: 4.5,
                                ),
                                backgroundColor: Color(0xFF442d53),
                                onPressed: () {},
                              ),
                            )
                          : null),
              expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Material(
                      color: Colors.black.withOpacity(0.7),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        margin: EdgeInsets.only(
                            top: SizeConfig.heightMultiplier * 4, right: 8.0),
                        child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                icon: Image.asset('assets/images/cancel.png'),
                                onPressed: () {
                                  setState(() {
                                    isAppOpenFirstTime = false;
                                  });
                                })),
                      ),
                    )
                  : Container(),
              bookmarkButtonRect != null &&
                      expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Positioned(
                      child: Image.asset(
                        'assets/images/bookmark_inc.png',
                        scale: 2,
                      ),
                      top: (bookmarkButtonRect!.top + 10) + height / 5,
                      left: bookmarkButtonRect!.left -
                          (bookmarkButtonRect!.width + 40),
                    )
                  : Container(),
              floatButtonRect != null &&
                      expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Positioned(
                      child: Image.asset(
                        'assets/images/floating_ins.png',
                        scale: 2,
                      ),
                      top:
                          floatButtonRect!.top - (floatButtonRect!.height + 20),
                      left:
                          floatButtonRect!.left - (floatButtonRect!.width + 30),
                    )
                  : Container(),
              drawerIconRect != null &&
                      expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Positioned(
                      child: Image.asset(
                        'assets/images/drawer_ins.png',
                        scale: 2,
                      ),
                      top: drawerIconRect!.top + (drawerIconRect!.height - 20),
                      left: drawerIconRect!.left + (drawerIconRect!.width - 30),
                    )
                  : Container(),
              drawerIconRect != null &&
                      expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Positioned.fromRect(
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      rect: drawerIconRect!,
                    )
                  : Container(),
              bookmarkButtonRect != null &&
                      expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Positioned(
                      child: Image.asset(
                        'assets/images/ic_bookmark_border_white_24dp.png',
                        scale: 3.5,
                      ),
                      top: (bookmarkButtonRect!.top - 14) + height / 5,
                      left: bookmarkButtonRect!.left + 10,
                    )
                  : Container(),
              floatButtonRect != null &&
                      expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Positioned(
                      child: Image.asset(
                        'assets/images/ic_notes.png',
                        scale: 3.5,
                      ),
                      left: bookmarkButtonRect!.left + 10,
                    )
                  : Container(),
              expansionTileTitle != "Start Course" &&
                      isAppOpenFirstTime &&
                      !_isLoading
                  ? Center(
                      child: Image.asset(
                        'assets/images/swap_ins.png',
                        scale: 2,
                      ),
                    )
                  : Container()
            ],
          ),
        );
      });
    });
  }

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url, enableDomStorage: true)
      : throw 'Could not launch $_url';

  String buildWebString(String data) {
    return Uri.dataFromString(data,
            mimeType: "text/html", encoding: Encoding.getByName('utf-8'))
        .toString();
  }

  Widget stepsWidget() {
    if (subSessionList != null && subSessionList!.length > 0) {
      return Column(
        children: [
          Expanded(
            flex: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                height: 32,
                color: Utils.getColorFromHex('#b0c9c6'),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ValueListenableBuilder(
                        valueListenable: pageValue,
                        builder: (context, dynamic value, child) {
                          return Visibility(
                            visible: value > 0,
                            child: Container(
                              transform:
                                  Matrix4.translationValues(-3.0, 0.0, 0.0),
                              child: Align(
                                child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: Utils.getColorFromHex('#5d5656'),
                                  ),
                                  onPressed: () {
                                    if (pageValue.value > 0) {
                                      _pageController!
                                          .jumpToPage(pageValue.value - 1);
                                    }
                                  },
                                  iconSize: 16,
                                ),
                                alignment: Alignment.centerLeft,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      flex: 0,
                      child: Align(
                        child: Text(
                          'SWIPE LEFT-RIGHT FOR PREVIOUS-NEXT LESSON',
                          style: TextStyle(
                              fontSize: SizeConfig.heightMultiplier * 1.3,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              color: Utils.getColorFromHex('#5d5656')),
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: ValueListenableBuilder(
                          valueListenable: pageValue,
                          builder: (context, dynamic value, child) {
                            return Visibility(
                              visible: subSessionList!.length - 1 > value,
                              child: Container(
                                transform:
                                    Matrix4.translationValues(8.0, 0.0, 0.0),
                                child: Align(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Utils.getColorFromHex('#5d5656'),
                                    ),
                                    onPressed: () {
                                      if (subSessionList!.length - 1 >
                                          pageValue.value) {
                                        _pageController!
                                            .jumpToPage(pageValue.value + 1);
                                      }
                                    },
                                    iconSize: 16,
                                  ),
                                  alignment: Alignment.centerRight,
                                ),
                              ),
                            );
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8.0),
              child: PreloadPageView.builder(
                  itemCount: subSessionList!.length,
                  controller: _pageController,
                  preloadPagesCount: 6,
                  onPageChanged: (position) {
                    pageValue.value = position;
                    pageViewPrevIndex = position;
                    imageURL = subSessionList![position].imageUrl;
                    sharedPreferences.setInt("pageIndex", position);
                    sharedPreferences.setString('subSessionId',
                        subSessionList![position].id.toString());
                    dbHelper
                        .queryBookmarkById(
                            int.parse(
                                sharedPreferences.getString('sessionId')!),
                            int.parse(subSessionList![position].id.toString()))
                        .then((value) {
                      if (value.isNotEmpty) {
                        _isBookmarked = true;
                      } else {
                        _isBookmarked = false;
                      }

                      setState(() {
                        _isLoading = false;
                        if (subSessionList!.length - 1 == position) {
                          _isLastPage = true;
                        } else {
                          _isLastPage = false;
                        }
                        print(expansionTileTitle);
                        //headerTitle = expansionTileTitle;
                        headerSubTitle = subSessionList![position].subtitle;
                      });
                    });
                  },
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Flexible(
                            flex: 0,
                            child: CachedNetworkImage(
                              imageUrl: subSessionList![index].imageUrl!,
                              httpHeaders: {'User-Agent': 'Mozilla/5.0'},
                              fit: BoxFit.fill,
                              progressIndicatorBuilder:
                                  (context, url, progress) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: SizeConfig.heightMultiplier * 30,
                                  child: Center(
                                    child: SizedBox(
                                      width: 40.0,
                                      height: 40.0,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.0,
                                          value: progress.progress,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Flexible(
                            child: Builder(builder: (context) {
                              List<Widget> buttonList = [];

                              if (index == 0 &&
                                  subSessionList![index].subtitle != '') {
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(
                                        subSessionList![index].subtitle,
                                        ColorUtils.greenButtonGradient,
                                        'assets/images/article.png',
                                        subSessionList![index].articleUrl,
                                        'pdf',
                                        subSessionList![index]),
                                  ),
                                ));
                              }
                              if (subSessionList![index].audioName != null &&
                                      subSessionList![index].audioName != '' ||
                                  subSessionList![index].videoName != null &&
                                      subSessionList![index].videoName != '') {
                                //print('IS BONUS :: ${LoginModel.isBonus}');
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Row(
                                      children: [
                                        LoginModel.isBonus &&
                                                ((subSessionList![index]
                                                            .subtitle ==
                                                        'Parent Personality Assessment') ||
                                                    (subSessionList![index]
                                                            .subtitle ==
                                                        'Your Parenting Style and Why It Matters'))
                                            ? subSessionList![index]
                                                            .videoName !=
                                                        null &&
                                                    subSessionList![index]
                                                            .videoName !=
                                                        ''
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 0.0),
                                                    child: createGradientButton(
                                                        'BONUS:' +
                                                            subSessionList![
                                                                    index]
                                                                .videoName!,
                                                        ColorUtils
                                                            .orangeGradient,
                                                        'assets/images/video.png',
                                                        subSessionList![index]
                                                            .videoUrl,
                                                        'video',
                                                        subSessionList![index]),
                                                  )
                                                : Container()
                                            : subSessionList![index]
                                                            .videoName !=
                                                        null &&
                                                    subSessionList![index]
                                                            .videoName !=
                                                        ''
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 0.0),
                                                    child: createGradientButton(
                                                        subSessionList![index]
                                                            .videoName,
                                                        ColorUtils
                                                            .loginButtonGradient,
                                                        'assets/images/video.png',
                                                        subSessionList![index]
                                                            .videoUrl,
                                                        'video',
                                                        subSessionList![index]),
                                                  )
                                                : Container(),
                                        LoginModel.isBonus &&
                                                ((subSessionList![index]
                                                            .subtitle ==
                                                        'Parent Personality Assessment') ||
                                                    (subSessionList![index]
                                                            .subtitle ==
                                                        'Your Parenting Style and Why It Matters'))
                                            ? subSessionList![index]
                                                            .audioName !=
                                                        null &&
                                                    subSessionList![index]
                                                            .audioName !=
                                                        ''
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: createGradientButton(
                                                        'BONUS:' +
                                                            subSessionList![
                                                                    index]
                                                                .audioName!,
                                                        ColorUtils
                                                            .brownGradient,
                                                        'assets/images/audio.png',
                                                        subSessionList![index]
                                                            .audioUrl,
                                                        'audio',
                                                        subSessionList![index]),
                                                  )
                                                : Container()
                                            : subSessionList![index]
                                                            .audioName !=
                                                        null &&
                                                    subSessionList![index]
                                                            .audioName !=
                                                        '' &&
                                                    LoginModel
                                                        .userAbleToPlayAudio
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0),
                                                    child: createGradientButton(
                                                        subSessionList![index]
                                                            .audioName,
                                                        ColorUtils
                                                            .brownGradient,
                                                        'assets/images/audio.png',
                                                        subSessionList![index]
                                                            .audioUrl,
                                                        'audio',
                                                        subSessionList![index]),
                                                  )
                                                : Container(),
                                      ],
                                    ),
                                  ),
                                ));
                              }
                              /*if (subSessionList[index].videoName != null && subSessionList[index].videoName != '') {
                                buttonList.add(Expanded(flex: 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(subSessionList[index].videoName, ColorUtils.loginButtonGradient,
                                        'assets/images/video.png', subSessionList[index].videoUrl, 'video', subSessionList[index]),
                                  ),
                                ));
                              }*/
                              if (subSessionList![index].articleTitle != null &&
                                  subSessionList![index].articleTitle != '' &&
                                  index != 0) {
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    // print("++++++++++++++++++++++++++++");
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(
                                        subSessionList![index].articleTitle,
                                        ColorUtils.greenButtonGradient,
                                        'assets/images/article.png',
                                        subSessionList![index].articleUrl,
                                        'pdf',
                                        subSessionList![index]),
                                  ),
                                ));
                              }
                              if (subSessionList![index].articleTitle2 !=
                                      null &&
                                  subSessionList![index].articleTitle2 != '' &&
                                  index != 0) {
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    // print("++++++++++++++++++++++++++++");
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(
                                        subSessionList![index].articleTitle2,
                                        ColorUtils.greenButtonGradient,
                                        'assets/images/article.png',
                                        subSessionList![index].articleUrl2,
                                        'pdf',
                                        subSessionList![index]),
                                  ),
                                ));
                              }
                              if (subSessionList![index].interactiveTitle !=
                                      null &&
                                  subSessionList![index].interactiveTitle !=
                                      '') {
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(
                                        subSessionList![index].interactiveTitle,
                                        ColorUtils.yellowButtonGradient,
                                        'assets/images/widgets.png',
                                        subSessionList![index]
                                            .interactiveId
                                            .toString(),
                                        'interactive',
                                        subSessionList![index]),
                                  ),
                                ));
                              }
                              if (subSessionList![index].faqTitle != null &&
                                  subSessionList![index].faqTitle != '') {
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(
                                        "FAQs",
                                        ColorUtils.orangeButtonGradient,
                                        'assets/images/faq.png',
                                        subSessionList![index].faqId.toString(),
                                        'faq',
                                        subSessionList![index]),
                                  ),
                                ));
                              }
                              if (subSessionList![index].toolBoxTitle != null &&
                                  subSessionList![index].toolBoxTitle != '') {
                                buttonList.add(Expanded(
                                  flex: 0,
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: createGradientButton(
                                        subSessionList![index].toolBoxTitle,
                                        ColorUtils.lightGreenButtonGradient,
                                        'assets/images/toolbox.png',
                                        subSessionList![index]
                                            .toolBoxId
                                            .toString(),
                                        'toolbox',
                                        subSessionList![index]),
                                  ),
                                ));
                              }

                              return Align(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  children: buttonList,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      );
    } else if (isAppOpenFirstTime) {
      return FutureBuilder(
        future: DatabaseHelper.instance.queryCourses(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Course> courses = snapshot.data as List<Course>;
            return Container(
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: HtmlWidget(
                          courses[0].Description!.contains("h3")
                              ? courses[0].Description!.replaceAll("h3", "h3")
                              : courses[0].Description!,
                          webView: false,
                          textStyle: TextStyle(
                            fontSize: SizeConfig.textMultiplier * 1.8,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      flex: 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 1.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: createGradientButton(
                                "START COURSE",
                                ColorUtils.loginButtonGradient,
                                null,
                                null,
                                null,
                                null),
                          ))),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  Widget createGradientButton(
      String? title,
      List<Color> colorList,
      String? iconPath,
      String? link,
      String? linkType,
      Subsession? subsession) {
    //print('LINK :: $link');
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Container(
        height: SizeConfig.heightMultiplier * 6 < 48
            ? SizeConfig.heightMultiplier * 6
            : 48,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: colorList,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.all(Radius.circular(5))),
        child: MaterialButton(
          onPressed: () {
            if (isAppOpenFirstTime) {
              sharedPreferences.setBool('isAppOpenFirstTime', false);
              dbHelper.querySessions(1).then((onValue) {
                sessions = onValue;
                tileTitle = "Steps 1-7";
                expansionTileTitle = sessions![0].title;
                dbHelper
                    .querySubSessions(sessions![0].id, null)
                    .then((onValue) {
                  dbHelper.insertDrawerMenuItem(sessions![0].id, onValue[0].id,
                      tileTitle, expansionTileTitle, subExpansionTitle);
                  setState(() {
                    _isLoading = false;
                    isStepsEnabled = true;
                    subSessionList = onValue;
                    headerSubTitle = onValue[0].subtitle;
                    headerTitle = expansionTileTitle;
                    currentSubSessionIndex = 0;
                    setInitialValues(null, sessions![0].id.toString(),
                        onValue[0].id.toString());
                  });
                });
              });
            } else {
              if (linkType == 'pdf') {
                String fileName = link!
                    .substring(link.lastIndexOf('/') + 1)
                    .replaceAll('.pdf', '');
                //print('FILE NAME ::: $fileName');
                if (Utils.pdfList.contains(fileName)) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          PDFTextContent(Utils.getPdfId(fileName))));
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PDFFileViewer(title, link)));
                }
              }
              if (title == 'Article: Democracy in the Family') {
              } else if (linkType == 'audio') {
                if (WebHelper.login!.categories!.userLevel!.keys
                        .contains('2') &&
                    LoginModel.isSubscriptionForAudio) {
                  playAudio(context, title, link, true, true);
                  // Navigator.of(context).push(MaterialPageRoute(
                  //     builder: (context) => PlayAudio(title, link)));
                } else {
                  playAudio(context, title, link, false, false);
                }
                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlayAudio(title, link)));
              } else if (linkType == 'video') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PlayVideo(title, link)));
              } else if (linkType == 'interactive') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Interactive(
                        subsession!.interactiveTypeId,
                        subsession.interactiveId,
                        linkType,
                        title)));
              } else if (linkType == 'faq') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Interactive(
                        subsession!.interactiveTypeId,
                        subsession.faqId,
                        linkType,
                        title)));
              } else if (linkType == 'toolbox') {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Interactive(
                        subsession!.interactiveTypeId,
                        subsession.toolBoxId,
                        linkType,
                        title)));
              }
            }
          },
          child: iconPath == null
              ? Text(
                  title!,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.textMultiplier * 1.6,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      transform: Matrix4.translationValues(
                          title!.startsWith('Audio') ? -8.0 : -8.0, 0.0, 0.0),
                      child: Image.asset(
                        iconPath,
                        scale: 4,
                      ),
                    ),
                    Container(
                      transform: Matrix4.translationValues(
                          title.contains('Audio') ? -6.0 : 0.0, 0.0, 0.0),
                      child: Text(
                        title.replaceAll('Lesson', 'Video'),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.textMultiplier * 2.3,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'BebasNeue',
                            letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  playAudio(context, title, link, isContinueStreaming, playOnline) {
    final fileName = link.substring(link.lastIndexOf('/') + 1, link.length);
    Utils.isFileExist(Utils.getDirectoryPath(), fileName).then((value) {
      if (value != null) {
        Navigator.of(_scaffoldKey.currentContext!)
            .push(
                MaterialPageRoute(builder: (context) => PlayAudio(title, link)))
            .then((value) {
          print('RESULT DATA :: $value');
          if (expansionTileTitle != WebHelper.ultimateSurvival!.name &&
              expansionTileTitle != WebHelper.battleTested!.name) {
            if (sharedPreferences.getBool('_isAudioPlayContinuously') != null &&
                sharedPreferences.getBool('_isAudioPlayContinuously')!) {
              if (value != null &&
                  value &&
                  subSessionList!.length - 1 > pageValue.value) {
                _pageController!.jumpToPage(pageValue.value + 1);
                String? url = subSessionList![pageValue.value].audioUrl;
                WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                  playAudio(_scaffoldKey.currentContext!, subSessionList![pageValue.value].audioName,
                      url, isContinueStreaming, playOnline);
                });
              }
            }
          }
        });
      } else {
        if (!isContinueStreaming &&
            sharedPreferences.getBool('_isPopupOptionEnabled')!) {
          showDownloadOrStreamDialog(title, link);
        } else {
          if (playOnline ||
              (sharedPreferences.getBool('onlineOption') != null &&
                  sharedPreferences.getBool('onlineOption')!)) {
            Navigator.of(_scaffoldKey.currentContext!)
                .push(MaterialPageRoute(
                    builder: (context) => PlayAudio(title, link)))
                .then((value) {
              print('RESULT DATA :: $value');
              if (sharedPreferences.getBool('_isAudioPlayContinuously') !=
                      null &&
                  sharedPreferences.getBool('_isAudioPlayContinuously')!) {
                if (value != null && value) {
                  _pageController!.jumpToPage(pageValue.value + 1);
                  String? url = subSessionList![pageValue.value].audioUrl;
                  WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                    playAudio(
                        _scaffoldKey.currentContext!,
                        subSessionList![pageValue.value].audioName,
                        url,
                        isContinueStreaming,
                        playOnline);
                  });
                }
              }
            });
          } else {
            Utils.downloadSingleFile(_scaffoldKey.currentContext, title,
                subSessionList![pageValue.value].audioUrl);
          }
        }
      }
    });
  }

  Widget createSpeedDialChild(String label, Color color, List<Color> colorList,
      String iconPath, String link, String linkType, double scale) {
    return TextButton(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              color: colorList == null ? color : null,
              gradient: color == null
                  ? LinearGradient(
                      colors: colorList,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter)
                  : null,
              shape: BoxShape.circle),
          child: Image.asset(
            iconPath,
            scale: scale,
          ),
        ),
        onPressed: () {
          if (linkType == 'pdf') {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFFileViewer(label, link)));
          } else if (linkType == 'audio') {
            playAudio(context, label, link, true, true);
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (context) => PlayAudio(label, link)));
          } else if (linkType == 'video') {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PlayVideo(label, link)));
          } else {}
        });
  }

  addNotes() {
    TextEditingController notesTextController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return FutureBuilder(
            future: sharedPreferences.getString('objectid') != null &&
                    sharedPreferences.getString('objectid') != ''
                ? dbHelper.queryNotes(
                    int.parse(sharedPreferences.getString('objectid')!), null)
                : dbHelper.queryNotes(
                    int.parse(sharedPreferences.getString('sessionId')!),
                    subSessionList![pageValue.value].id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<NoteList> notesList = snapshot.data as List<NoteList>;
                if (notesList.isNotEmpty)
                  print('${notesList[0].Note}  ::: ${pageValue.value}');
                notesTextController = notesList.isNotEmpty
                    ? TextEditingController(text: notesList[0].Note)
                    : TextEditingController();
                return Dialog(
                  insetPadding: EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: ColorUtils.yellowButtonGradient,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                          ),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "Notes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: IconButton(
                                icon: Image.asset('assets/images/cancel.png'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            trailing: IconButton(
                                icon: Image.asset('assets/images/save.png'),
                                onPressed: () {
                                  if (notesTextController.text != null &&
                                      notesTextController.text != "") {
                                    if (sharedPreferences
                                                .getString('objectid') !=
                                            null &&
                                        sharedPreferences
                                                .getString('objectid') !=
                                            '') {
                                      print(subExpansionTitle);

                                      int contentType = (subExpansionTitle ==
                                                      null ||
                                                  subExpansionTitle == '') &&
                                              sharedPreferences
                                                      .getString('objectid') !=
                                                  null &&
                                              sharedPreferences
                                                      .getString('objectid') !=
                                                  ''
                                          ? DatabaseHelper
                                              .contentTypeSpecialityModule
                                          : DatabaseHelper
                                              .contentTypeExpertSeries;

                                      WebHelper.postAddNotes(context, [
                                        Notes(
                                            int.parse(sharedPreferences
                                                .getString('objectid')!),
                                            notesTextController.text,
                                            contentType)
                                      ]);
                                      dbHelper.saveNotes(
                                          int.parse(sharedPreferences
                                              .getString('objectid')!),
                                          notesTextController.text,
                                          contentType);
                                    } else if (sharedPreferences
                                                .getString('subSessionId') !=
                                            null &&
                                        sharedPreferences
                                                .getString('subSessionId') !=
                                            '') {
                                      WebHelper.postAddNotes(context, [
                                        Notes(
                                            subSessionList![pageValue.value].id,
                                            notesTextController.text,
                                            DatabaseHelper.contentTypeSteps)
                                      ]);
                                      dbHelper.saveNotes(
                                          subSessionList![pageValue.value].id,
                                          notesTextController.text,
                                          DatabaseHelper.contentTypeSteps);
                                    }
                                  } else {
                                    if (sharedPreferences
                                                .getString('objectid') !=
                                            null &&
                                        sharedPreferences
                                                .getString('objectid') !=
                                            '') {
                                      WebHelper.postDeleteNote(
                                          context,
                                          int.parse(sharedPreferences
                                              .getString('objectid')!));
                                      dbHelper.deleteNotes(
                                          int.parse(sharedPreferences
                                              .getString('objectid')!),
                                          subSessionList != null
                                              ? DatabaseHelper.contentTypeSteps
                                              : (subExpansionTitle == null ||
                                                          subExpansionTitle ==
                                                              '') &&
                                                      sharedPreferences
                                                              .getString(
                                                                  'objectid') !=
                                                          null &&
                                                      sharedPreferences
                                                              .getString(
                                                                  'objectid') !=
                                                          ''
                                                  ? DatabaseHelper
                                                      .contentTypeSpecialityModule
                                                  : DatabaseHelper
                                                      .contentTypeExpertSeries);
                                    } else if (sharedPreferences
                                                .getString('sessionId') !=
                                            null &&
                                        sharedPreferences
                                                .getString('sessionId') !=
                                            '') {
                                      WebHelper.postDeleteNote(
                                          context,
                                          int.parse(sharedPreferences
                                              .getString('subSessionId')!));
                                      dbHelper.deleteNotes(
                                          int.parse(sharedPreferences
                                              .getString('subSessionId')!),
                                          subSessionList != null
                                              ? DatabaseHelper.contentTypeSteps
                                              : (subExpansionTitle == null ||
                                                          subExpansionTitle ==
                                                              '') &&
                                                      sharedPreferences
                                                              .getString(
                                                                  'objectid') !=
                                                          null &&
                                                      sharedPreferences
                                                              .getString(
                                                                  'objectid') !=
                                                          ''
                                                  ? DatabaseHelper
                                                      .contentTypeSpecialityModule
                                                  : DatabaseHelper
                                                      .contentTypeExpertSeries);
                                    }
                                  }

                                  Navigator.of(context).pop();
                                }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              autofocus: true,
                              controller: notesTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add notes here",
                              ),
                              maxLines: null,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              } else {
                return Dialog(
                  insetPadding: EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 16.0, bottom: 16.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: ColorUtils.yellowButtonGradient,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter),
                          ),
                          child: ListTile(
                            title: Center(
                              child: Text(
                                "Notes",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: IconButton(
                                icon: Image.asset('assets/images/cancel.png'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            trailing: IconButton(
                                icon: Image.asset('assets/images/save.png'),
                                onPressed: () {
                                  if (notesTextController.text != null &&
                                      notesTextController.text != "") {
                                    int? contentType = sharedPreferences
                                                    .getString('objectid') !=
                                                null &&
                                            sharedPreferences
                                                    .getString('objectid') !=
                                                ''
                                        ? DatabaseHelper
                                            .contentTypeSpecialityModule
                                        : DatabaseHelper
                                            .contentTypeExpertSeries;

                                    String? objectId =
                                        sharedPreferences.getString('objectid');

                                    if (sharedPreferences
                                                .getString('objectid') !=
                                            null &&
                                        sharedPreferences
                                                .getString('objectid') !=
                                            '') {
                                      //
                                      print("IN");
                                      WebHelper.postAddNotes(context, [
                                        Notes(
                                            int.parse(objectId!),
                                            notesTextController.text,
                                            contentType)
                                      ]);

                                      dbHelper.saveNotes(
                                          int.parse(objectId),
                                          notesTextController.text,
                                          contentType);
                                    } else if (sharedPreferences
                                                .getString('sessionId') !=
                                            null &&
                                        sharedPreferences
                                                .getString('sessionId') !=
                                            '') {
                                      print("IN");

                                      WebHelper.postAddNotes(context, [
                                        Notes(
                                            int.parse(sharedPreferences
                                                .getString('subSessionId')!),
                                            notesTextController.text,
                                            DatabaseHelper.contentTypeSteps)
                                      ]);

                                      dbHelper.saveNotes(
                                          int.parse(sharedPreferences
                                              .getString('subSessionId')!),
                                          notesTextController.text,
                                          DatabaseHelper.contentTypeSteps);
                                    }
                                  } else {
                                    if (sharedPreferences
                                                .getString('objectid') !=
                                            null &&
                                        sharedPreferences
                                                .getString('objectid') !=
                                            '') {
                                      WebHelper.postDeleteNote(
                                          context,
                                          int.parse(sharedPreferences
                                              .getString('objectid')!));
                                      dbHelper.deleteNotes(
                                          int.parse(sharedPreferences
                                              .getString('objectid')!),
                                          DatabaseHelper
                                              .contentTypeSpecialityModule);
                                    } else if (sharedPreferences
                                                .getString('sessionId') !=
                                            null &&
                                        sharedPreferences
                                                .getString('sessionId') !=
                                            '') {
                                      WebHelper.postDeleteNote(
                                          context,
                                          int.parse(sharedPreferences
                                              .getString('subSessionId')!));
                                      dbHelper.deleteNotes(
                                          int.parse(sharedPreferences
                                              .getString('subSessionId')!),
                                          DatabaseHelper.contentTypeSteps);
                                    }
                                  }

                                  Navigator.of(context).pop();
                                }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: notesTextController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add notes here",
                              ),
                              maxLines: null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        });
  }

  @override
  void onTileTapped(List sessionTitles, String title, List? sessions, int index,
      int selectedSessionIndex) {
    if (sessionTitles[selectedSessionIndex] !=
        WebHelper.quickStartTutorial!.name) {
      setState(() {
        if (sessionTitles[selectedSessionIndex] ==
            WebHelper.ultimateSurvival!.name) {
          isStepsEnabled = false;
          headerTitle = null;
        }
        tileTitle = title;
        _isLoading = true;
        subExpansionTitle = '';
      });

      if (sessionTitles[selectedSessionIndex] ==
          WebHelper.ultimateSurvival!.name) {
        if (_listViewScrollController!.hasClients)
          _listViewScrollController!.animateTo(0.0,
              duration: Duration(microseconds: 200), curve: Curves.easeInOut);
        dbHelper
            .queryBookmarkById(
                WebHelper.ultimateSurvival!.items![index].objectId, null)
            .then((value) {
          if (value.isNotEmpty) {
            _isBookmarked = true;
          } else {
            _isBookmarked = false;
          }
          print('ID ::: ' +
              WebHelper.ultimateSurvival!.items![index].objectId.toString());
          WebHelper.fetchSpecialityModule(
                  WebHelper.ultimateSurvival!.items![index].objectId.toString())
              .then((onValue) {
            try {
              dbHelper.insertDrawerMenuItem(
                  WebHelper.ultimateSurvival!.items![index].objectId,
                  null,
                  tileTitle,
                  expansionTileTitle,
                  subExpansionTitle);
            } on Exception catch (_) {
              print('never reached');
            }

            setState(() {
              _isLastPage = false;
              subSessionList = null;
              isStepsEnabled = false;
              imageURL = onValue!.acf!.appImage!.url;
              webUrl = onValue.acf!.appContent;
              headerSubTitle = onValue.title!.rendered;
              appMp3 = onValue.acf!.appMp3;
              appVideo = onValue.acf!.appVideo;
              appNoteTakingGuide = onValue.acf!.appNoteTakingGuide;
              appHelpfulresources = onValue.acf!.appHelpfulResources;
              print(onValue.acf!.appHelpfulResources);
              print(WebHelper.ultimateSurvival!.items![index].objectId
                  .toString());
              setInitialValues(
                  WebHelper.ultimateSurvival!.items![index].objectId.toString(),
                  null,
                  null);
              _isLoading = false;
            });
          });
        });
      } else {
        currentSubSessionIndex = sessions![index].id - 2;

        dbHelper.querySubSessions(sessions[index].id, null).then((onValue) {
          dbHelper
              .queryBookmarkById(onValue[0].sessionId, onValue[0].id)
              .then((value) {
            if (value.isNotEmpty) {
              _isBookmarked = true;
            } else {
              _isBookmarked = false;
            }

            dbHelper.insertDrawerMenuItem(sessions[index].id, onValue[0].id,
                tileTitle, expansionTileTitle, subExpansionTitle);
            setState(() {
              isStepsEnabled = true;
              _isLoading = false;
              _isLastPage = false;
              subSessionList = onValue;
              headerSubTitle = onValue[0].subtitle;
              headerTitle = title;
              appMp3 = null;
              appVideo = null;
              appNoteTakingGuide = null;
              appHelpfulresources = null;
              setInitialValues(null, sessions[index].id.toString(),
                  onValue[0].id.toString());
              if (_pageController!.hasClients) _pageController!.jumpTo(0.0);
            });
          });
        });
      }
    } else {
      print(
          'QUICK START TUTORIAL :: ${WebHelper.quickStartTutorial!.items![index].title}');
      showDialog(
        context: context,
        builder: (context) => FullScreenProgress(),
      );
      WebHelper.fetchVideoTutorial(
              WebHelper.quickStartTutorial!.items![index].objectId.toString())
          .then((value) {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              PlayVideo(value.title!.rendered, value.acf!.vimeoLink),
        ));
      });
    }
  }

  @override
  void onSubTileTapped(List sessionTitles, String title, List? sessions,
      int index, int selectedSessionIndex, int selectedSubSessionIndex) {
    isStepsEnabled = false;
    String objectid = WebHelper
        .battleTested!.items![selectedSubSessionIndex].children![index].objectId
        .toString();

    setState(() {
      tileTitle = title;
      headerTitle = null;
      _isLoading = true;
      subSessionList = null;
      _isLastPage = false;
    });
    if (_listViewScrollController!.hasClients)
      _listViewScrollController!.animateTo(0.0,
          duration: Duration(microseconds: 200), curve: Curves.easeInOut);
    dbHelper.queryBookmarkById(int.parse(objectid), null).then((value) {
      if (value.isNotEmpty) {
        _isBookmarked = true;
      } else {
        _isBookmarked = false;
      }

      WebHelper.fetchSpecialityModule(objectid).then((onValue) {
        dbHelper.insertDrawerMenuItem(int.parse(objectid), null, tileTitle,
            expansionTileTitle, subExpansionTitle);
        setState(() {
          _isLastPage = false;
          imageURL = onValue!.acf!.appImage!.url;
          webUrl = onValue.acf!.appContent;
          headerSubTitle = onValue.title!.rendered;
          appMp3 = onValue.acf!.appMp3;
          appVideo = onValue.acf!.appVideo;
          appNoteTakingGuide = onValue.acf!.appNoteTakingGuide;
          appHelpfulresources = onValue.acf!.appHelpfulResources;
          setInitialValues(objectid, null, null);
          _isLoading = false;
        });
      });
    });
  }

  @override
  void onSimpleTileTapped(String title) {
    if (title == 'Instructions') {
      if (tileTitle != 'Steps 1-7') {
        dbHelper.querySessions(1).then((onValue) {
          sessions = onValue;
          tileTitle = "Steps 1-7";
          expansionTileTitle = sessions![0].title;
          dbHelper.querySubSessions(sessions![0].id, null).then((onValue) {
            dbHelper.insertDrawerMenuItem(sessions![0].id, onValue[0].id,
                tileTitle, expansionTileTitle, subExpansionTitle);
            setState(() {
              _isLoading = false;
              isStepsEnabled = true;
              subSessionList = onValue;
              headerSubTitle = onValue[0].subtitle;
              headerTitle = expansionTileTitle;
              currentSubSessionIndex = 0;
              setInitialValues(
                  null, sessions![0].id.toString(), onValue[0].id.toString());
            });
          });
        });
      }

      setState(() {
        _isLastPage = false;
        isAppOpenFirstTime = true;
      });
    }
  }

  showDownloadOrStreamDialog(title, link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(10),
        title: Text("Stream audio?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content:
            Text("Continue streaming audio or download to play it locally?"),
        actions: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(left: 10, right: 10),
            child: Container(
              alignment: Alignment.center,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      Utils.downloadSingleFile(
                          _scaffoldKey.currentContext, title, link);
                    },
                    child: Text(
                      'DOWNLOAD LOCALLY',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF442d53),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                      print("on Press");
                      playAudio(context, title, link, true, true);
                    },
                    child: Text(
                      'CONTINUE STREAMING',
                      style: TextStyle(
                          color: Color(0xFF442d53),
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void onFileDelete() {
    // TODO: implement onFileDelete
  }

  @override
  void onFileDownloaded(title, downloadLink) {
    print('onFileDownloaded');
    playAudio(context, title, downloadLink, false, false);
  }

  showAppUpdateDialog(version) {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (context) => AlertDialog(
        insetPadding: EdgeInsets.all(10),
        title: Text("Update Available",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Please update to the latest version"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              'Next time',
              style: TextStyle(color: Color(0xFF442d53)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              if (Platform.isIOS) {
                launch(
                    'https://itunes.apple.com/us/app/pps-online/id1166493887');
              } else {
                InAppUpdate.performImmediateUpdate();
              }
            },
            child: Text(
              'Update',
              style: TextStyle(color: Color(0xFF442d53)),
            ),
          ),
        ],
      ),
    );
  }

  checkForUpdate() {
    //print('COUNTER UP :: ${sharedPreferences.getInt('appOpenCounter')}');

    if (sharedPreferences.getBool('isCheckForUpdate')!) {
      sharedPreferences.setBool('isCheckForUpdate', false);
      if (Platform.isIOS) {
        WebHelper.checkAppleUpdate().then((value) {
          PackageInfo.fromPlatform().then((info) {
            if (value.results![0].version != info.version) {
              showAppUpdateDialog(value.results![0].version);
            } else {
              checkAppReview();
            }
          });
        });
      } else {
        InAppUpdate.checkForUpdate().then((value) {
          if (value.updateAvailability == UpdateAvailability.updateAvailable) {
            showAppUpdateDialog(value.availableVersionCode);
          } else {
            checkAppReview();
          }
        });
      }
    }
  }

  checkAppReview() async {
    //print('COUNTER :: ${sharedPreferences.getInt('appOpenCounter')}');
    if (sharedPreferences.getBool('isCheckForAppReview')!) {
      sharedPreferences.setBool('isCheckForAppReview', false);
      if (sharedPreferences.getInt('appOpenCounter') != null &&
          sharedPreferences.getInt('appOpenCounter')! > 5) {
        sharedPreferences.setInt('appOpenCounter', 1);
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
      } else {
        sharedPreferences.setInt(
            'appOpenCounter',
            sharedPreferences.getInt('appOpenCounter') != null
                ? sharedPreferences.getInt('appOpenCounter')! + 1
                : 1);
      }
    }
  }
}
