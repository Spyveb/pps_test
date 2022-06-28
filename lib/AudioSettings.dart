import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ppsflutter/SizeConfig.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/databaseModel/Bookmark.dart';
import 'package:ppsflutter/databaseModel/Notes.dart';
import 'package:ppsflutter/store_content_offline.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AppDrawer.dart';
import 'DatabaseHelper.dart';
import 'FileOperationCallBacks.dart';
import 'Utils.dart';

class AudioSettings extends StatefulWidget {
  @override
  _AudioSettingsState createState() => _AudioSettingsState();
}

bool? _isAudioPlayContinuously = true;
bool? _isPopupOptionEnabled = false;
bool? _offlineOption = true;
bool? _onlineOption = false;
int totalPercentage = 100;
int percentage = 0;
CancelToken? cancelToken;
BuildContext? progressDialogContext;

class _AudioSettingsState extends State<AudioSettings>
    with WidgetsBindingObserver
    implements FileOperationCallBacks {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final dbHelper = DatabaseHelper.instance;

  void showOfflineContentDialog(context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Offline Access'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Do you want to enable offline access?'),
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
  Widget build(BuildContext context) {
    print('AUDIO SCREEN');
    Utils.setFileOperationCallBacks(this);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SingleChildScrollView(
            child: FutureBuilder(
              future: SharedPreferences.getInstance(),
              builder: (context, pref) {
                if (pref.hasData) {
                  SharedPreferences preferences =
                      pref.data as SharedPreferences;
                  _isPopupOptionEnabled =
                      preferences.getBool('_isPopupOptionEnabled');
                  _offlineOption = preferences.getBool('offlineOption');
                  _onlineOption = preferences.getBool('onlineOption') != null
                      ? preferences.getBool('onlineOption')
                      : !_offlineOption!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CheckboxListTile(
                          value: preferences
                                      .getBool('_isAudioPlayContinuously') !=
                                  null
                              ? preferences.getBool('_isAudioPlayContinuously')
                              : _isAudioPlayContinuously,
                          title: Text(
                            'Play audio continuously within sessions',
                            style: TextStyle(
                                fontFamily: 'OpenSans-Regular',
                                fontSize: SizeConfig.textMultiplier * 1.7,
                                color: Color(0xFF8c8c8c)),
                          ),
                          checkColor: Colors.white,
                          activeColor: Color(0xFF442d53),
                          onChanged: (isChecked) {
                            setState(() {
                              _isAudioPlayContinuously = isChecked;
                              preferences.setBool(
                                  '_isAudioPlayContinuously', isChecked!);
                            });
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      CheckboxListTile(
                          value: preferences.getBool('_isPopupOptionEnabled') !=
                                  null
                              ? preferences.getBool('_isPopupOptionEnabled')
                              : _isPopupOptionEnabled,
                          title: Text(
                            'Show Download or Stream popup option for each AUDIO link',
                            style: TextStyle(
                                fontFamily: 'OpenSans-Regular',
                                fontSize: SizeConfig.textMultiplier * 1.7,
                                color: Color(0xFF8c8c8c)),
                          ),
                          checkColor: Colors.white,
                          activeColor: Color(0xFF442d53),
                          onChanged: (isChecked) {
                            setState(() {
                              _isPopupOptionEnabled = isChecked;
                              preferences.setBool(
                                  '_isPopupOptionEnabled', isChecked!);
                            });
                          }),
                      !_isPopupOptionEnabled!
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 28.0),
                                  child: Text(
                                      'Default action for each AUDIO link:',
                                      style: TextStyle(
                                          fontFamily: 'OpenSans-Regular',
                                          fontSize:
                                              SizeConfig.textMultiplier * 1.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8c8c8c))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28.0, top: 0.0, right: 28.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Download to this device and play locally',
                                            style: TextStyle(
                                                fontFamily: 'OpenSans-Regular',
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        1.4,
                                                color: Color(0xFF8c8c8c)),
                                          ),
                                          Text(
                                            'allows for offline listening',
                                            style: TextStyle(
                                                fontFamily: 'OpenSans-Regular',
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        1.3,
                                                color: Color(0xFF8c8c8c)),
                                          ),
                                        ],
                                      ),
                                      Checkbox(
                                          value: _offlineOption,
                                          checkColor: Colors.white,
                                          activeColor: Color(0xFF442d53),
                                          onChanged: (isChecked) {
                                            preferences.setBool(
                                                'offlineOption', isChecked!);
                                            preferences.setBool(
                                                'onlineOption', !isChecked);
                                            setState(() {
                                              _onlineOption = !isChecked;
                                              _offlineOption = isChecked;
                                            });
                                          })
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 28.0, right: 28.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Stream from web',
                                            style: TextStyle(
                                                fontFamily: 'OpenSans-Regular',
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        1.4,
                                                color: Color(0xFF8c8c8c)),
                                          ),
                                          Text(
                                            'requires active internet connection',
                                            style: TextStyle(
                                                fontFamily: 'OpenSans-Regular',
                                                fontSize:
                                                    SizeConfig.textMultiplier *
                                                        1.3,
                                                color: Color(0xFF8c8c8c)),
                                          ),
                                        ],
                                      ),
                                      Checkbox(
                                          value: _onlineOption,
                                          checkColor: Colors.white,
                                          activeColor: Color(0xFF442d53),
                                          onChanged: (isChecked) {
                                            preferences.setBool(
                                                'onlineOption', isChecked!);
                                            preferences.setBool(
                                                'offlineOption', !isChecked);
                                            setState(() {
                                              _onlineOption = isChecked;
                                              _offlineOption = !isChecked;
                                            });
                                          })
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Offline Access',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          'Sync content for offline access',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          showOfflineContentDialog(context);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      CheckboxListTile(
                          value: WebHelper.isBookmarkSync,
                          title: Text(
                            'Sync All Bookmarks',
                            style: TextStyle(
                                fontFamily: 'OpenSans-Regular',
                                fontSize: SizeConfig.textMultiplier * 1.7,
                                color: Color(0xFF8c8c8c)),
                          ),
                          subtitle: Text(
                            'Sync all bookmarks to the server',
                            style: TextStyle(
                                fontFamily: 'OpenSans-Regular',
                                fontSize: SizeConfig.textMultiplier * 1.2,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF8c8c8c)),
                          ),
                          checkColor: Colors.white,
                          dense: true,
                          activeColor: Color(0xFF442d53),
                          onChanged: (isChecked) async {
                            setState(() {
                              WebHelper.isBookmarkSync = isChecked!;
                              preferences.setBool('isBookmarkSync', isChecked);
                            });
                            if (WebHelper.isBookmarkSync) {
                              dbHelper
                                  .insertBookmarkFromAPI()
                                  .then((value) async {
                                List<Bookmark> bookmarks = [];
                                List<Map<String, dynamic>> data =
                                    await dbHelper.queryAll("Bookmark");
                                data.forEach((element) {
                                  bookmarks.add(Bookmark.fromJson(element));
                                });
                                WebHelper.postAddBookmark(context, bookmarks);
                              });
                            }
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 0,
                        ),
                      ),
                      CheckboxListTile(
                          value: WebHelper.isNoteSync,
                          title: Text(
                            'Sync All Notes',
                            style: TextStyle(
                                fontFamily: 'OpenSans-Regular',
                                fontSize: SizeConfig.textMultiplier * 1.7,
                                color: Color(0xFF8c8c8c)),
                          ),
                          subtitle: Text(
                            'Sync all notes to the server',
                            style: TextStyle(
                                fontFamily: 'OpenSans-Regular',
                                fontSize: SizeConfig.textMultiplier * 1.2,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF8c8c8c)),
                          ),
                          dense: true,
                          checkColor: Colors.white,
                          activeColor: Color(0xFF442d53),
                          onChanged: (isChecked) async {
                            setState(() {
                              WebHelper.isNoteSync = isChecked!;
                              preferences.setBool('isNoteSync', isChecked);
                            });

                            if (WebHelper.isNoteSync) {
                              dbHelper.insertNoteFromAPI().then((value) async {
                                List<Notes> notes = [];
                                List<Map<String, dynamic>> data =
                                    await dbHelper.queryAll("Notes");
                                data.forEach((element) {
                                  notes.add(Notes.fromJson(element));
                                });
                                WebHelper.postAddNotes(context, notes);
                              });
                            }
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 0,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all Course Session audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '200 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              _scaffoldKey.currentContext,
                              200,
                              WebHelper.courseZipFilePath,
                              WebHelper.coursesZipFileName,
                              WebHelper.coursesPath);
                        },
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(WebHelper.coursesPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'Course Session audio',
                                      WebHelper.coursesPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 0.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all Ultimate Survival Guides audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '120 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              _scaffoldKey.currentContext,
                              155,
                              WebHelper.ultimateSurvivalGuidesZipFilePath,
                              WebHelper.ultimateSurvivalGuidesZipFileName,
                              WebHelper.ultimateSurvivalGuidesPath);
                        },
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(
                            WebHelper.ultimateSurvivalGuidesPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'Ultimate Survival Guides audio',
                                      WebHelper.ultimateSurvivalGuidesPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all THE LITTLES Blueprints audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '90 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              _scaffoldKey.currentContext,
                              90,
                              WebHelper.theLittlesBlueprintsZipFilePath,
                              WebHelper.theLittlesBlueprintsFileName,
                              WebHelper.theLittlesBlueprintsPath);
                        },
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(
                            WebHelper.theLittlesBlueprintsPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'THE LITTLES Blueprints audio',
                                      WebHelper.theLittlesBlueprintsPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all TWEENS & TEENS Blueprints audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '155 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              _scaffoldKey.currentContext,
                              135,
                              WebHelper.tweensteensZipFilePath,
                              WebHelper.tweensteensZipFileName,
                              WebHelper.tweensteensPath);
                        },
                      ),
                      FutureBuilder(
                        future:
                            Utils.isDirectoryExist(WebHelper.tweensteensPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'TWEENS & TEENS Blueprints audio',
                                      WebHelper.tweensteensPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all HOMEWORK & SCHOOL Blueprints audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '110 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              context,
                              120,
                              WebHelper.homeworkSchoolZipFilePath,
                              WebHelper.homeworkSchoolZipFileName,
                              WebHelper.homeworkSchoolPath);
                        },
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(
                            WebHelper.homeworkSchoolPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'HOMEWORK & SCHOOL Blueprints audio',
                                      WebHelper.homeworkSchoolPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all KIDS WITH DIFFERENCES Blueprints audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '120 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              context,
                              100,
                              WebHelper.kidsDifferencesZipFilePath,
                              WebHelper.kidsDifferencesZipFileName,
                              WebHelper.kidsDifferencesPath);
                        },
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(
                            WebHelper.kidsDifferencesPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'KIDS WITH DIFFERENCES Blueprints audio',
                                      WebHelper.kidsDifferencesPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all ENDING ENTITLEMENT Blueprints audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '115 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              context,
                              115,
                              WebHelper.endingEntitlementZipFilePath,
                              WebHelper.endingEntitlementZipFileName,
                              WebHelper.endingEntitlementPath);
                        },
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(
                            WebHelper.endingEntitlementPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      _scaffoldKey.currentContext,
                                      'ENDING ENTITLEMENT Blueprints audio',
                                      WebHelper.endingEntitlementPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      ListTile(
                        title: Text(
                          'Download all ADULT RELATIONSHIPS Blueprints audio files for offline listening',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.7,
                              color: Color(0xFF8c8c8c)),
                        ),
                        subtitle: Text(
                          '65 MB space required',
                          style: TextStyle(
                              fontFamily: 'OpenSans-Regular',
                              fontSize: SizeConfig.textMultiplier * 1.2,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF8c8c8c)),
                        ),
                        dense: true,
                        onTap: () {
                          Utils.showDownloadDialog(
                              _scaffoldKey.currentContext,
                              70,
                              WebHelper.adultRelationZipFilePath,
                              WebHelper.adultRelationZipFileName,
                              WebHelper.adultRelationPath);
                        },
                      ),
                      FutureBuilder(
                        future:
                            Utils.isDirectoryExist(WebHelper.adultRelationPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 8.0),
                              child: InkWell(
                                child: Text(
                                  'Delete from this device?',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      context,
                                      'ADULT RELATIONSHIPS Blueprints audio',
                                      WebHelper.adultRelationPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: Color(0xFF8c8c8c),
                          height: 1,
                        ),
                      ),
                      FutureBuilder(
                        future: Utils.isDirectoryExist(
                            WebHelper.individualFilesPath),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data as bool) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, bottom: 16.0, top: 12.0),
                              child: InkWell(
                                child: Text(
                                  'Clear/Delete all individually downloaded audio files',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: SizeConfig.textMultiplier * 1.5,
                                      fontFamily: 'OpenSans-Bold'),
                                ),
                                onTap: () {
                                  Utils.showDeleteFileDialog(
                                      context,
                                      'ADULT RELATIONSHIPS Blueprints audio',
                                      WebHelper.individualFilesPath);
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('AUDIO SCREEN INIT');
    WidgetsBinding.instance?.waitUntilFirstFrameRasterized.then((value) {
      print('BINDING');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void onFileDelete() {
    print('onFileDelete');
    if (mounted) setState(() {});
  }

  @override
  void onFileDownloaded(title, downloadLink) {
    if (mounted) setState(() {});
  }
}
