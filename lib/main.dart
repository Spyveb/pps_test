import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as services;
import 'package:http/http.dart' as http;
import 'package:native_shared_preferences/native_shared_preferences.dart';
import 'package:path/path.dart';
import 'package:ppsflutter/AppDrawer.dart';
import 'package:ppsflutter/DatabaseHelper.dart';
import 'package:ppsflutter/Utils.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:ppsflutter/databaseModel/ExpertSeries.dart';
import 'package:ppsflutter/databaseModel/SubCategory.dart';
import 'package:ppsflutter/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'SizeConfig.dart';
import 'databaseModel/SpecialityModule.dart';
import 'http_override.dart';
import 'login.dart';

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = false;

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = HttpOverride();
    await Firebase.initializeApp();
    LocalNotificationService.initialize();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(MyApp());
    Utils.monitorInternetConnection();
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

String splashLogo = "";

class _MyAppState extends State<MyApp> {
  File? imageFile;
  String? localPath;
  bool isImageLoaded = false;
  bool _isAllImagesDownloaded = true;
  bool _isLoadingStarted = true;
  double? currentProgress;
  ValueNotifier<double?> currentProgressNotifier = ValueNotifier<double?>(0.0);
  SharedPreferences? sharedPreferences;
  late NativeSharedPreferences _nativeSharedPreferences;
  late DatabaseHelper dbHelper;

  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize

    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }
  }

//1865268418
  @override
  void initState() {
    super.initState();
    _initializeFlutterFire();
    //Utils.getLocalPath();
    //file('splash_bg.png');
    //loadSharedPreference();
  }

  Future<SharedPreferences?> loadSharedPreference() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _nativeSharedPreferences = await NativeSharedPreferences.getInstance();

    WebHelper.isBookmarkSync = sharedPreferences?.getBool("isBookmarkSync") ?? false;
    WebHelper.isNoteSync = sharedPreferences?.getBool("isNoteSync") ?? false;


    // print("******************${WebHelper.isBookmarkSync} ${WebHelper.isNoteSync}");
    return sharedPreferences;
  }

  /*Future<dynamic> fetchTheme() async {
    http.Response response = await http.post("https://bbitsworldnet.000webhostapp.com/pps_theme1.php");
    Map<String, dynamic> theme = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return theme;
    }
  }*/

  File? file(String filename) {
    String dir = Utils.localPath!;
    String pathName = join(dir, filename);
    imageFile = File(pathName);
    return imageFile;
  }

  imageDownloadProgress(int received, int total) {
    //setState(() {
    currentProgress = (received / total).toDouble();
    currentProgressNotifier.value = currentProgress;
    //log("Current Progress: " + currentProgress.toString());
    // });
  }

  void downloadImages(List imageUrls, List fileNames) {
    Future.wait([
      WebHelper.dioInstance!.download(imageUrls[0], fileNames[0],
          onReceiveProgress: imageDownloadProgress),
      WebHelper.dioInstance!.download(imageUrls[1], fileNames[1],
          onReceiveProgress: imageDownloadProgress),
    ]).then((value) {
      if (value[0].statusCode == 200 && value[1].statusCode == 200) {
        setState(() {
          _isAllImagesDownloaded = true;
        });
      }
    });
  }

  setStateFromBuilder(bool _isLoadingStart, bool _isAllImageDownload) {
    Future.delayed(Duration(seconds: 0)).then((value) {
      setState(() {
        _isLoadingStarted = _isLoadingStart;
        _isAllImagesDownloaded = _isAllImageDownload;
      });
    });
  }

  Future startTime(BuildContext context) async {
    Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    services.SystemChrome.setPreferredOrientations([
      services.DeviceOrientation.portraitDown,
      services.DeviceOrientation.portraitUp
    ]);

    return MaterialApp(
        title: "PPS Online",
        theme: ThemeData(
          primaryColor: Color(0xFF442d53),
        ),
        home: Scaffold(
          key: _scaffoldKey,
          body: LayoutBuilder(builder: (context, constraints) {
            return OrientationBuilder(builder: (context, orientation) {
              SizeConfig().init(constraints, orientation);
              return FutureBuilder(
                  future: loadSharedPreference(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      print(
                          'NATIVE DATA :: ${_nativeSharedPreferences.getString('UserLogin')}');

                      if (sharedPreferences!.getString("username") == null &&
                          _nativeSharedPreferences.getString('UserLogin') !=
                              null) {
                        if (_nativeSharedPreferences.getString('UserLogin') !=
                                null &&
                            _nativeSharedPreferences
                                    .getString('UserPassword') !=
                                null) {
                          sharedPreferences!.setString('username',
                              _nativeSharedPreferences.getString('UserLogin')!);
                          sharedPreferences!.setString(
                              'password',
                              _nativeSharedPreferences
                                  .getString('UserPassword')!);
                        }
                      }

                      sharedPreferences!.setBool('isCheckForUpdate', true);
                      sharedPreferences!.setBool('isCheckForAppReview', true);
                      dbHelper = DatabaseHelper.instance;
                      return FutureBuilder(
                          future: Future.wait([
                            startTime(context),
                            DatabaseHelper.instance.databse
                          ]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              WidgetsBinding.instance!
                                  .addPostFrameCallback((timeStamp) async {
                                if (sharedPreferences != null) {
                                  if (sharedPreferences!
                                              .getString("username") !=
                                          null &&
                                      sharedPreferences!
                                              .getString("password") !=
                                          null) {
                                    Utils.isLoginFromSharedPreference = true;
                                    isAppOpenFirstTime = false;
                                    WebHelper.postLogin(
                                            context,
                                            sharedPreferences!
                                                .getString("username"),
                                            sharedPreferences!
                                                .getString("password"))
                                        .then((login) {
                                      if (login != null &&
                                          login.ok! &&
                                          login.categories != null &&
                                          login.subscriptions != null) {
                                        Future.wait([
                                          WebHelper.postUltimateSurvival(),
                                          WebHelper.postBattleTested(),
                                          WebHelper.postQuickStartTutorials()
                                        ]).then((value) {
                                          WebHelper.ultimateSurvival!.items!
                                              .forEach((element) {
                                            dbHelper.insertSpecialityModule(
                                                SpecialityModule(
                                                        element.objectId,
                                                        element.title,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null)
                                                    .toJson());
                                          });

                                          WebHelper.quickStartTutorial!.items!
                                              .forEach((element) {
                                            dbHelper.insertQuickStartTutorial({
                                              'title': element.title,
                                              'object_id': element.objectId
                                            });
                                          });

                                          WebHelper.battleTested!.items!
                                              .forEach((element) {
                                            dbHelper.insertExpertSeries(
                                                ExpertSeries(
                                                        element.objectId,
                                                        element.title,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null,
                                                        null)
                                                    .toJson());

                                            element.children!
                                                .forEach((element) {
                                              dbHelper.insertSubCategory(
                                                  SubCategory(
                                                          element.objectId,
                                                          element.title,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null,
                                                          null)
                                                      .toJson());
                                            });
                                          });

                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                            builder: (context) => HomeScreen(),
                                          ));
                                        });
                                      } else {
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) => Login(
                                                    'Sorry, you don\'t have any active products...')));
                                        Utils.isLoginFromSharedPreference =
                                            false;
                                        sharedPreferences!.remove('username');
                                        sharedPreferences!.remove('password');
                                      }
                                    });
                                  } else {
                                    sharedPreferences!.getBool(
                                                'isAppOpenFirstTime') ==
                                            null
                                        ? isAppOpenFirstTime = true
                                        : isAppOpenFirstTime = false;
                                    Future.delayed(Duration(seconds: 3))
                                        .then((value) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Login(null),
                                          ));
                                    });
                                  }
                                } else if (!Utils.isInternetAvailable) {
                                  Utils.showNoInternetSnackBar(_scaffoldKey);

                                  Timer.periodic(Duration(seconds: 2), (timer) {
                                    if (Utils.isInternetAvailable) {
                                      _scaffoldKey.currentState!
                                          .hideCurrentSnackBar();
                                      timer.cancel();
                                      setState(() {});
                                      if (sharedPreferences!
                                                  .getString("username") !=
                                              null &&
                                          sharedPreferences!
                                                  .getString("password") !=
                                              null) {
                                        Utils.isLoginFromSharedPreference =
                                            true;
                                        WebHelper.postLogin(
                                                context,
                                                sharedPreferences!
                                                    .getString("username"),
                                                sharedPreferences!
                                                    .getString("password"))
                                            .then((login) {
                                          if (login != null &&
                                              login.ok! &&
                                              login.subscriptions != null &&
                                              login.categories != null) {
                                            Future.wait([
                                              WebHelper.postUltimateSurvival(),
                                              WebHelper.postBattleTested(),
                                              WebHelper
                                                  .postQuickStartTutorials()
                                            ]).then((value) {
                                              WebHelper.ultimateSurvival!.items!
                                                  .forEach((element) {
                                                dbHelper.insertSpecialityModule(
                                                    SpecialityModule(
                                                            element.objectId,
                                                            element.title,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null)
                                                        .toJson());
                                              });

                                              WebHelper
                                                  .quickStartTutorial!.items!
                                                  .forEach((element) {
                                                dbHelper
                                                    .insertQuickStartTutorial({
                                                  'title': element.title,
                                                  'object_id': element.objectId
                                                });
                                              });

                                              WebHelper.battleTested!.items!
                                                  .forEach((element) {
                                                dbHelper.insertExpertSeries(
                                                    ExpertSeries(
                                                            element.objectId,
                                                            element.title,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null,
                                                            null)
                                                        .toJson());

                                                element.children!
                                                    .forEach((element) {
                                                  dbHelper.insertSubCategory(
                                                      SubCategory(
                                                              element.objectId,
                                                              element.title,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null,
                                                              null)
                                                          .toJson());
                                                });
                                              });

                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(),
                                              ));
                                            });
                                          } else {
                                            Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(
                                                    builder: (context) => Login(
                                                        'Sorry, you don\'t have any active products...')));
                                            Utils.isLoginFromSharedPreference =
                                                false;
                                            sharedPreferences!
                                                .remove('username');
                                            sharedPreferences!
                                                .remove('password');
                                          }
                                        });
                                      } else {
                                        Future.delayed(Duration(seconds: 3))
                                            .then((value) {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    Login(null),
                                              ));
                                        });
                                      }
                                    }
                                  });
                                }
                              });
                            }
                            return Stack(
                              children: [
                                Container(
                                  child: AspectRatio(
                                    aspectRatio:
                                        MediaQuery.of(context).size.aspectRatio,
                                    child: Image(
                                      image: AssetImage(
                                          'assets/images/splash_bg.png'),
                                      fit: BoxFit.fill, // use this
                                    ),
                                  ),
                                ),
                                Utils.isInternetAvailable &&
                                        sharedPreferences!
                                                .getString("username") !=
                                            null
                                    ? Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                        ),
                                      )
                                    : Container(),
                              ],
                            );
                          });
                    } else {
                      return Container(child: CircularProgressIndicator());
                    }
                  });
            });
          }),
        ));
  }

/*Scaffold(
  body: !_isLoadingStarted
  ? FutureBuilder(
  future: fetchTheme(),
  builder: (context, snapshot) {
  if (snapshot.hasData) {
  Map<String, dynamic> theme = snapshot.data;
  appThemeData.appName = theme['appName'];
  splashLogo = theme['appBarLogo'];
  app_images.LOGO_ICON = splashLogo.substring(splashLogo.lastIndexOf("/") + 1);
  app_images.SPLASH_IMAGE =
  theme['splashImage'].substring(theme['splashImage'].lastIndexOf("/") + 1);
  appThemeData.appBarColor = theme['appBarColor'];

  if (!Utils.file(app_images.LOGO_ICON).existsSync() ||
  !Utils.file(app_images.SPLASH_IMAGE).existsSync()) {
  SharedPreferences.getInstance().then((value) {
  value.setString("logo", app_images.LOGO_ICON);
  });
  setStateFromBuilder(true, false);
  downloadImages([
  theme['splashImage'],
  theme['appBarLogo'],
  ], [
  file(app_images.SPLASH_IMAGE).path,
  file(app_images.LOGO_ICON).path,
  ]);
  } else {
  setStateFromBuilder(true, true);
  }
  }
  return Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
  FileSystemEntity.isFileSync(join(
  Utils.localPath,
  sharedPreferences.getString("logo") != null
  ? sharedPreferences.getString("logo")
      : ""))
  ? Center(
  child: Image.file(
  Utils.file(sharedPreferences.getString("logo")),
  alignment: Alignment.center,
  fit: BoxFit.contain,
  height: 100.0,
  width: 100.0,
  ),
  )
      : Container(),
  Padding(
  padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 4),
  child: CircularProgressIndicator(
  strokeWidth: 1.5,
  ),
  )
  ],
  );
  },
  )
      : !_isAllImagesDownloaded
  ? Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
  Utils.file(app_images.LOGO_ICON).existsSync()
  ? Center(
  child: Image.file(
  Utils.file(app_images.LOGO_ICON),
  alignment: Alignment.center,
  fit: BoxFit.contain,
  height: 100.0,
  width: 100.0,
  ),
  )
      : Center(
  child: Image.network(
  splashLogo,
  height: 100.0,
  width: 100.0,
  fit: BoxFit.contain,
  alignment: Alignment.center,
  ),
  ),
  Padding(
  padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 4),
  child: ValueListenableBuilder(
  valueListenable: currentProgressNotifier,
  builder: (context, values, child) {
  return CircularProgressIndicator(
  strokeWidth: 1.5,
  value: values,
  );
  }))
  ],
  )
      : FutureBuilder(
  future: startTime(context),
  builder: (context, snapshot) {
  //print(snapshot.connectionState);
  if (snapshot.connectionState == ConnectionState.done) {
  if (sharedPreferences != null) {
  if (sharedPreferences.getString("username") != null &&
  sharedPreferences.getString("password") != null) {
  Utils.isLoginFromSharedPreference = true;
  WebHelper.postLogin(sharedPreferences.getString("username"),
  sharedPreferences.getString("password"))
      .then((login) {
  if (WebHelper.login.ok) {
  Future.wait([WebHelper.postUltimateSurvival(), WebHelper.postBattleTested()])
      .then((value) {
  Navigator.of(context).pushReplacement(MaterialPageRoute(
  builder: (context) => HomeScreen(),
  ));
  });
  }
  });
  } else {
  Future.delayed(Duration(microseconds: 0)).then((value) {
  Navigator.pushReplacement(
  context,
  MaterialPageRoute(
  builder: (context) => Login(),
  ));
  });
  }
  }
  }
  */ /*else {
                                      if (sharedPreferences == null) {
                                        SharedPreferences.getInstance()
                                            .then((value) {
                                          sharedPreferences = value;
                                        });
                                      }
                                    }*/ /*
  return Center(
  child: Column(
  mainAxisAlignment: MainAxisAlignment.center,
  crossAxisAlignment: CrossAxisAlignment.center,
  children: <Widget>[
  Image.file(
  Utils.file(app_images.LOGO_ICON),
  height: 100.0,
  width: 100.0,
  fit: BoxFit.contain,
  ),
  Padding(
  padding: EdgeInsets.only(top: SizeConfig.heightMultiplier * 4),
  child: CircularProgressIndicator(
  strokeWidth: 1.5,
  ),
  )
  ],
  ));
  },
  )
  )*/
}
