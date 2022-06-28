import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ppsflutter/Utils.dart';
import 'package:ppsflutter/WebHelper.dart';

import 'DatabaseHelper.dart';
import 'HomeScreen.dart';
import 'appThemeData.dart';

class PlayAudio extends StatefulWidget {
  final String? fileName, uri;

  PlayAudio(this.fileName, this.uri);

  @override
  _PlayAudioState createState() => _PlayAudioState(fileName, uri);
}

bool isFromNoInternetState = false;

class _PlayAudioState extends State<PlayAudio> {
  String? fileName = '', uri;
  bool _isLoading = true;
  bool _isSeekBarLoading = false;
  bool _isSeekComplete = false;
  bool isPlaying = true;
  double currentSeekValue = 0.0;
  double totalSeekValue = 0.0;
  int beforeSeekTime = 0;
  String? currentTime;
  int? startTime = 0;
  int? currentTimeInMillis = 0;
  String? totalTime;
  int totalTimeNumber = 0;
  var audioId;
  final dbHelper = DatabaseHelper.instance;

  _PlayAudioState(this.fileName, this.uri);

  AudioCache audioCache = AudioCache();
  AudioPlayer audioPlayer = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print('PLAY AUDIO initState :: $uri');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    if (uri!.contains('sessions/'))
      audioId = '"${uri!.split("sessions/")[1].split(".mp3")[0]}"';
    else if (uri!.contains('content/mp3/'))
      audioId = '"${uri!.split("content/mp3/")[1].split(".mp3")[0]}"';

    print('AID :: $audioId');
    if (Utils.isInternetAvailable) {
      loadAudio();
      WebHelper.checkAudioState(audioId).then((value) {
        currentTimeInMillis = value;
        startTime = value;
        print('currentTimeInMillis :: $currentTimeInMillis');
        final fileName = uri!.substring(uri!.lastIndexOf('/') + 1, uri!.length);
        Utils.isFileExist(Utils.getDirectoryPath(), fileName)
            .then((value) async {
          if (value != null) {
            print('VALUES :: NOT NULL');
            try {
              if (audioPlayer.state == PlayerState.STOPPED)
                await audioPlayer.play(value,
                    isLocal: true,
                    position: Duration(milliseconds: currentTimeInMillis!),
                    stayAwake: true);
            } catch (e) {
              print('PlayAudio :: $e');
            }
          } else {
            print('VALUES :: ${audioPlayer.state}');
            if (audioPlayer.state == PlayerState.STOPPED)
              await audioPlayer.play(uri!,
                  stayAwake: true,
                  position: Duration(milliseconds: currentTimeInMillis!));
          }
        });
        //audioPlayer.seek(Duration(milliseconds: currentTimeInMillis));
      });
    } else {
      dbHelper.queryAudioState(audioId).then((value) {
        currentTimeInMillis = value;
        startTime = value;
        final fileName = uri!.substring(uri!.lastIndexOf('/') + 1, uri!.length);
        Utils.isFileExist(Utils.getDirectoryPath(), fileName)
            .then((value) async {
          if (value != null) {
            if (audioPlayer.state == PlayerState.STOPPED) {
              await audioPlayer.play(value,
                  isLocal: true,
                  position: Duration(milliseconds: currentTimeInMillis!),
                  stayAwake: true);
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (_scaffoldKey.currentContext != null) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
    }
    timer?.cancel();
    print(
        'PLAY AUDIO dispose :: ${((currentTimeInMillis! * 100) / totalTimeNumber)}');
    if (Utils.isInternetAvailable) {
      if (((currentTimeInMillis! * 100) / totalTimeNumber) >= 99) {
        WebHelper.setAudioState(audioId, 0);
      } else {
        WebHelper.setAudioState(audioId, currentTimeInMillis);
      }
    } else {
      if (((currentTimeInMillis! * 100) / totalTimeNumber) >= 99) {
        dbHelper.insertAudioState(audioId, 0);
      } else {
        dbHelper.insertAudioState(audioId, currentTimeInMillis);
      }
    }
    //releasePlayer();
  }

  String getTimeString(int millis) {
    String timeString;
    double hours = millis / (1000 * 60 * 60);
    double minutes = (millis % (1000 * 60 * 60)) / (1000 * 60);
    double seconds = ((millis % (1000 * 60 * 60)) % (1000 * 60)) / 1000;

    if (hours.toInt().toString().padLeft(2, '0') == '00') {
      timeString =
          '${minutes.toInt().toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    } else if (hours.toInt().toString().padLeft(2, '0') == '00' &&
        minutes.toInt().toString().padLeft(2, '0') == '00') {
      timeString = '${seconds.toInt().toString().padLeft(2, '0')}';
    } else {
      timeString =
          '${hours.toInt().toString().padLeft(2, '0')}:${minutes.toInt().toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    }

    return timeString;
  }

  loadAudio() async {
    log(uri!);

    /*if (Platform.isIOS) {
      if (audioCache.fixedPlayer != null) {
        audioCache.fixedPlayer.startHeadlessService();
      }
      audioPlayer.startHeadlessService();
    }*/

    audioPlayer.onAudioPositionChanged.listen((event) {
      if (this.mounted) {
        setState(() {
          currentTimeInMillis = event.inMilliseconds;
          currentTime = getTimeString(event.inMilliseconds);
          currentSeekValue = event.inSeconds.toDouble();

          //print('onAudioPositionChanged : currentTimeInMillis :: $currentTimeInMillis');

          if (_isSeekComplete) {
            if (event.inMilliseconds > beforeSeekTime) {
              setState(() {
                _isSeekBarLoading = false;
              });
            }
          } else {
            beforeSeekTime = event.inMilliseconds;
          }
        });
      } else {}
    });

    audioPlayer.onDurationChanged.listen((event) async {
      if ((event.inMilliseconds) > currentTimeInMillis!) {
        setState(() {
          _isLoading = false;
          totalTime = getTimeString(event.inMilliseconds);
          totalTimeNumber = event.inMilliseconds;
          totalSeekValue = event.inSeconds.toDouble();
        });
      }

      if (((startTime! * 100) / event.inMilliseconds) >= 99) {
        startTime = 0;
        audioPlayer.seek(Duration(seconds: 0));
      }
    });

    audioPlayer.onPlayerCompletion.listen((event) {
      setState(() {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop(true);
      });
    });

    audioPlayer.onSeekComplete.listen((event) {
      _isSeekBarLoading = true;
      _isSeekComplete = true;
    });
  }

  Future<bool> releasePlayer() async {
    await audioPlayer.stop();
    await audioPlayer.release();
    await audioPlayer.dispose();
    print('CLOSED');
    return true;
  }

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('PlayAudio :: WillPopScope');
        return releasePlayer();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            fileName != null ? fileName! : '',
            style: TextStyle(fontSize: 14.0),
          ),
          titleSpacing: 0.0,
          backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
        ),
        body: _isLoading
            ? Container(
                child: Builder(
                  builder: (context) {
                    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                      final fileName = uri!
                          .substring(uri!.lastIndexOf('/') + 1, uri!.length);
                      Utils.isFileExist(Utils.getDirectoryPath(), fileName)
                          .then((value) {
                        if (value != null) {
                          loadAudio();
                        } else {
                          timer = Timer.periodic(Duration(seconds: 2), (timer) {
                            if (Utils.isInternetAvailable) {
                              if (_scaffoldKey.currentContext != null)
                                ScaffoldMessenger.of(
                                        _scaffoldKey.currentContext!)
                                    .hideCurrentSnackBar();
                              timer.cancel();
                              if (isFromNoInternetState) loadAudio();
                            } else {
                              isFromNoInternetState = true;
                              Utils.showNoInternetSnackBar(_scaffoldKey);
                            }
                          });
                        }
                      });
                    });
                    return Stack(
                      children: [
                        Center(child: Image.network(imageURL!)),
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  },
                ),
              )
            : Stack(
                children: <Widget>[
                  Center(
                      child: CachedNetworkImage(
                    imageUrl: imageURL!,
                  )),
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                if (currentSeekValue > 10) {
                                  setState(() {
                                    _isSeekComplete = false;
                                    currentSeekValue = currentSeekValue - 10;
                                    audioPlayer.seek(Duration(
                                        seconds: currentSeekValue.toInt()));
                                  });
                                } else {
                                  setState(() {
                                    _isSeekComplete = false;
                                    currentSeekValue = 0;
                                    audioPlayer.seek(Duration(seconds: 0));
                                  });
                                }
                              },
                              child: Icon(
                                Icons.fast_rewind,
                                color: Colors.white,
                              ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                isPlaying
                                    ? audioPlayer.pause().then((value) {
                                        setState(() {
                                          isPlaying = false;
                                        });
                                      })
                                    : audioPlayer.resume().then((value) {
                                        setState(() {
                                          isPlaying = true;
                                        });
                                      });
                              },
                              child: isPlaying
                                  ? Icon(
                                      Icons.pause,
                                      color: Colors.white,
                                    )
                                  : Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                            ),
                            MaterialButton(
                              onPressed: () {
                                setState(() {
                                  _isSeekComplete = false;
                                  currentSeekValue = currentSeekValue + 10;
                                  audioPlayer.seek(Duration(
                                      seconds: currentSeekValue.toInt()));
                                });
                              },
                              child: Icon(
                                Icons.fast_forward,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, bottom: 16.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 0,
                                child: Text(
                                  currentTime != null ? currentTime! : '',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Color(0xFF442d53),
                                    inactiveTrackColor: Colors.grey,
                                    trackHeight: 1.5,
                                    thumbColor: Color(0xFF442d53),
                                    thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 3.0),
                                    overlayColor: Colors.purple.withAlpha(32),
                                    overlayShape: RoundSliderOverlayShape(
                                        overlayRadius: 12.0),
                                  ),
                                  child: totalSeekValue > 0.0
                                      ? Slider(
                                          value:
                                              currentSeekValue <= totalSeekValue
                                                  ? currentSeekValue
                                                  : totalSeekValue,
                                          max: totalSeekValue,
                                          min: 0.0,
                                          onChanged: (value) {
                                            print("SEEK VALUE :: $value");
                                            setState(() {
                                              _isSeekComplete = false;
                                              currentSeekValue = value;
                                              audioPlayer.seek(Duration(
                                                  seconds: value.toInt()));
                                            });
                                          })
                                      : Slider(
                                          value: 0.0,
                                          max: totalSeekValue,
                                          min: 0.0,
                                          onChanged: (value) {
                                            print("SEEK VALUE :: $value");
                                            setState(() {
                                              _isSeekComplete = false;
                                              currentSeekValue = value;
                                              audioPlayer.seek(Duration(
                                                  seconds: value.toInt()));
                                            });
                                          }),
                                ),
                              ),
                              Expanded(
                                flex: 0,
                                child: Text(
                                  totalTime != null ? totalTime! : '',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isSeekBarLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Container(),
                ],
              ),
      ),
    );
  }
}
