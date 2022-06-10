import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:ppsflutter/databaseModel/Session.dart';
import 'package:ppsflutter/databaseModel/Subsession.dart';

import 'DatabaseHelper.dart';
import 'WebHelper.dart';

class StoreContentOffline extends StatefulWidget {
  static const name = "progress_screen";

  static PageRoute route() => PageRouteBuilder(
      settings: RouteSettings(name: name), opaque: false, pageBuilder: (context, _, __) => StoreContentOffline());

  const StoreContentOffline({Key? key}) : super(key: key);

  @override
  _StoreContentOfflineState createState() => _StoreContentOfflineState();
}

class _StoreContentOfflineState extends State<StoreContentOffline> {
  final dbHelper = DatabaseHelper.instance;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initProcess().then((value) {
      downloadAllModules().then((value) {
        downloadAllSpeciality().then((value) {
          Navigator.of(context).pop(true);
        });
      });
    });
  }

  Future initProcess() async {
    List<Session> sessions = await dbHelper.querySessions(1);
    return await Future.forEach(sessions, (dynamic element) async {
      List<Subsession> subSessions = await dbHelper.querySubSessions(element.id, null);

      await Future.forEach(
          subSessions,
          (dynamic element) async => await DefaultCacheManager()
              .downloadFile(element.imageUrl, authHeaders: {'User-Agent': 'Mozilla/5.0'})).onError((dynamic error, stackTrace) {
        Navigator.of(context).pop();
        return;
      });
    });
  }

  Future downloadAllModules() async {
    return await Future.forEach(WebHelper.ultimateSurvival!.items!, (dynamic element) async {
      final module = await (WebHelper.fetchSpecialityModule(element.objectId.toString()).onError((dynamic error, stackTrace) {
        Navigator.of(context).pop();
        return;
      }));
      await DefaultCacheManager().downloadFile(module!.acf!.appImage!.url!, authHeaders: {'User-Agent': 'Mozilla/5.0'});
    });
  }

  Future downloadAllSpeciality() async {
    return await Future.forEach(WebHelper.battleTested!.items!, (dynamic element) async {
      await Future.forEach(element.children, (dynamic element) async {
        final module = await (WebHelper.fetchSpecialityModule(element.objectId.toString()).onError((dynamic error, stackTrace) {
          return;
        }));
        await DefaultCacheManager().downloadFile(module!.acf!.appImage!.url!, authHeaders: {'User-Agent': 'Mozilla/5.0'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: isLoading
          ? Container(
              alignment: AlignmentDirectional.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text(
                    'Storing content offline\nPlease wait...',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          : Container(),
    );
  }
}
