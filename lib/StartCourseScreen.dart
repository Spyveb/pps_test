import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:ppsflutter/DatabaseHelper.dart';
import 'package:ppsflutter/HomeScreen.dart';
import 'package:ppsflutter/color_utils.dart';
import 'package:ppsflutter/databaseModel/Course.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartCourseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DatabaseHelper.instance.queryCourses(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          List<Course> courses = snapshot.data as List<Course>;
          return Container(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: HtmlWidget(
                    courses[0].Description!.contains("h3")
                        ? courses[0].Description!.replaceAll("h3", "h3")
                        : courses[0].Description!,
                    webView: false,
                    textStyle: TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),

                Expanded(
                    flex: 0,
                    child: createGradientButton("START COURSE", ColorUtils.loginButtonGradient, null)
                ),
              ],
            ),
          );
        }else{
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  void setInitialValues(String? objectid, String sessionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessionId', sessionId);
    await prefs.setBool("isStepsEnabled", isStepsEnabled!);
    await prefs.setBool("isAppOpenFirstTime", false);
    print('Values Setted');
  }

  Widget createGradientButton(
      String title, List<Color> colorList, String? iconPath) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: colorList,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(5.0)),
      child: MaterialButton(
        onPressed: () {
          setInitialValues(null, '1');
        },
        child: Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
      ),
    );
  }
}
