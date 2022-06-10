import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:ppsflutter/AppleUpdater.dart';
import 'package:ppsflutter/databaseModel/Bookmark.dart';
import 'package:ppsflutter/databaseModel/Notes.dart';
import 'package:ppsflutter/webModel/ArticleText.dart';
import 'package:ppsflutter/webModel/BattleTested.dart';
import 'package:ppsflutter/webModel/Documents.dart';
import 'package:ppsflutter/webModel/LoginModel.dart';
import 'package:ppsflutter/webModel/UltimateSurvivalGuides.dart';
import 'package:ppsflutter/webModel/WebSpecialityModule.dart';
import 'package:ppsflutter/webModel/quick_start_tutorial.dart';
import 'package:ppsflutter/webModel/video_tutorial.dart';

class WebHelper {
  static String individualFilesPath = "tempFiles";
  static String expertSeriesPath = "tempExpert";
  static String specialityModulePath = "tempSpeciality";
  static String coursesPath = "tempCourses";
  static String ultimateSurvivalGuidesPath = "tempUltimateSurvivalGuides";
  static String theLittlesBlueprintsPath = "tempTheLittlesBlueprints";
  static String tweensteensPath = "tempTweensteens";
  static String homeworkSchoolPath = "tempHomeworkSchool";
  static String kidsDifferencesPath = "tempKidsDifferences";
  static String endingEntitlementPath = "tempEndingEntitlement";
  static String adultRelationPath = "tempAdultRelation";

  static String coursesZipFileName = "Sessions.zip";
  static String ultimateSurvivalGuidesZipFileName = "SurvivalGuides.zip";
  static String theLittlesBlueprintsFileName = "TheLittlesBlueprints.zip";
  static String tweensteensZipFileName = "TweensTeensBlueprints.zip";
  static String homeworkSchoolZipFileName = "HomeworkSchoolBlueprints.zip";
  static String kidsDifferencesZipFileName = "KidsBlueprints.zip";
  static String endingEntitlementZipFileName = "EntitlementBlueprints.zip";
  static String adultRelationZipFileName = "AdultRelationshipsBlueprints.zip";

  static String courseZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/sessions.zip";
  static String ultimateSurvivalGuidesZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/SurvivalGuides.zip";
  static String theLittlesBlueprintsZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/TheLittlesBlueprints.zip";
  static String tweensteensZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/TweensTeensBlueprints.zip";
  static String homeworkSchoolZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/HomeworkSchoolBlueprints.zip";
  static String kidsDifferencesZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/KidsBlueprints.zip";
  static String endingEntitlementZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/EntitlementBlueprints.zip";
  static String adultRelationZipFilePath =
      "https://www.positiveparentingsolutions.com/app/content/mp3/AdultRelationshipsBlueprints.zip";

  static final String API_BASE_URL = "www.positiveparentingsolutions.com";
  static final String LOGIN_API_URL = "/amember/api/check-access/by-login-pass";
  static final String RESET_PASSWORD_API_URL =
      "/amember/api/check-access/send-pass";
  static final String ULTIMATE_SURVIVAL_GUIDES =
      "/wp-json/wp-api-menus/v2/menus/446";
  static final String BATTLE_TESTED_BLUEPRINTS =
      "/wp-json/wp-api-menus/v2/menus/447";
  static final String QUICK_START_TUTORIAL =
      "/wp-json/wp-api-menus/v2/menus/501";
  static final String VIDEO_TUTORIAL = "/wp-json/wp/v2/video-tutorial/";
  static final String DOCUMENT_LIST = "/wp-json/wp-api-menus/v2/menus/448";
  static final String SPECIALITY_MODULES_DETAIL_URL = "/wp-json/wp/v2/pages/";
  static final String SPECIALITY_MODULES_DETAIL_POST_FIX =
      "title.rendered,acf.app_image.url,acf.app_content,acf.app_video,acf.app_note_taking_guide,acf.app_mp3,acf.app_helpful_resources";
  static final String CHANGE_VIDEO_STATE_URL = "/app/video.php?uid=";
  static final String VIDEO_STATE_API_PARAMETER_VIDEO_ID = "vid=";
  static final String VIDEO_STATE_API_PARAMETER_VIDEO_STATE = "st=";
  static final String BOOKMARK_API_URL = '/app/bookmarks.php';
  static final String NOTE_API_URL = '/app/notes.php';

  static final String ARTICLES = "/articles";
  static final String ARTICLE_S1_L1 =
      "/articles/democracy-in-the-family-really";

  static final String CHANGE_AUDIO_STATE_URL = "/app/audio.php?uid=";
  static final String AUDIO_STATE_API_PARAMETER_VIDEO_ID = "aid=";
  static final String AUDIO_STATE_API_PARAMETER_VIDEO_STATE = "st=";

  static final List<String> subscription = [
    "99",
    "100",
    "101",
    "102",
    "103",
    "104",
    "110",
    "129",
    "130",
    "131",
    "132"
  ];

  static LoginModel? login;
  static UltimateSurvivalGuides? ultimateSurvival;
  static BattleTested? battleTested;
  static WebSpecialityModule? specialityModule;
  static QuickStartTutorial? quickStartTutorial;
  static Documents? documents;
  static bool isBookmarkSync = false;
  static bool isNoteSync = false;
  static Dio? dio;

  static Dio? get dioInstance {
    if (dio == null) {
      dio = new Dio();
      dio!.interceptors
          .add(DioCacheManager(CacheConfig(baseUrl: API_BASE_URL)).interceptor);
    }

    return dio;
  }

  static Future<LoginModel?> postLogin(
      context, String? email, String? password) async {
    String? token = await FirebaseMessaging.instance.getToken();

    var parameter = {
      "_key": "wlyOF7TM8Y3tn19KUdlq",
      "login": email,
      "pass": password,
      "deviceToken": token
    };
    print(parameter.toString());
    var response;
    try {
      var url = Uri.https(API_BASE_URL, LOGIN_API_URL, parameter);
      response = await dioInstance!
          .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }

    if (response != null) {
      login = LoginModel.fromJson(json.decode(response.data!));

      LoginModel.isSubscriptionForAudio = false;
      LoginModel.isBonus = false;

      if (login!.categories != null &&
          login!.categories!.userLevel!.keys.contains('1')) {
        LoginModel.isGoldUser = true;
        LoginModel.isBronzeUser = false;
        LoginModel.isSilverUser = false;
        LoginModel.userLevel = 1;
      } else if (login!.categories != null &&
          login!.categories!.userLevel!.keys.contains('2')) {
        LoginModel.isGoldUser = false;
        LoginModel.isBronzeUser = false;
        LoginModel.isSilverUser = true;
        LoginModel.userLevel = 2;
      } else if (login!.categories != null &&
          login!.categories!.userLevel!.keys.contains('3')) {
        LoginModel.isGoldUser = false;
        LoginModel.isBronzeUser = true;
        LoginModel.isSilverUser = false;
        LoginModel.userLevel = 3;
      }

      if (login!.categories != null &&
          login!.categories!.userLevel!.keys.contains('9'))
        LoginModel.isBonus = true;

      if (login!.subscriptions != null) {
        login!.subscriptions!.sub!.keys.forEach((element) {
          if (subscription.contains(element)) {
            if (element == '110') {
              LoginModel.isSubscriptionForAudio = true;
              print('ELEMENTS :: $element');
            }
          }
        });
      }

      if (LoginModel.userLevel == 2) {
        if (LoginModel.isSubscriptionForAudio) {
          LoginModel.userAbleToPlayAudio = true;
        } else {
          LoginModel.userAbleToPlayAudio = false;
        }
      } else {
        LoginModel.userAbleToPlayAudio = true;
      }
      return login;
    } else {
      return null;
    }
  }

  static Future<String?> postResetPassword(String email) async {
    var parameter = {
      "_key": "wlyOF7TM8Y3tn19KUdlq",
      "login": email,
    };

    var url = Uri.https(API_BASE_URL, RESET_PASSWORD_API_URL, parameter);
    print(url);
    Response<String> response = await dioInstance!.getUri<String>(url);

    print(response.data);
    return response.data;
  }

  static Future<UltimateSurvivalGuides?> postUltimateSurvival() async {
    var url = Uri.https(API_BASE_URL, ULTIMATE_SURVIVAL_GUIDES);
    print(url);
    Response<String> response = await dioInstance!
        .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    print(response.data);
    ultimateSurvival =
        UltimateSurvivalGuides.fromJson(json.decode(response.data!));
    return ultimateSurvival;
  }

  static Future<QuickStartTutorial?> postQuickStartTutorials() async {
    var url = Uri.https(API_BASE_URL, QUICK_START_TUTORIAL);
    print(url);
    Response<String> response = await dioInstance!
        .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    print(response.data);
    quickStartTutorial =
        QuickStartTutorial.fromJson(json.decode(response.data!));
    return quickStartTutorial;
  }

  static Future<void> postAddBookmark(context, List<Bookmark> bookmarks) async {
    if (!WebHelper.isBookmarkSync) return;
    var parameter = {
      "uid": login!.userId,
      "action": "set",
      "bookmarks": bookmarks.map((e) => e.toJson()).toList()
    };
    print("%%%%%%%%%%%%%" + parameter.toString());

    try {
      Response<String> response = await dioInstance!
          .post('https://$API_BASE_URL$BOOKMARK_API_URL', data: parameter);
      // print("++++++++++++++$response");
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  static Future<void> postDeleteBookmark(context, int? subsessionId) async {
    String key = "";
    if (subsessionId.toString().length > 2) {
      key = 'ServerId';
    } else {
      key = 'SubsessionId';
    }

    if (!WebHelper.isBookmarkSync) return;
    try {
      Response<String> response = await dioInstance!.get(
          'https://$API_BASE_URL$BOOKMARK_API_URL?uid=${login!.userId}&action=delete&$key=$subsessionId');
      // print("++++++++++++++$response");
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  static Future<List<Bookmark>> postGetBookmarks(context) async {
    if (!WebHelper.isBookmarkSync) return [];
    List<Bookmark> bookmarks = [];
    try {
      Response response = await dioInstance!.get(
          'https://$API_BASE_URL$BOOKMARK_API_URL?uid=${login!.userId}&action=get');
      List<dynamic> jsonArray = json.decode(response.data);
      jsonArray.forEach((element) {
        bookmarks.add(Bookmark.fromAPIJson(element));
      });
      return bookmarks;
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }
    return [];
  }

  static Future<void> postAddNotes(context, List<Notes> notes) async {
    if (!WebHelper.isNoteSync) return;

    var parameter = {
      "uid": login!.userId,
      "action": "set",
      "notes": notes.map((e) => e.toJson()).toList()
    };
    // print("%%%%%%%%%%%%%" + parameter.toString());

    try {
      Response<String> response = await dioInstance!
          .post('https://$API_BASE_URL$NOTE_API_URL', data: parameter);
      // print("++++++++++++++$response");
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  static Future<void> postDeleteNote(context, int? subsessionId) async {
    if (!WebHelper.isNoteSync) return;

    try {
      Response<String> response = await dioInstance!.get(
          'https://$API_BASE_URL$NOTE_API_URL?uid=${login!.userId}&action=delete&SubsessionId=$subsessionId');
      // print("++++++++++++++$response");
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }
  }

  static Future<List<Notes>> postGetNotes(context) async {
    if (!WebHelper.isNoteSync) return [];

    List<Notes> notes = [];
    try {
      Response response = await dioInstance!.get(
          'https://$API_BASE_URL$NOTE_API_URL?uid=${login!.userId}&action=get');
      // print("====================${response.data.toString()}");
      List<dynamic> jsonArray = json.decode(response.data);
      jsonArray.forEach((element) {
        notes.add(Notes.fromAPIJson(element));
      });
      return notes;
    } on DioError catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message),
        duration: Duration(seconds: 3),
      ));
    }
    return [];
  }

  static Future<VideoTutorial> fetchVideoTutorial(String id) async {
    var url = Uri.https(API_BASE_URL, VIDEO_TUTORIAL + id);
    print(url);
    Response<String> response = await dioInstance!
        .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    print(response.data);
    return VideoTutorial.fromJson(json.decode(response.data!));
  }

  static Future<BattleTested?> postBattleTested() async {
    var url = Uri.https(API_BASE_URL, BATTLE_TESTED_BLUEPRINTS);
    print(url);
    Response<String> response = await dioInstance!
        .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    print(response.data);
    battleTested = BattleTested.fromJson(json.decode(response.data!));
    return battleTested;
  }

  static Future<WebSpecialityModule?> fetchSpecialityModule(
      String objectID) async {
    var params = {"fields": SPECIALITY_MODULES_DETAIL_POST_FIX};

    var url = Uri.https(
        API_BASE_URL, SPECIALITY_MODULES_DETAIL_URL + objectID, params);
    print(Uri.decodeFull(url.toString()));
    Response<String> response = await dioInstance!.get<String>(
        Uri.decodeFull(url.toString()),
        options: buildCacheOptions(Duration(days: 29)));
    specialityModule =
        WebSpecialityModule.fromJson(json.decode(response.data!));
    return specialityModule;
  }

  static Future<Documents?> fetchDocumentList() async {
    var url = Uri.https(API_BASE_URL, DOCUMENT_LIST);
    print(url);
    Response<String> response = await dioInstance!
        .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    log(response.data!);
    documents = Documents.fromJson(json.decode(response.data!));
    return documents;
  }

  static Future<AppleUpdater> checkAppleUpdate() async {
    var url =
        Uri.parse('http://itunes.apple.com/lookup?bundleId=com.pponline.com');
    print(url);
    Response<String> response = await dioInstance!
        .getUri<String>(url, options: buildCacheOptions(Duration(days: 29)));
    //print(response.data);
    return AppleUpdater.fromJson(json.decode(response.data!));
  }

  static Future<int> checkVideoState(int vid) async {
    var url = Uri.parse(
        'https://$API_BASE_URL$CHANGE_VIDEO_STATE_URL${login!.userId}&$VIDEO_STATE_API_PARAMETER_VIDEO_ID$vid');
    print(url);
    Response<String> response = await dioInstance!.getUri<String>(url);
    print('RES :: $response');
    return int.parse(response.data!);
  }

  static Future<int> setVideoState(int vid, int state) async {
    var url = Uri.parse(
        'https://$API_BASE_URL$CHANGE_VIDEO_STATE_URL${login!.userId}&$VIDEO_STATE_API_PARAMETER_VIDEO_ID$vid&$VIDEO_STATE_API_PARAMETER_VIDEO_STATE$state');
    print(url);
    Response<String> response = await dioInstance!.getUri<String>(url);
    //print(response.data);
    return int.parse(response.data!);
  }

  static Future<int> checkAudioState(aid) async {
    var url = Uri.parse(
        'https://$API_BASE_URL$CHANGE_AUDIO_STATE_URL${login!.userId}&$AUDIO_STATE_API_PARAMETER_VIDEO_ID$aid');
    print(url);
    Response<String> response = await dioInstance!.getUri<String>(url);
    //print('RES :: $response');
    return int.parse(response.data!);
  }

  static Future<int> setAudioState(aid, int? state) async {
    var url = Uri.parse(
        'https://$API_BASE_URL$CHANGE_AUDIO_STATE_URL${login!.userId}&$AUDIO_STATE_API_PARAMETER_VIDEO_ID$aid&$AUDIO_STATE_API_PARAMETER_VIDEO_STATE$state');
    print(url);
    Response<String> response = await dioInstance!.getUri<String>(url);
    //print(response.data);
    return 0;
  }

  static Future<ArticleText> getArticleText(String articleId) async {
    var url =
        Uri.https(API_BASE_URL, SPECIALITY_MODULES_DETAIL_URL + '$articleId');
    print(Uri.decodeFull(url.toString()));
    Response<String> response = await dioInstance!.get<String>(
        Uri.decodeFull(url.toString()),
        options: buildCacheOptions(Duration(days: 29)));
    return ArticleText.fromJson(json.decode(response.data!));
  }
}
