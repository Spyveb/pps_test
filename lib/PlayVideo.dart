import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

import 'Utils.dart';

class PlayVideo extends StatefulWidget {
  String? fileName, uri;

  PlayVideo(this.fileName, this.uri);

  @override
  _PlayVideoState createState() => _PlayVideoState(fileName, uri);
}

class _PlayVideoState extends State<PlayVideo> {
  String? fileName, uri;

  _PlayVideoState(this.fileName, this.uri);

  VideoPlayerController? _playerController;
  int currentTime = 0;
  bool _isPanelShow = true;
  Timer? timer;
  Timer? timerInternet;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late var videoId;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    print('VIDEO_URL :: $uri');
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);

    if (Utils.isInternetAvailable) initialProcess();
  }

  initialProcess() {

    print('$uri');

    videoId = uri!.split("external/")[1].split(".sd.mp4")[0];

    print('VID :: $videoId');

    WebHelper.checkVideoState(int.parse(videoId)).then((onValue) {
      _playerController = VideoPlayerController.network(uri!)
        ..initialize().then((_) {
          if (this.mounted) {
            setState(() {
              _playerController!.play().then((value) {
                _playerController!.seekTo(Duration(milliseconds: onValue));
              });
            });
          }

          _playerController!.addListener(() {
            if (this.mounted) {
              if (_playerController!.value.duration.inMilliseconds == _playerController!.value.position.inMilliseconds) {
                setState(() {
                  currentTime = 0;
                  if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                });
              } else {
                setState(() {
                  currentTime = _playerController!.value.position.inMilliseconds;
                });
              }
            }
          });

          timer = Timer(Duration(seconds: 6), () {
            if (this.mounted) {
              setState(() {
                _isPanelShow = false;
              });
            }
          });
        });
    });
  }

  String getTimeString(int millis) {
    String timeString;
    double hours = millis / (1000 * 60 * 60);
    double minutes = (millis % (1000 * 60 * 60)) / (1000 * 60);
    double seconds = ((millis % (1000 * 60 * 60)) % (1000 * 60)) / 1000;

    if (hours.toInt().toString().padLeft(2, '0') == '00') {
      timeString = '${minutes.toInt().toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    } else if (hours.toInt().toString().padLeft(2, '0') == '00' && minutes.toInt().toString().padLeft(2, '0') == '00') {
      timeString = '${seconds.toInt().toString().padLeft(2, '0')}';
    } else {
      timeString =
          '${hours.toInt().toString().padLeft(2, '0')}:${minutes.toInt().toString().padLeft(2, '0')}:${seconds.toInt().toString().padLeft(2, '0')}';
    }

    return timeString;
  }

  @override
  void dispose() {
    super.dispose();
    if (_scaffoldKey.currentContext != null)
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
    timerInternet?.cancel();
    Wakelock.disable();
    _playerController!.dispose().then((value) {
      WebHelper.setVideoState(int.parse(videoId), currentTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: _isPanelShow
          ? AppBar(
              backgroundColor: Colors.black,
            )
          : null,
      body: Utils.isInternetAvailable
          ? Container(
              width: double.infinity,
              height: double.infinity,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_playerController!.value.isInitialized) {
                      if (!_isPanelShow) {
                        _isPanelShow = true;
                        timer = Timer(Duration(seconds: 6), () {
                          if (this.mounted) {
                            setState(() {
                              _isPanelShow = false;
                            });
                          }
                        });
                      } else {
                        if (timer != null) timer!.cancel();
                        _isPanelShow = false;
                      }
                    }
                  });
                },
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      child: _playerController != null && _playerController!.value != null && _playerController!.value.isInitialized
                          ? Center(
                              child: AspectRatio(
                                aspectRatio: _playerController!.value.aspectRatio,
                                child: VideoPlayer(
                                  _playerController!,
                                ),
                              ),
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                    _playerController != null && _playerController!.value != null && _playerController!.value.isInitialized
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Visibility(
                                maintainAnimation: true,
                                maintainState: true,
                                visible: _isPanelShow,
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                              flex: 0,
                                              child: Container(
                                                width: 32.0,
                                              )),
                                          Expanded(
                                            child: Align(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () {
                                                      if (_playerController!.value.position.inSeconds > 10) {
                                                        setState(() {
                                                          _playerController!.seekTo(
                                                              Duration(seconds: _playerController!.value.position.inSeconds - 10));
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _playerController!.seekTo(Duration(seconds: 0));
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
                                                      _playerController!.value.isPlaying
                                                          ? _playerController!.pause()
                                                          : _playerController!.play();
                                                    },
                                                    child: _playerController!.value.isPlaying
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
                                                      if (_playerController!.value.position.inSeconds <
                                                          _playerController!.value.duration.inSeconds) {
                                                        setState(() {
                                                          _playerController!.seekTo(
                                                              Duration(seconds: _playerController!.value.position.inSeconds + 10));
                                                        });
                                                      }
                                                    },
                                                    child: Icon(
                                                      Icons.fast_forward,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 8.0),
                                              child: IconButton(
                                                  icon: Icon(
                                                    Icons.more_vert,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    if (_playerController!.value.isInitialized) showPlayBackSpeedDialog();
                                                  }),
                                            ),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 16.0),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 0,
                                              child: Text(
                                                getTimeString(currentTime),
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                            Expanded(
                                              child: SliderTheme(
                                                data: SliderTheme.of(context).copyWith(
                                                  activeTrackColor: Color(0xFF442d53),
                                                  inactiveTrackColor: Colors.grey,
                                                  trackHeight: 1.0,
                                                  thumbColor: Color(0xFF442d53),
                                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 3.0),
                                                  overlayColor: Colors.purple.withAlpha(32),
                                                  overlayShape: RoundSliderOverlayShape(overlayRadius: 12.0),
                                                ),
                                                child: Slider(
                                                    value: _playerController!.value.position.inSeconds.toDouble(),
                                                    max: _playerController!.value.duration.inSeconds.toDouble(),
                                                    min: 0.0,
                                                    onChanged: (value) {
                                                      print(value);
                                                      setState(() {
                                                        _playerController!.seekTo(Duration(seconds: value.toInt()));
                                                      });
                                                    }),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 0,
                                              child: Text(
                                                getTimeString(_playerController!.value.duration.inMilliseconds),
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            )
          : Container(
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                    Utils.showNoInternetSnackBar(_scaffoldKey);
                    timerInternet = Timer.periodic(Duration(seconds: 2), (timer) {
                      if (Utils.isInternetAvailable) {
                        if (_scaffoldKey.currentContext != null)
                          ScaffoldMessenger.of(_scaffoldKey.currentContext!).hideCurrentSnackBar();
                        timerInternet!.cancel();
                        initialProcess();
                      }
                    });
                  });
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
    );
  }

  showPlayBackSpeedDialog() {
    _isPanelShow = true;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Expanded(
                    flex: 0,
                    child: ListView(shrinkWrap: true, children: <Widget>[
                      ListTile(
                        title: Text("0.5"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _playerController!.setPlaybackSpeed(0.5);
                        },
                      ),
                      ListTile(
                        title: Text("0.75"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _playerController!.setPlaybackSpeed(0.75);
                        },
                      ),
                      ListTile(
                        title: Text("Normal"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _playerController!.setPlaybackSpeed(1.0);
                        },
                      ),
                      ListTile(
                        title: Text("1.25"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _playerController!.setPlaybackSpeed(1.25);
                        },
                      ),
                      ListTile(
                        title: Text("1.5"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _playerController!.setPlaybackSpeed(1.5);
                        },
                      ),
                      ListTile(
                        title: Text("2.0"),
                        onTap: () {
                          Navigator.of(context).pop();
                          _playerController!.setPlaybackSpeed(2.0);
                        },
                      ),
                    ]))
              ]),
            ),
          );
        });
  }
}
