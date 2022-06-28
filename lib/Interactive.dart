import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ppsflutter/InteractiveResult.dart';
import 'package:ppsflutter/Utils.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:ppsflutter/color_utils.dart';
import 'package:ppsflutter/databaseModel/Subtab.dart';

import 'DatabaseHelper.dart';
import 'SizeConfig.dart';

class Interactive extends StatefulWidget {
  int? isInteractive;
  int? id;
  String? type;
  String? _title;

  Interactive(this.isInteractive, this.id, this.type, this._title);

  @override
  _InteractiveState createState() => _InteractiveState(isInteractive, id, type, _title);
}

int selectedIndex = 0;

class _InteractiveState extends State<Interactive> {
  final int MOSTLY_MULTIPLIER = 4;
  final int OFTEN_MULTIPLIER = 3;
  final int SOMETIMES_MULTIPLIER = 2;
  final int NEVER_MULTIPLIER = 1;

  int superiorityScore = 0, pleasingScore = 0, controllingScore = 0, comfortingScore = 0;
  late int currentQuestionScore;
  int questionPageIndex = 0;
  int totalQuestions = 0;

  int? _isInteractive;
  bool _isAssessmentStarted = false;
  String? radioGroupValue = '';
  int? _id;
  String? _type;
  String? _title;
  final dbHelper = DatabaseHelper.instance;

  PageController _pageController = PageController(initialPage: 0);

  _InteractiveState(this._isInteractive, this._id, this._type, this._title);

  var scores = {};

  @override
  void dispose() {
    selectedIndex = 0;
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await (showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Are you sure?"),
            content: Text('Assessment data will be lost.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'YES',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _isAssessmentStarted ? _onWillPop : null,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Interactives"),
            backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
            bottom: PreferredSize(
              child: Stack(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: SizeConfig.heightMultiplier * 9,
                    child: Image.asset(
                      app_images.SPLASH_IMAGE,
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            HtmlUnescape().convert(_title!),
                            maxLines: 2,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.textMultiplier * 2.2,
                                fontStyle: FontStyle.italic,
                                fontFamily: 'AppleGaramondItalic'),
                          ),
                        ),
                      ),
                      _isAssessmentStarted
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'Question ' + (questionPageIndex + 1).toString() + ' of  ' + (_isInteractive != 3 ? totalQuestions : (totalQuestions - 1)).toString(),
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: SizeConfig.textMultiplier * 2.1,
                                      fontFamily: 'AppleGaramondBold'),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  )
                ],
              ),
              preferredSize: Size(double.infinity, SizeConfig.heightMultiplier * 9),
            ),
          ),
          body: FutureBuilder<List<Subtab>>(
            future: dbHelper.querySubTabs(_id, _type),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (_isInteractive != 3) {
                  totalQuestions = snapshot.data![0].content!.split('\$##\$').length;
                } else {
                  totalQuestions = snapshot.data!.length;
                }
                if (_type == 'interactive') {
                  return _isInteractive == 2 ? createInteractive(snapshot.data) : createAssessment(snapshot.data);
                } else {
                  return createInteractive(snapshot.data);
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
    );
  }

  Widget createInteractive(List<Subtab>? subTabs) {
    return LayoutBuilder(builder: (context, constraint) {
      return ListView.builder(
        itemCount: subTabs!.length,
        itemBuilder: (context, index) {
          return ConfigurableExpansionTile(
            key: GlobalKey(),
            initiallyExpanded: index == selectedIndex,
            onExpansionChanged: (val) {
              print('onExpansionChanged => $index');
              if (val) {
                setState(() {
                  selectedIndex = index;
                });
              } else {
                setState(() {
                  selectedIndex = -1;
                });
              }
            },
            header: Container(
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: ColorUtils.greenGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              width: constraint.maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Align(
                          child: Text(
                            subTabs[index].title!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.textMultiplier * 1.9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans-Bold'),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            headerExpanded: Container(
              decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: ColorUtils.greenGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              width: constraint.maxWidth,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.keyboard_arrow_up,
                            color: Colors.white,
                          ),
                        )),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Align(
                          child: Text(
                            subTabs[index].title!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.textMultiplier * 1.9,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans-Bold'),
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: HtmlWidget(
                    subTabs[index].content!,
                    webView: false,
                    textStyle: TextStyle(fontSize: SizeConfig.textMultiplier * 1.8, fontFamily: 'OpenSans-Regular'),
                  ),
                ),
              )
            ],
          );
        },
      );
    });
  }

  Widget createAssessment(List<Subtab>? subTabs) {
    return !_isAssessmentStarted
        ? Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Utils.getColorFromHex('#f0f0f0')),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: 16.0),
                  child: HtmlWidget(
                    _isInteractive != 3 ? subTabs![0].title! : subTabs![0].content!,
                    textStyle: TextStyle(
                        color: Utils.getColorFromHex(appThemeData.appBarColor), fontSize: SizeConfig.heightMultiplier * 2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: ColorUtils.greenButtonGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                        borderRadius: BorderRadius.all(Radius.circular(2))),
                    child: MaterialButton(
                      onPressed: () {
                        setState(() {
                          _isAssessmentStarted = true;
                        });
                      },
                      child: Text(
                        'Start Assessment',
                        style:
                            TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isInteractive != 3
                ? Container(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: subTabs![0].content!.split('\$##\$').length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                          decoration: BoxDecoration(color: Utils.getColorFromHex('#f0f0f0')),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 32.0, bottom: 16.0, left: 8.0),
                                child: HtmlWidget(
                                  subTabs[0].content!.split('\$##\$')[index],
                                  textStyle: TextStyle(
                                      color: Utils.getColorFromHex(appThemeData.appBarColor),
                                      fontSize: SizeConfig.textMultiplier * 2.2),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      radioGroupValue = 'Most of the time';
                                      currentQuestionScore = MOSTLY_MULTIPLIER;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: 'Most of the time',
                                        groupValue: radioGroupValue,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            radioGroupValue = value;
                                            currentQuestionScore = MOSTLY_MULTIPLIER;
                                          });
                                        },
                                      ),
                                      Text('Most of the time', style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.8)),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      radioGroupValue = 'Often';
                                      currentQuestionScore = OFTEN_MULTIPLIER;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: 'Often',
                                        groupValue: radioGroupValue,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            radioGroupValue = value;
                                            currentQuestionScore = OFTEN_MULTIPLIER;
                                          });
                                        },
                                      ),
                                      Text('Often', style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.8))
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      radioGroupValue = 'Sometimes';
                                      currentQuestionScore = SOMETIMES_MULTIPLIER;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: 'Sometimes',
                                        groupValue: radioGroupValue,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            radioGroupValue = value;
                                            currentQuestionScore = SOMETIMES_MULTIPLIER;
                                          });
                                        },
                                      ),
                                      Text('Sometimes', style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.8))
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      radioGroupValue = 'Almost never';
                                      currentQuestionScore = NEVER_MULTIPLIER;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Radio(
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        value: 'Almost never',
                                        groupValue: radioGroupValue,
                                        onChanged: (dynamic value) {
                                          setState(() {
                                            radioGroupValue = value;
                                            currentQuestionScore = NEVER_MULTIPLIER;
                                          });
                                        },
                                      ),
                                      Text('Almost never', style: TextStyle(fontSize: SizeConfig.textMultiplier * 1.8))
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: ColorUtils.greenButtonGradient,
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter),
                                        borderRadius: BorderRadius.all(Radius.circular(2))),
                                    child: MaterialButton(
                                      onPressed: () {
                                        if (questionPageIndex != subTabs[0].content!.split('\$##\$').length) {
                                          if (radioGroupValue != '') {
                                            if (questionPageIndex < 8 && questionPageIndex >= 0) {
                                              superiorityScore += currentQuestionScore;
                                            } else if (questionPageIndex < 16 && questionPageIndex >= 8) {
                                              controllingScore += currentQuestionScore;
                                            } else if (questionPageIndex < 24 && questionPageIndex >= 16) {
                                              pleasingScore += currentQuestionScore;
                                            } else if (questionPageIndex < 32 && questionPageIndex >= 24) {
                                              comfortingScore += currentQuestionScore;
                                            }

                                            if (questionPageIndex != subTabs[0].content!.split('\$##\$').length - 1) {
                                              setState(() {
                                                radioGroupValue = '';
                                                currentQuestionScore = 0;
                                              });
                                              _pageController.jumpToPage(questionPageIndex += 1);
                                            } else {
                                              //Show Result
                                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                                  builder: (context) => InteractiveResult(
                                                      superiorityScore, pleasingScore, controllingScore, comfortingScore)));
                                            }
                                          }
                                        }
                                      },
                                      child: Text(
                                        questionPageIndex != subTabs[0].content!.split('\$##\$').length - 1
                                            ? 'Next Question'
                                            : 'Show Result',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: SizeConfig.textMultiplier * 2,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Container(
                    child: FutureBuilder<List<Subtab>>(
                      future: dbHelper.querySubTabs(_id, 'interactive'),
                      builder: (context, snapshot) {
                        print('Interactive ID => $_id');
                        if (snapshot.hasData) {
                          return Container(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: snapshot.data!.length,
                              physics: NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(color: Utils.getColorFromHex('#f0f0f0')),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 32.0, bottom: 16.0, left: 16.0),
                                        child: HtmlWidget(
                                          snapshot.data![index + 1].title!,
                                          textStyle: TextStyle(color: Utils.getColorFromHex(appThemeData.appBarColor)),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Encouragement',
                                                  groupValue: radioGroupValue,
                                                  onChanged: (dynamic value) {
                                                    setState(() {
                                                      radioGroupValue = value;
                                                    });
                                                  },
                                                ),
                                                InkWell(
                                                  child: Text('Encouragement'),
                                                  onTap: () {
                                                    setState(() {
                                                      radioGroupValue = 'Encouragement';
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                            child: Row(
                                              children: [
                                                Radio(
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  value: 'Praise',
                                                  groupValue: radioGroupValue,
                                                  onChanged: (dynamic value) {
                                                    setState(() {
                                                      radioGroupValue = value;
                                                    });
                                                  },
                                                ),
                                                InkWell(
                                                  child: Text('Praise'),
                                                  onTap: () {
                                                    setState(() {
                                                      radioGroupValue = 'Praise';
                                                    });
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                          child: radioGroupValue != ''
                                              ? SingleChildScrollView(
                                                  child: HtmlWidget(
                                                    radioGroupValue == 'Encouragement'
                                                        ? snapshot.data![index + 1].content!.split('\$##\$')[1]
                                                        : snapshot.data![index + 1].content!.split('\$##\$')[0],
                                                    textStyle: TextStyle(fontSize: SizeConfig.heightMultiplier * 1.6),
                                                    webView: false,
                                                  ),
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 0,
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 16.0),
                                            child: Container(
                                              height: 48,
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: ColorUtils.greenButtonGradient,
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter),
                                                  borderRadius: BorderRadius.all(Radius.circular(2))),
                                              child: MaterialButton(
                                                onPressed: () {
                                                  if (questionPageIndex != snapshot.data!.length - 2) {
                                                    if (radioGroupValue != '') {
                                                      setState(() {
                                                        radioGroupValue = '';
                                                      });
                                                      _pageController.jumpToPage(questionPageIndex += 1);
                                                    }
                                                  } else {
                                                    showThankYouDialog();
                                                  }
                                                },
                                                child: Text(
                                                  questionPageIndex != snapshot.data!.length - 2 ? 'Next Question' : 'Done',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ));
  }

  showThankYouDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text('Thank you for taking the assessment.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              Navigator.of(context).pop(true);
            },
            child: Text(
              'OKAY',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
