import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:archive/archive.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AppDrawer.dart';
import 'FileOperationCallBacks.dart';
import 'SizeConfig.dart';
import 'WebHelper.dart';

class Utils {
  static Utils? instance;
  static File? imageFile;
  static bool isLoginFromSharedPreference = false;
  static CancelToken? cancelToken;
  static ValueNotifier percentNotifier = ValueNotifier(0);
  static ValueNotifier dialogTitleNotifier = ValueNotifier('Downloading file...');
  static int totalPercentage = 100;
  static int percentage = 0;
  static FileOperationCallBacks? fileOperationCallBacks;
  static bool isDownloadError = false;
  static bool isInternetAvailable = true;

  factory Utils() => instance ??= new Utils();

  Utils._();

  static String? localPath;
  static Directory? localDirectory;

  static Future<bool> monitorInternetConnection() async {
    return Future.delayed(Duration(seconds: 2)).then((value) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
        try {
          final result = await InternetAddress.lookup(WebHelper.API_BASE_URL);
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            monitorInternetConnection();
            isInternetAvailable = true;
            return true;
          } else {
            monitorInternetConnection();
            isInternetAvailable = false;
            return false;
          }
        } on SocketException catch (_) {
          monitorInternetConnection();
          isInternetAvailable = false;
          return false;
        }
      } else {
        monitorInternetConnection();
        isInternetAvailable = false;
        return false;
      }
    });
  }

  static showNoInternetSnackBar(_scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('No Internet Connection'),
      duration: Duration(days: 365),
    ));
  }

  static showNoInternetSnackBarWithHide(_scaffoldKey) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('No Internet Connection'),
      duration: Duration(days: 365),
    ));

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (isInternetAvailable) {
        _scaffoldKey.currentState.hideCurrentSnackBar();
        timer.cancel();
      }
    });
  }

  static Color getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Color(int.parse("0x$hexColor"));
  }

  static File? file(String filename) {
    String dir = Utils.localPath!;
    String pathName = join(dir, filename);
    imageFile = File(pathName);
    return imageFile;
  }

  static Future<String?> getLocalPath() async {
    Directory dir = await getApplicationDocumentsDirectory();
    localDirectory = dir;
    localPath = dir.path;
    return localPath;
  }

  static setFileOperationCallBacks(FileOperationCallBacks callBacks) {
    fileOperationCallBacks = callBacks;
  }

  static showFacebookGoldDialog(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Positive Parenting"),
        content: Text('Are you sure you want to leave the app?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              launch(
                  'https://docs.google.com/forms/d/e/1FAIpQLSeRsa_ApXtGwienPl7ON8-r-WpIXVpJ9r0EWxztoiZlZrluSQ/viewform');
            },
            child: Text(
              'OKAY',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  static showCoachingSupportDialog(context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Positive Parenting"),
        content: Text(
            'You will be taken outside of this app to your browser where you will have to log into a protected area again. Are you sure you want to do that?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              launch('https://www.positiveparentingsolutions.com/ask-amy-calls');
            },
            child: Text(
              'OKAY',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  static Future<String?> isFileExist(directoryPath, fileName) async {
    Directory externalDir = await getTemporaryDirectory();
    Directory ppsDir = Directory(join(externalDir.path, 'pps'));

    Directory directory = Directory(join(ppsDir.path, directoryPath));
    Directory indDirectory = Directory(join(ppsDir.path, WebHelper.individualFilesPath));

    File file = File(join(directory.path, fileName));

    if (file.existsSync()) {
      return file.path;
    } else {
      File file = File(join(indDirectory.path, fileName));
      return file.existsSync() ? file.path : null;
    }
  }

  static String? getDirectoryPath() {
    var directoryPath;
    if (expansionTileTitle == WebHelper.battleTested!.name && subExpansionTitle != null) {
      switch (subExpansionTitle) {
        case 'THE LITTLES':
          directoryPath = WebHelper.theLittlesBlueprintsPath;
          break;
        case 'TWEENS & TEENS':
          directoryPath = WebHelper.tweensteensPath;
          break;
        case 'HOMEWORK & SCHOOL':
          directoryPath = WebHelper.homeworkSchoolPath;
          break;
        case 'KIDS WITH DIFFERENCES':
          directoryPath = WebHelper.kidsDifferencesPath;
          break;
        case 'ENDING ENTITLEMENT':
          directoryPath = WebHelper.endingEntitlementPath;
          break;
        case 'ADULT RELATIONSHIPS':
          directoryPath = WebHelper.adultRelationPath;
          break;
      }
    } else if (expansionTileTitle == WebHelper.ultimateSurvival!.name) {
      directoryPath = WebHelper.ultimateSurvivalGuidesPath;
    } else {
      directoryPath = WebHelper.coursesPath;
    }

    return directoryPath;
  }

  static Future<String> getFreeSpace() async {
    double? freeSpace = await DiskSpace.getFreeDiskSpace;
    print(freeSpace);
    return 'Available Space: $freeSpace MB';
  }

  static showDownloadDialog(context, requiredSpace, downloadLink, fileName, filePath) async {
    Directory externalDir = await getTemporaryDirectory();
    //print('PATH :: ${join(externalDir.path, WebHelper.coursesPath)}');
    Directory ppsDir = Directory(join(externalDir.path, 'pps'));
    if (!ppsDir.existsSync()) {
      ppsDir.create(recursive: false);
    }

    Directory directory = Directory(join(ppsDir.path, filePath));

    if (!directory.existsSync()) {
      getFreeSpace().then((value) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Continue download?"),
            content: Text('$value\nSpace Required: $requiredSpace MB'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  downloadZipFile(context, downloadLink, fileName, filePath);
                },
                child: Text(
                  'YES',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        );
      });
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            'Already Downloaded',
            textAlign: TextAlign.center,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))));
    }
  }

  static downloadZipFile(context, fileUrl, fileName, filePath) async {
    if (Utils.isInternetAvailable) {
      cancelToken = CancelToken();
      Directory externalDir = await getTemporaryDirectory();
      //print('PATH :: ${join(externalDir.path, WebHelper.coursesPath)}');
      Directory ppsDir = Directory(join(externalDir.path, 'pps'));
      if (!ppsDir.existsSync()) {
        ppsDir.create(recursive: false);
      }

      Directory directory = Directory(join(ppsDir.path, filePath));

      if (!directory.existsSync()) {
        percentNotifier.value = 0;
        dialogTitleNotifier.value = 'Downloading file...';

        showDownloadProgressDialog(context, directory, fileName);

        if (!directory.existsSync()) {
          directory.create(recursive: false);
        }

        Future.wait([startDownloading(context, fileUrl, '${directory.path}/$fileName', directory)]).then((value) {
          print(value);

          if (value != null && value[0] != null) {
            dialogTitleNotifier.value = "Unzipping files...";
          } else {
            Navigator.of(context).pop();
            context.setState(() {});
          }
        });
      } else {
        print('ALREADY DOWNLOADED');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No Internet Connection'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  static Future<dynamic> startDownloading(context, fileUrl, path, Directory directory) async {
    return WebHelper.dioInstance!.download(
      fileUrl,
      path,
      onReceiveProgress: (progress, total) {
        percentNotifier.value = ((progress / total) * totalPercentage);
      },
      deleteOnError: true,
      cancelToken: cancelToken,
      options: Options(
        followRedirects: false,
        validateStatus: (status) {
          return status! < 500;
        },
        headers: {'User-Agent': 'Mozilla/5.0'},
      ),
    ).catchError((onError) {
      isDownloadError = true;
      print('ERROR :: ${(onError as DioError).type}');
      percentNotifier.value = 0;
      final name = directory.path.substring(directory.path.lastIndexOf('/') + 1, directory.path.length);

      if (name != WebHelper.individualFilesPath && directory.existsSync()) directory.deleteSync(recursive: true);
    });
  }

  static showDownloadProgressDialog(mContext, Directory directory, fileName) {
    showDialog(
      context: mContext,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: ValueListenableBuilder(
            valueListenable: dialogTitleNotifier,
            builder: (context, dynamic value, child) {
              if (value == "Unzipping files...") {
                Future.delayed(Duration(milliseconds: 500)).then((value) {
                  unzipFile(context, '${directory.path}/$fileName', directory.path);
                });
              }
              return Text(
                value,
                style: TextStyle(fontSize: SizeConfig.textMultiplier * 2),
              );
            },
          ),
          content: ValueListenableBuilder(
            valueListenable: percentNotifier,
            builder: (context, dynamic value, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF442d53)),
                            backgroundColor: Colors.grey.withAlpha(70),
                            value: (value / totalPercentage),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentNotifier.value.round()}%',
                          style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.5),
                        ),
                        Text(
                          '${percentNotifier.value.round()}/$totalPercentage',
                          style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.5),
                        )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 16.0, bottom: 16.0),
              child: InkWell(
                child: Text(
                  'CANCEL',
                  style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.7),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  if (!cancelToken!.isCancelled) cancelToken!.cancel();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<bool> isDirectoryExist(filePath) async {
    Directory externalDir = await getTemporaryDirectory();
    Directory ppsDir = Directory(join(externalDir.path, 'pps'));

    if (!ppsDir.existsSync()) {
      ppsDir.create(recursive: false);
    }

    Directory directory = Directory(join(ppsDir.path, filePath));
    if (!directory.existsSync()) {
      return false;
    } else {
      return true;
    }
  }

  static showDeleteFileDialog(context, name, dirPath) async {
    Directory externalDir = await getTemporaryDirectory();
    Directory ppsDir = Directory(join(externalDir.path, 'pps'));
    print(dirPath);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: dirPath != WebHelper.individualFilesPath
            ? Text("Delete ${name}s?", style: TextStyle(fontSize: SizeConfig.textMultiplier * 2))
            : Text("Clear all individually downloaded files?",
                style: TextStyle(fontSize: SizeConfig.textMultiplier * 2)),
        content: Text('Are you sure?', style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.7)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Directory dir = Directory(join(ppsDir.path, dirPath));
              if (dir.existsSync()) {
                dir.delete(recursive: true);
              }

              if (fileOperationCallBacks != null) fileOperationCallBacks!.onFileDelete();
            },
            child: Text(
              'YES',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> unzipFile(context, filePath, directoryPath) async {
    final bytes = File(filePath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    archive.forEach((file) {
      final filename = file.name;
      print(filename);
      if (file.isFile) {
        final data = file.content as List<int>;
        File(join(directoryPath, filename))
          ..create(recursive: true)
          ..writeAsBytes(data);
      } else {
        Directory(join(directoryPath, filename))..create(recursive: true);
      }
    });

    Navigator.of(context).pop();
    if (fileOperationCallBacks != null) fileOperationCallBacks!.onFileDownloaded(null, null);
    return true;
  }

  static downloadSingleFile(context, title, downloadLink) async {
    if (Utils.isInternetAvailable) {
      cancelToken = CancelToken();
      Directory externalDir = await getTemporaryDirectory();
      //print('PATH :: ${join(externalDir.path, WebHelper.coursesPath)}');
      Directory ppsDir = Directory(join(externalDir.path, 'pps'));
      if (!ppsDir.existsSync()) {
        ppsDir.create(recursive: false);
      }

      Directory directory = Directory(join(ppsDir.path, WebHelper.individualFilesPath));
      final fileName = downloadLink.substring(downloadLink.lastIndexOf('/') + 1, downloadLink.length);

      if (!File(join(directory.path, fileName)).existsSync()) {
        percentNotifier.value = 0;
        dialogTitleNotifier.value = 'Downloading file...';

        showDownloadProgressDialog(context, directory, fileName);

        if (!directory.existsSync()) {
          directory.create(recursive: false);
        }

        Future.wait([startDownloading(context, downloadLink, '${directory.path}/$fileName', directory)]).then((value) {
          if (!isDownloadError) {
            Navigator.of(context).pop();
            print('fileOperationCallBacks NULL');
            if (fileOperationCallBacks != null) {
              print('fileOperationCallBacks NOT NULL');
              fileOperationCallBacks!.onFileDownloaded(title, downloadLink);
            }
          } else {
            isDownloadError = false;
          }
        });
      } else {
        print('ALREADY DOWNLOADED');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No Internet Connection'),
        duration: Duration(seconds: 2),
      ));
    }
  }

  static final pdfList = [
    'PPS_Democracy_in_the_Family',
    'PPS_Psychology_of_Parenting',
    'PPS_No_Time_for_MBST',
    'PPS_Encourage_Your_Kids',
    'PPS_Battling_Backtalk',
    'PPS_Lying',
    'PPS_Potty_Talk_Swearing',
    'PPS_Calming_Car_Chaos',
    'PPS_To_Lose_Or_Not_To_Lose',
    'PPS_Okay_Not_To_Share',
    'PPS_Meaningful_Apologies',
    'PPS_Tattling_vs_Informing',
    'PPS_How_Not_To_Talk_To_Kids',
  ];

  static String getPdfId(String fileName) {
    switch (fileName) {
      case 'PPS_Democracy_in_the_Family':
        return '32402';
      case 'PPS_Psychology_of_Parenting':
        return '32696';
      case 'PPS_No_Time_for_MBST':
        return '32699';
      case 'PPS_Encourage_Your_Kids':
        return '32701';
      case 'PPS_Battling_Backtalk':
        return '32705';
      case 'PPS_Lying':
        return '32707';
      case 'PPS_Potty_Talk_Swearing':
        return '32708';
      case 'PPS_Calming_Car_Chaos':
        return '32711';
      case 'PPS_To_Lose_Or_Not_To_Lose':
        return '32713';
      case 'PPS_Okay_Not_To_Share':
        return '32715';
      case 'PPS_Meaningful_Apologies':
        return '32719';
      case 'PPS_Tattling_vs_Informing':
        return '32717';
      case 'PPS_How_Not_To_Talk_To_Kids':
        return '32703';
      default:
        return '';
    }
  }
}
