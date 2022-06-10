import 'package:flutter/material.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:ppsflutter/color_utils.dart';
import 'AppDrawer.dart';
import 'PDFFileViewer.dart';
import 'PlayAudio.dart';
import 'PlayVideo.dart';
import 'SizeConfig.dart';
import 'Utils.dart';
import 'appThemeData.dart';

class FreeIntroWebinar extends StatefulWidget {
  @override
  _FreeIntroWebinarState createState() => _FreeIntroWebinarState();
}

final String WEBINAR_DESC = "In this introductory class, you'll discover why kids really misbehave, how your personality may cause your kids to fight" +
    " back and a 5-step No-Yelling formula for consequences.\n\nTo learn all the tools in The Toolbox, proceed through Sessions 1-7 of the course.";

class _FreeIntroWebinarState extends State<FreeIntroWebinar> {

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.heightMultiplier * 11;
    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            'Free Intro Webinar',
            style: TextStyle(fontSize: SizeConfig.isMobilePortrait ? SizeConfig.textMultiplier * 2.2 : SizeConfig.textMultiplier * 1.5),
          ),
        ),
        titleSpacing: 0.0,
        backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
        bottom: PreferredSize(
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: height,
                child: Image.asset(
                  app_images.SPLASH_IMAGE,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0),
                child: Text(
                  'Get kids to listen without nagging, reminding or yelling',
                  maxLines: 2,
                  style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 2.5, fontFamily: 'AppleGaramondBold'),
                ),
              )
            ],
          ),
          preferredSize: Size(double.infinity, height),
        ),
      ),
      drawer: AppDrawer(null),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            createGradientButton("WORKBOOK", ColorUtils.greenButtonGradient, 'assets/images/article.png',
                "https://www.positiveparentingsolutions.com/app/content/pdf/Workbook-FREE_WEBINAR-Members.pdf", 'pdf'),
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: Text(
                WEBINAR_DESC,
                style: TextStyle(fontFamily: 'OpenSans-Regular', fontSize: SizeConfig.textMultiplier * 1.9, color: Colors.black),
              ),
            ),
            createGradientButton("VIEW WEBINAR", ColorUtils.loginButtonGradient, 'assets/images/video.png',
                "https://player.vimeo.com/external/289894694.sd.mp4?s=63b1cedae93b3ed37c314867991cc054281bec04&profile_id=164", 'video'),
          ],
        ),
      ),
    );
  }

  Widget createGradientButton(String title, List<Color> colorList, String iconPath, String link, String linkType) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colorList, begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: MaterialButton(
        onPressed: () {
          if (linkType == 'pdf') {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PDFFileViewer("Free intro webinar", link)));
          } else if (linkType == 'audio') {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlayAudio(title, link)));
          } else if (linkType == 'video') {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlayVideo(title, link)));
          }
        },
        child: iconPath == null
            ? Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 1.6, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              transform: Matrix4.translationValues(-8.0, 0.0, 0.0),
              child: Image.asset(
                iconPath,
                scale: 4,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConfig.textMultiplier * 2.3,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'BebasNeue',
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
