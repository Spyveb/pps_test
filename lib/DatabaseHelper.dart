import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_shared_preferences/original_shared_preferences/original_shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ppsflutter/AppDrawer.dart';
import 'package:ppsflutter/HomeScreen.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/databaseModel/Bookmark.dart';
import 'package:ppsflutter/databaseModel/BookmarkList.dart';
import 'package:ppsflutter/databaseModel/Course.dart';
import 'package:ppsflutter/databaseModel/DrawerMenu.dart';
import 'package:ppsflutter/databaseModel/Faq.dart';
import 'package:ppsflutter/databaseModel/Interactive.dart';
import 'package:ppsflutter/databaseModel/Notes.dart';
import 'package:ppsflutter/databaseModel/Session.dart';
import 'package:ppsflutter/databaseModel/SpecialityModule.dart';
import 'package:ppsflutter/databaseModel/Subsession.dart';
import 'package:ppsflutter/databaseModel/Subtab.dart';
import 'package:ppsflutter/databaseModel/Toolbox.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'databaseModel/NoteList.dart';

class DatabaseHelper {
  static final databaseName = "assets/db/pps.sqlite";
  static final int contentTypeSteps = Platform.isIOS ? 1 : 2131296539;
  static final int contentTypeSpecialityModule =
      Platform.isIOS ? 2 : 2131296645;
  static final int contentTypeExpertSeries = Platform.isIOS ? 3 : 2131296415;
  int? stepsSessionId;

  var THE_LITTLES = [
    'Potty Training 101',
    'Stopping Sibling Bullying',
    'Raising Adventurous Eaters'
  ];
  var TWEENS_TWEENS = [
    'Terrific Teens Parenting Skills',
    'Technology Survival Plan',
    'Sex Talks... Simplified',
    'Responsible Social Media',
    '14 Talks by Age 14'
  ];
  var HOMEWORK_SCHOOL = [
    'Help for Homework Hassles',
    '3 R\'s of School Success',
    'Keeping Kids Safe from Bullying',
    'Help for Struggling Students'
  ];
  var KIDS_WITH_DIFF = [
    'ADHD 101',
    'Homework Skills for ADHD/EFD Kids',
    'Help for Anxious Kids',
    'The Explosive Child'
  ];
  var ENDING_ENTITLEMENT = [
    'Curing the Entitlement Epidemic',
    'ABCs of Allowance',
    'Say NO to Rewards & Praise',
    'Business Systems in the Family'
  ];
  var ADULT_RELATIONSHIP = [
    'Stronger Than Ever Parenting Partners',
    'Divorce & Parenting Apart',
    'Getting Your Partner on the Same Page'
  ];

  static Database? _database;
  bool isDatabaseFirstTimeCreated = false;

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database?> get databse async {
    if (_database != null) return _database;

    _database = await initDatabase();

    await _database!.execute(
        'CREATE TABLE IF NOT EXISTS DrawerMenu (sessionId INTEGER, SubSessionId INTEGER PRIMARY KEY, tileTitle TEXT, expansionTileTitle TEXT, subExpansionTileTitle TEXT)');

    await _database!.execute(
        "CREATE TABLE IF NOT EXISTS SubCategory AS SELECT * FROM ExpertSeries;");

    await _database!.execute(
        "CREATE TABLE IF NOT EXISTS AudioState (aid TEXT, state INTEGER)");

    await _database!.execute(
        "CREATE TABLE IF NOT EXISTS QuickStartTutorial (title TEXT, object_id INTEGER)");

    await _database!
        .execute("UPDATE Toolbox SET Title='STEP 1 TOOLS' WHERE SessionId = 2");
    await _database!
        .execute("UPDATE Toolbox SET Title='STEP 2 TOOLS' WHERE SessionId = 3");
    await _database!
        .execute("UPDATE Toolbox SET Title='STEP 3 TOOLS' WHERE SessionId = 4");
    await _database!
        .execute("UPDATE Toolbox SET Title='STEP 4 TOOLS' WHERE SessionId = 5");
    await _database!
        .execute("UPDATE Toolbox SET Title='STEP 5 TOOLS' WHERE SessionId = 6");
    await _database!
        .execute("UPDATE Toolbox SET Title='STEP 5 TOOLS' WHERE SessionId = 7");

    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 1:','STEP 1 of 7:')");
    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 2:','STEP 2 of 7:')");
    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 3:','STEP 3 of 7:')");
    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 4:','STEP 4 of 7:')");
    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 5:','STEP 5 of 7:')");
    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 6:','STEP 6 of 7:')");
    await _database!.execute(
        "UPDATE Session SET Title = REPLACE(Title,'STEP 7:','STEP 7 of 7:')");

    var query = await queryById('SubSession', 'Id', 48);
    Subsession subsession = Subsession.fromJson(query[0]);
    if (subsession.articleTitle2 == null || subsession.articleTitle2 == '') {
      await _database!.execute(
          "UPDATE SubSession SET ArticleTitle2 = 'Article: Tattling vs Informing', "
          "ArticleUrl2 = 'https://www.positiveparentingsolutions.com/app/content/PPS_Tattling_vs_Informing.pdf' "
          "WHERE Id = 48");
    }

    return _database;
  }

  insertDrawerMenuItem(int? sessionId, int? SubSessionId, String? tileTitle,
      String? expansionTileTitle, String? subExpansionTileTitle) async {
    Database? db = await instance.databse;

    print('sessionId :: $sessionId --->  SubSessionId :: $SubSessionId');

    if (SubSessionId == null) {
      db!
          .query("DrawerMenu",
              where: 'sessionId = ${sessionId} AND SubSessionId = ${sessionId}')
          .then((value) {
        if (value.isEmpty) {
          db.insert(
              "DrawerMenu",
              DrawerMenu(sessionId, sessionId, tileTitle, expansionTileTitle,
                      subExpansionTileTitle)
                  .toJson());
        } else {
          db.update(
              "DrawerMenu",
              DrawerMenu(sessionId, sessionId, tileTitle, expansionTileTitle,
                      subExpansionTileTitle)
                  .toJson(),
              where:
                  'sessionId = ${sessionId} AND SubSessionId = ${sessionId}');
        }
      });
    } else {
      db!
          .query("DrawerMenu",
              where:
                  'sessionId = ${sessionId} AND SubSessionId = ${SubSessionId}')
          .then((value) {
        if (value.isEmpty) {
          db.insert(
              "DrawerMenu",
              DrawerMenu(sessionId, SubSessionId, tileTitle, expansionTileTitle,
                      subExpansionTileTitle)
                  .toJson());
        } else {
          db.update(
              "DrawerMenu",
              DrawerMenu(sessionId, SubSessionId, tileTitle, expansionTileTitle,
                      subExpansionTileTitle)
                  .toJson(),
              where:
                  'sessionId = ${sessionId} AND SubSessionId = ${SubSessionId}');
        }
      });
    }

    /*if(SubSessionId == null) {
      db.insert("DrawerMenu", DrawerMenu(sessionId, sessionId, tileTitle, expansionTileTitle, subExpansionTileTitle).toJson());
    }else {
      db.insert("DrawerMenu", DrawerMenu(sessionId, SubSessionId, tileTitle, expansionTileTitle, subExpansionTileTitle).toJson());
    }*/
  }

  Future<List<DrawerMenu>> queryDrawerMenu(
      int? sessionId, int? subSessionId) async {
    Database? db = await instance.databse;
    List<DrawerMenu> interactiveList = [];
    var allRows;

    allRows = await db!.query("DrawerMenu");
    print(allRows);

    if (subSessionId != null) {
      allRows = await db.query("DrawerMenu",
          where: 'sessionId = ${sessionId} AND SubSessionId = ${subSessionId}');
    } else {
      allRows = await db.query("DrawerMenu", where: 'sessionId = ${sessionId}');
    }

    print(allRows);

    allRows.forEach((row) {
      interactiveList.add(DrawerMenu.fromJson(row));
    });

    return interactiveList;
  }

  initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = join(dbDir.path, "pps.db");

    if (!File(dbPath).existsSync()) {
      var databaseDir = await getDatabasesPath();
      var databasePath;

      if (Platform.isAndroid) {
        databasePath = join(databaseDir, 'pps.sqlite');
      } else {
        databasePath = join(databaseDir, 'PPS.sqlite');
      }

      File dbFile = File(join(databasePath));
      isDatabaseFirstTimeCreated = true;

      if (dbFile.existsSync()) {
        print("DATABASE PATH : " + databaseDir);
        print("DATABASE FILE : " + dbFile.lengthSync().toString());

        Uint8List list = dbFile.readAsBytesSync();
        ByteData data = ByteData.view(list.buffer);

        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes);
      } else {
        ByteData data = await rootBundle.load(databaseName);
        List<int> bytes =
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

        await File(dbPath).writeAsBytes(bytes);
      }
    } else {
      isDatabaseFirstTimeCreated = false;
    }

    log("Database Created");
    return await openDatabase(dbPath);
  }

  Future<List<Map<String, dynamic>>> queryAll(String tableName) async {
    Database? db = await instance.databse;
    return await db!.query(tableName);
  }

  Future<List<Map<String, dynamic>>> queryById(
      String tableName, String columnName, int? id) async {
    Database? db = await instance.databse;
    return await db!.query(tableName, where: '${columnName} = ${id}');
  }

  Future<List<Course>> queryCourses() async {
    List<Course> courseList = [];
    var allRows = await queryAll("Course");
    allRows.forEach((row) {
      courseList.add(Course.fromJson(row));
    });

    return courseList;
  }

  Future<List<Session>> querySessions(int courseId) async {
    List<Session> sessionList = [];
    var allRows = await queryById("Session", "CourseId", courseId);
    allRows.forEach((row) {
      sessionList.add(Session.fromJson(row));
    });

    return sessionList;
  }

  Future<List<Session>> querySessionById(int? Id) async {
    List<Session> sessionList = [];
    var allRows = await queryById("Session", "Id", Id);
    allRows.forEach((row) {
      sessionList.add(Session.fromJson(row));
    });

    return sessionList;
  }

  Future<List<Session>> querySessionsBySessionId(int SessionId) async {
    List<Session> sessionList = [];
    var allRows = await queryById("Session", "Id", SessionId);
    allRows.forEach((row) {
      sessionList.add(Session.fromJson(row));
    });

    return sessionList;
  }

  Future<List<Faq>> queryFaqs(int? sessionid) async {
    List<Faq> faqList = [];
    var allRows = await queryById("Faq", "SessionId", sessionid);
    allRows.forEach((row) {
      faqList.add(Faq.fromJson(row));
    });

    return faqList;
  }

  Future<List<Toolbox>> queryToolBox(int? sessionid) async {
    List<Toolbox> toolBoxList = [];
    var allRows = await queryById("Toolbox", "SessionId", sessionid);
    allRows.forEach((row) {
      toolBoxList.add(Toolbox.fromJson(row));
    });

    return toolBoxList;
  }

  Future<List<Subsession>> querySubSessions(
      int? sessionId, int? subSessionId) async {
    Database? db = await instance.databse;
    List<Subsession> subsessionList = [];
    var allRows;
    if (subSessionId == null) {
      allRows = await queryById("Subsession", "SessionId", sessionId);
    } else {
      allRows = await db!.query('Subsession',
          where: 'SessionId = ${sessionId} AND Id = ${subSessionId}');
    }

    allRows.forEach((row) {
      subsessionList.add(Subsession.fromJson(row));
    });

    for (int i = 0; i < subsessionList.length; i++) {
      queryInteractive(subsessionList[i].id).then((onValue) {
        if (onValue.length > 0) {
          subsessionList[i].interactiveId = onValue[0].id;
          subsessionList[i].interactiveTypeId = onValue[0].interactiveTypeId;
          subsessionList[i].interactiveTitle = onValue[0].title;
        }
      });
    }

    if (subsessionList.length > 0) {
      queryFaqs(sessionId).then((onValue) {
        if (onValue.length > 0) {
          subsessionList[subsessionList.length - 1].faqId = onValue[0].id;
          subsessionList[subsessionList.length - 1].faqTitle = onValue[0].Title;
        }
      });

      queryToolBox(sessionId).then((onValue) {
        if (onValue.length > 0) {
          subsessionList[subsessionList.length - 1].toolBoxId = onValue[0].id;
          subsessionList[subsessionList.length - 1].toolBoxTitle =
              onValue[0].title;
        }
      });
    }

    return subsessionList;
  }

  Future<List<Interactive>> queryInteractive(int? subSessionId) async {
    List<Interactive> interactiveList = [];
    var allRows = await queryById("Interactive", "SubsessionId", subSessionId);
    allRows.forEach((row) {
      interactiveList.add(Interactive.fromJson(row));
    });
    return interactiveList;
  }

  Future insertQuickStartTutorial(Map<String, dynamic> values) async {
    Database? db = await instance.databse;

    db!
        .query("QuickStartTutorial",
            where: '${'object_id'} = ${values['object_id']}')
        .then((value) {
      if (value.isEmpty) {
        db.insert("QuickStartTutorial", values);
      } else {
        db.update("QuickStartTutorial", values,
            where: '${'object_id'} = ${values['object_id']}');
      }
    });

    /* querySpecialityModulekById(values['ServerId']).then((value){
      if(value.isEmpty){
        db.insert("SpecialityModule", values);
      }else {
        db.update("SpecialityModule", values,where: '${'ServerId'} = ${values['ServerId']}');
      }
    });*/
  }

  Future insertSpecialityModule(Map<String, dynamic> values) async {
    Database? db = await instance.databse;

    db!
        .query("SpecialityModule",
            where: '${'ServerId'} = ${values['ServerId']}')
        .then((value) {
      if (value.isEmpty) {
        db.insert("SpecialityModule", values);
      } else {
        db.update("SpecialityModule", values,
            where: '${'ServerId'} = ${values['ServerId']}');
      }
    });

    /* querySpecialityModulekById(values['ServerId']).then((value){
      if(value.isEmpty){
        db.insert("SpecialityModule", values);
      }else {
        db.update("SpecialityModule", values,where: '${'ServerId'} = ${values['ServerId']}');
      }
    });*/
  }

  Future insertSubCategory(Map<String, dynamic> values) async {
    Database? db = await instance.databse;
    db!
        .query("SubCategory", where: '${'ServerId'} = ${values['ServerId']}')
        .then((value) {
      if (value.isEmpty) {
        db.insert("SubCategory", values);
      } else {
        db.update("SubCategory", values,
            where: '${'ServerId'} = ${values['ServerId']}');
      }
    });
  }

  Future insertExpertSeries(Map<String, dynamic> values) async {
    Database? db = await instance.databse;

    db!
        .query("ExpertSeries", where: '${'ServerId'} = ${values['ServerId']}')
        .then((value) {
      if (value.isEmpty) {
        db.insert("ExpertSeries", values);
      } else {
        db.update("ExpertSeries", values,
            where: '${'ServerId'} = ${values['ServerId']}');
      }
    });
  }

  Future<List<SpecialityModule>> querySpecialityModulekById(
      int serverId) async {
    Database? db = await instance.databse;
    List<SpecialityModule> interactiveList = [];

    var allRows = await db!
        .query("SpecialityModule", where: '${'ServerId'} = ${serverId}');
    allRows.forEach((row) {
      interactiveList.add(SpecialityModule.fromJson(row));
    });
    return interactiveList;
  }

  Future querySelectTables() async {
    Database? db = await instance.databse;

    var allRows = await db!.rawQuery("SELECT * FROM Bookmark");
    print("BookMark TABLE:");
    allRows.forEach((element) {
      print(element.toString());
    });
    //
    // allRows = await db.rawQuery("SELECT * FROM SpecialityModule");
    // print("SpecialityModule TABLE:");
    // allRows.forEach((element) {
    //   print(element.toString());
    // });
     allRows = await db!.rawQuery("SELECT * FROM Notes");
    print("SpecialityModule TABLE:");
    allRows.forEach((element) {
      print(element.toString());
    });
  }

  deleteSpecialityModulekById(int id, String title) async {
    Database? db = await instance.databse;
    db!.delete("SpecialityModule",
        where: '${'ServerId'} = ${id} and ${'Title'} = \"${title}\"');
  }

  Future insertBookmarkFromAPI() async {
    List<Bookmark> bookmarks = await WebHelper.postGetBookmarks(context);
    bookmarks.forEach((element) async {
      List<dynamic> books =
          await queryBookmarkById(element.SessionId, element.SubsessionId);
      if (books.isEmpty)
        insertBookmark(element.ServerId, element.SessionId,
            element.SubsessionId, element.ContentTypeId!);
    });
  }

  Future insertBookmark(
      int? objectId, int? SessionId, int? subSessionId, int contentType) async {
    Database? db = await instance.databse;
    print(
        'BOOKMARK - Object ID : $objectId & SessionID : $SessionId & SubSessionID : $subSessionId');
    if (objectId == null) {
      db!.insert("Bookmark",
          Bookmark(SessionId, subSessionId, contentType, -1).toJson());
    } else {
      db!.insert("Bookmark",
          Bookmark(SessionId, subSessionId, contentType, objectId).toJson());
    }
    /*db.query("Bookmark",where: '${'SessionId'} = ${objectId}').then((value) {
      if(value.isEmpty){

      }
    });*/
  }

  deleteBookmark(int? objectId, int? SessionId, int? subSessionId) async {
    Database? db = await instance.databse;
    print(
        'DELETE BOOKMARK - Object ID : $objectId & SessionID : $SessionId & SubSessionID : $subSessionId');
    if (objectId == null) {
      db!.delete("Bookmark",
          where:
              '${'SessionId'} = ${SessionId} AND ${'SubsessionId'} = ${subSessionId}');
    } else {
      db!.delete("Bookmark", where: '${'ServerId'} = ${objectId}');
    }
  }

  Future<List<BookmarkList>> queryBookmarkById(
      int? objectId, int? subSessionId) async {
    Database? db = await instance.databse;
    List<BookmarkList> interactiveList = [];
    var allRows;

    if (subSessionId != null) {
      allRows = await db!.rawQuery(
          "SELECT Session.Title, Subsession.SubTitle, Bookmark.Id, Bookmark.ContentTypeId, Bookmark.SessionId, Bookmark.SubsessionId FROM Bookmark INNER JOIN Session, Subsession " +
              "ON Bookmark.SessionId = ${objectId} AND Bookmark.SubsessionId = ${subSessionId}");

      allRows.forEach((row) {
        interactiveList.add(BookmarkList.fromJson(row));
      });
    }
    allRows = await db!.rawQuery(
        "SELECT SpecialityModule.MenuTitle, Bookmark.Id, Bookmark.ServerId, Bookmark.ContentTypeId FROM Bookmark INNER JOIN SpecialityModule " +
            "ON Bookmark.ServerId = ${objectId}");

    print(allRows);

    allRows.forEach((row) {
      interactiveList.add(BookmarkList.fromJson(row));
    });

    allRows = await db.rawQuery(
        "SELECT SubCategory.MenuTitle, Bookmark.Id, Bookmark.ServerId, Bookmark.ContentTypeId FROM Bookmark INNER JOIN SubCategory " +
            "ON Bookmark.ServerId =  ${objectId}");

    allRows.forEach((row) {
      interactiveList.add(BookmarkList.fromJson(row));
    });
    return interactiveList;
  }

  Future<List<BookmarkList>> queryBookmark() async {
    Database? db = await instance.databse;
    /*List<Bookmark> interactiveList = [];
    var allRows = await db.rawQuery("SELECT * FROM Bookmark GROUP BY SessionId");
    allRows.forEach((row) {
      interactiveList.add(Bookmark.fromJson(row));
    });

    interactiveList.toSet().toList().forEach((element) {
      log("Bookmark ID: " + element.SessionId.toString());
    });*/

    List<BookmarkList> interactiveList = [];

    var allRows = await db!.rawQuery(
        "SELECT Session.Title, Subsession.SubTitle, Bookmark.Id, Bookmark.ContentTypeId, Bookmark.SessionId, Bookmark.SubsessionId FROM Bookmark INNER JOIN Session, Subsession " +
            "ON Bookmark.SessionId = Session.Id AND Bookmark.SubsessionId = Subsession.Id");

    print(allRows);

    allRows.forEach((row) async {
      interactiveList.add(BookmarkList(
          row['SessionId'] as int?,
          row['SubsessionId'] as int?,
          contentTypeSteps,
          row['ServerId'] as int?,
          row['Title'] as String?,
          row['Subtitle'] as String?,
          row['MenuTitle'] as String?));
      //interactiveList.add(BookmarkList.fromJson(row));
      await insertDrawerMenuItem(
          row['SessionId'] as int?,
          row['SubsessionId'] as int?,
          'Steps 1-7',
          row['Title'] as String?,
          null);
    });

    allRows = await db.rawQuery(
        "SELECT SpecialityModule.MenuTitle, SpecialityModule.Title, Bookmark.Id, Bookmark.ServerId, Bookmark.ContentTypeId FROM Bookmark INNER JOIN SpecialityModule " +
            "ON Bookmark.ServerId = SpecialityModule.ServerId");

    print(allRows);

    allRows.forEach((row) async {
      //interactiveList.add(BookmarkList.fromJson(row));
      interactiveList.add(BookmarkList(
          row['SessionId'] as int?,
          row['SubsessionId'] as int?,
          contentTypeSpecialityModule,
          row['ServerId'] as int?,
          row['Title'] as String?,
          row['Subtitle'] as String?,
          row['MenuTitle'] as String?));
      print(
          "#################${interactiveList.length}\n${interactiveList[1].ServerId}");
      await insertDrawerMenuItem(row['ServerId'] as int?, null,
          'Ultimate Survival Guides', row['Title'] as String?, null);
    });

    allRows = await db.rawQuery(
        "SELECT SubCategory.MenuTitle, Bookmark.Id, Bookmark.ServerId, Bookmark.ContentTypeId FROM Bookmark INNER JOIN SubCategory " +
            "ON Bookmark.ServerId =  SubCategory.ServerId");

    allRows.forEach((row) async {
      interactiveList.add(BookmarkList(
          row['SessionId'] as int?,
          row['SubsessionId'] as int?,
          contentTypeExpertSeries,
          row['ServerId'] as int?,
          row['Title'] as String?,
          row['Subtitle'] as String?,
          row['MenuTitle'] as String?));
      //interactiveList.add(BookmarkList.fromJson(row));
      if (THE_LITTLES.contains(row['MenuTitle'])) {
        subExpansionTitle = 'THE LITTLES';
      } else if (TWEENS_TWEENS.contains(row['MenuTitle'])) {
        subExpansionTitle = 'TWEENS & TEENS';
      } else if (HOMEWORK_SCHOOL.contains(row['MenuTitle'])) {
        subExpansionTitle = 'HOMEWORK & SCHOOL';
      } else if (KIDS_WITH_DIFF.contains(row['MenuTitle'])) {
        subExpansionTitle = 'KIDS WITH DIFFERENCES';
      } else if (ENDING_ENTITLEMENT.contains(row['MenuTitle'])) {
        subExpansionTitle = 'ENDING ENTITLEMENT';
      } else if (ADULT_RELATIONSHIP.contains(row['MenuTitle'])) {
        subExpansionTitle = 'ADULT RELATIONSHIPS';
      }
      await insertDrawerMenuItem(
          row['ServerId'] as int?,
          null,
          row['MenuTitle'] as String?,
          'Battle-Tested Blueprints',
          subExpansionTitle);
    });

    return interactiveList;
  }

  Future insertNoteFromAPI() async {
    List<Notes> notes = await WebHelper.postGetNotes(context);
    notes.forEach((element) {
      saveNotes(element.SubsessionId, element.Note!, element.ContentType!);
    });
  }

  saveNotes(int? sessionId, String notes, int contentType) async {
    Database? db = await instance.databse;

    print('SAVE NOTES');

    db!
        .query("Notes",
            where: 'SubsessionId = $sessionId AND ContentType = $contentType')
        .then((value) {
      if (value.isEmpty) {
        db.insert("Notes", Notes(sessionId, notes, contentType).toJson());
      } else {
        db.update("Notes", Notes(sessionId, notes, contentType).toJson(),
            where:
                '${'SubsessionId'} = ${sessionId} AND ${'ContentType'} = ${contentType}');
      }
    });
  }

  deleteNotes(int sessionId, int subSessionId) async {
    Database? db = await instance.databse;
    var delete = await db!.delete("Notes",
        where:
            '${'SubsessionId'} = ${sessionId} AND ${'ContentType'} = ${subSessionId}');
    print("@@@@@@@@@@@@@@@$delete");
  }

  Future<List<NoteList>> queryNotes(int? sessionId, int? subSessionId) async {
    Database? db = await instance.databse;
    List<NoteList> interactiveList = [];

    var allRows;

    print('NOTE : ${sessionId} ::: ${subSessionId}');

    if (sessionId == null && subSessionId == null) {
      allRows = await db!.rawQuery(
          "SELECT Session.Title, Subsession.SubTitle, Notes.Id, Subsession.SessionId, Notes.SubsessionId, Notes.Note, Notes.ContentType FROM Notes INNER JOIN Session, Subsession " +
              "ON Notes.SubsessionId = Subsession.Id AND Subsession.SessionId = Session.Id");
    } else {
      allRows = await db!.rawQuery(
          "SELECT Session.Title, Subsession.SubTitle, Notes.Id, Subsession.SessionId, Notes.SubsessionId, Notes.Note, Notes.ContentType FROM Notes INNER JOIN Session, Subsession ON Notes.SubsessionId = $subSessionId AND Session.Id = $sessionId AND Subsession.Id = $subSessionId");
    }

    print(allRows);

    allRows.forEach((row) async {
      print(row['Title']);
      interactiveList.add(NoteList(
          row['SubsessionId'],
          row['Note'],
          contentTypeSteps,
          row['Title'],
          row['Subtitle'],
          row['SessionId'],
          row['MenuTitle'],
          null));
      //interactiveList.add(NoteList.fromJson(row));
      await insertDrawerMenuItem(row['SessionId'], row['SubsessionId'],
          'Steps 1-7', row['Title'], null);
    });

    if (sessionId == null && subSessionId == null) {
      allRows = await db.rawQuery(
          "SELECT SpecialityModule.MenuTitle, SpecialityModule.ServerId, Notes.Id, Notes.SubsessionId, Notes.Note, Notes.ContentType FROM Notes INNER JOIN SpecialityModule" +
              " ON Notes.SubsessionId = SpecialityModule.ServerId");
      allRows.forEach((row) async {
        print('FOR 2');
        interactiveList.add(NoteList(
            row['SubsessionId'],
            row['Note'],
            contentTypeSpecialityModule,
            row['Title'],
            row['Subtitle'],
            row['SessionId'],
            row['MenuTitle'],
            row['ServerId']));
        //interactiveList.add(NoteList.fromJson(row));
        await insertDrawerMenuItem(row['ServerId'], null,
            'Ultimate Survival Guides', row['Title'], null);
      });
    } else if (subSessionId == null) {
      allRows = await db.rawQuery(
          "SELECT SpecialityModule.MenuTitle, SpecialityModule.ServerId, Notes.Id, Notes.SubsessionId, Notes.Note, Notes.ContentType FROM Notes INNER JOIN SpecialityModule" +
              " ON Notes.SubsessionId = $sessionId AND SpecialityModule.ServerId = $sessionId");
      allRows.forEach((row) async {
        print('FOR 2');
        interactiveList.add(NoteList(
            row['SubsessionId'],
            row['Note'],
            contentTypeSpecialityModule,
            row['Title'],
            row['Subtitle'],
            row['SessionId'],
            row['MenuTitle'],
            row['ServerId']));
        //interactiveList.add(NoteList.fromJson(row));
        await insertDrawerMenuItem(row['ServerId'], null,
            'Ultimate Survival Guides', row['Title'], null);
      });
    }

    if (sessionId == null && subSessionId == null) {
      allRows = await db.rawQuery(
          "SELECT SubCategory.MenuTitle, SubCategory.ServerId, Notes.Id, Notes.SubsessionId, Notes.Note, Notes.ContentType FROM Notes INNER JOIN SubCategory" +
              " ON Notes.SubsessionId = SubCategory.ServerId");
      allRows.forEach((row) async {
        print('FOR 3');
        interactiveList.add(NoteList(
            row['SubsessionId'],
            row['Note'],
            contentTypeExpertSeries,
            row['Title'],
            row['Subtitle'],
            row['SessionId'],
            row['MenuTitle'],
            row['ServerId']));
        //interactiveList.add(NoteList.fromJson(row));
        if (THE_LITTLES.contains(row['MenuTitle'])) {
          subExpansionTitle = 'THE LITTLES';
        } else if (TWEENS_TWEENS.contains(row['MenuTitle'])) {
          subExpansionTitle = 'TWEENS & TEENS';
        } else if (HOMEWORK_SCHOOL.contains(row['MenuTitle'])) {
          subExpansionTitle = 'HOMEWORK & SCHOOL';
        } else if (KIDS_WITH_DIFF.contains(row['MenuTitle'])) {
          subExpansionTitle = 'KIDS WITH DIFFERENCES';
        } else if (ENDING_ENTITLEMENT.contains(row['MenuTitle'])) {
          subExpansionTitle = 'ENDING ENTITLEMENT';
        } else if (ADULT_RELATIONSHIP.contains(row['MenuTitle'])) {
          subExpansionTitle = 'ADULT RELATIONSHIPS';
        }
        await insertDrawerMenuItem(row['ServerId'], null, row['MenuTitle'],
            'Battle-Tested Blueprints', subExpansionTitle);
      });
    } else if (subSessionId == null) {
      allRows = await db.rawQuery(
          "SELECT SubCategory.MenuTitle, SubCategory.ServerId, Notes.Id, Notes.SubsessionId, Notes.Note, Notes.ContentType FROM Notes INNER JOIN SubCategory" +
              " ON Notes.SubsessionId = $sessionId AND SubCategory.ServerId = $sessionId");
      allRows.forEach((row) async {
        print('FOR 3');
        interactiveList.add(NoteList(
            row['SubsessionId'],
            row['Note'],
            contentTypeExpertSeries,
            row['Title'],
            row['SubTitle'],
            row['SessionId'],
            row['MenuTitle'],
            row['ServerId']));
        //interactiveList.add(NoteList.fromJson(row));
        if (THE_LITTLES.contains(row['MenuTitle'])) {
          subExpansionTitle = 'THE LITTLES';
        } else if (TWEENS_TWEENS.contains(row['MenuTitle'])) {
          subExpansionTitle = 'TWEENS & TEENS';
        } else if (HOMEWORK_SCHOOL.contains(row['MenuTitle'])) {
          subExpansionTitle = 'HOMEWORK & SCHOOL';
        } else if (KIDS_WITH_DIFF.contains(row['MenuTitle'])) {
          subExpansionTitle = 'KIDS WITH DIFFERENCES';
        } else if (ENDING_ENTITLEMENT.contains(row['MenuTitle'])) {
          subExpansionTitle = 'ENDING ENTITLEMENT';
        } else if (ADULT_RELATIONSHIP.contains(row['MenuTitle'])) {
          subExpansionTitle = 'ADULT RELATIONSHIPS';
        }
        await insertDrawerMenuItem(row['ServerId'], null, row['MenuTitle'],
            'Battle-Tested Blueprints', subExpansionTitle);
      });
    }

    return interactiveList;
  }

  Future<List<Notes>> queryAllNotes() async {
    Database? db = await instance.databse;
    List<Notes> interactiveList = [];

    var allRows = await db!.rawQuery("SELECT * FROM Notes");

    allRows.forEach((row) {
      interactiveList.add(Notes.fromJson(row));
    });
    return interactiveList;
  }

  Future<List<Subtab>> querySubTabs(int? id, String? trigger) async {
    Database? db = await instance.databse;
    List<Subtab> interactiveList = [];
    var allRows;

    if (trigger == 'faq') {
      allRows = await db!.query("Subtab", where: '${'FaqId'} = ${id}');
    } else if (trigger == 'interactive') {
      allRows = await db!.query("Subtab", where: '${'InteractiveId'} = ${id}');
    } else {
      allRows = await db!.query("Subtab", where: '${'ToolboxId'} = ${id}');
    }

    allRows.forEach((row) {
      interactiveList.add(Subtab.fromJson(row));
    });
    return interactiveList;
  }

  insertAudioState(String? aid, int? state) async {
    Database? db = await instance.databse;

    db!.query('AudioState', where: 'aid = ${"'$aid'"}').then((value) {
      print('insertAudioState :: $value');
      if (value.length == 0) {
        print('insertAudioState Insert');
        db.insert('AudioState', {'aid': aid, 'state': state});
      } else {
        print('insertAudioState Update');
        db.update('AudioState', {'state': state}, where: 'aid = ${"'$aid'"}');
      }
    });
  }

  Future<int?> queryAudioState(String? aid) async {
    Database? db = await instance.databse;

    print('SELECT state FROM AudioState WHERE aid = ${"'$aid'"}');

    List allRows = await db!
        .rawQuery('SELECT state FROM AudioState WHERE aid = ${"'$aid'"}');

    return allRows.length > 0 ? allRows[0]['state'] : 0;
  }
}
