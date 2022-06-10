import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ppsflutter/HomeScreen.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/app_images.dart';

import 'SizeConfig.dart';
import 'Utils.dart';
import 'color_utils.dart';

class InteractiveResult extends StatefulWidget {
  int superiorityScore = 0, pleasingScore = 0, controllingScore = 0, comfortingScore = 0;

  InteractiveResult(this.superiorityScore, this.pleasingScore, this.controllingScore, this.comfortingScore);

  @override
  _InteractiveResultState createState() => _InteractiveResultState(superiorityScore, pleasingScore, controllingScore, comfortingScore);
}

class _InteractiveResultState extends State<InteractiveResult> {
  int _superiorityScore = 0, _pleasingScore = 0, _controllingScore = 0, _comfortingScore = 0;

  _InteractiveResultState(this._superiorityScore, this._pleasingScore, this._controllingScore, this._comfortingScore);

  Map scores = {};

  @override
  Widget build(BuildContext context) {
    scores[_superiorityScore] = 'Superiority';
    scores[_pleasingScore] = 'Pleasing';
    scores[_controllingScore] = 'Controlling';
    scores[_comfortingScore] = 'Comforting';

    return Scaffold(
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Your Personality Score',
                    maxLines: 2,
                    style: TextStyle(
                        color: Colors.white, fontSize: SizeConfig.textMultiplier * 2.3, fontStyle: FontStyle.italic, fontFamily: 'AppleGaramondItalic'),
                  ),
                ),
              )
            ],
          ),
          preferredSize: Size(double.infinity, SizeConfig.heightMultiplier * 9),
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Superiority',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7, color: Utils.getColorFromHex(appThemeData.appBarColor)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Controlling',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7, color: Utils.getColorFromHex(appThemeData.appBarColor)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Pleasing',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7, color: Utils.getColorFromHex(appThemeData.appBarColor)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Comforting',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7, color: Utils.getColorFromHex(appThemeData.appBarColor)),
                        ),
                      ),
                    ],
                  )),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Container(height: SizeConfig.heightMultiplier * 8, child: VerticalDivider(color: Colors.grey)),
                  ),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _superiorityScore.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7),
                        ),
                      ),
                      Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              _controllingScore.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7),
                            ),
                          ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _pleasingScore.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _comfortingScore.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7),
                        ),
                      )
                    ],
                  )),
                ],
              ),

              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  'Your Primary Personality Priority is',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7, color: Utils.getColorFromHex(appThemeData.appBarColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  scores[(scores.keys.toList()..sort())[(scores.keys.toList()..sort()).length - 1]],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.9),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Text(
                  'Your Secondary Personality Priority is',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.7, color: Utils.getColorFromHex(appThemeData.appBarColor)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  scores[(scores.keys.toList()..sort())[(scores.keys.toList()..sort()).length - 2]],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: SizeConfig.heightMultiplier * 1.9),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0),
                  child: Text(
                    'Write down these scores for easy reference.',
                    style: TextStyle(fontSize: SizeConfig.heightMultiplier * 1.4, color: Colors.grey),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Continue on to discover how your Personality Priority affects your parenting style.',
                    style: TextStyle(fontSize: SizeConfig.heightMultiplier * 1.3, color: Colors.grey),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: ColorUtils.greenButtonGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                      borderRadius: BorderRadius.all(Radius.circular(2))),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: Text(
                      'Okay',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
