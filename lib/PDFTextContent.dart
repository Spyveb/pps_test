import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:ppsflutter/HomeScreen.dart';
import 'package:ppsflutter/Utils.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:ppsflutter/webModel/ArticleText.dart';

import 'SizeConfig.dart';

class PDFTextContent extends StatefulWidget {
  String articleId;
  PDFTextContent(this.articleId);

  @override
  _PDFTextContentState createState() => _PDFTextContentState();
}

String headerSubTitle = "";

class _PDFTextContentState extends State<PDFTextContent> {
  ArticleText? articleText;

  @override
  void initState() {
    super.initState();
    WebHelper.getArticleText(widget.articleId).then((value) {
      setState(() {
        articleText = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.heightMultiplier * 12;
    String _final = "";

    if (articleText != null) {
      String replaseH2 = articleText!.content!.rendered!
          .replaceAll('<h2>', '<h3 style="color:#969;">');
      _final = replaseH2.replaceAll('<h1>', '<h2 style="color:#969;">');
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 10.0,
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            appThemeData.appName.replaceAll('The ', ''),
            style: TextStyle(
                fontSize: SizeConfig.isMobilePortrait
                    ? SizeConfig.textMultiplier * 1.6
                    : SizeConfig.textMultiplier * 1.5),
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
                padding: EdgeInsets.only(
                  left: SizeConfig.widthMultiplier * 3,
                  right: SizeConfig.widthMultiplier * 1.5,
                  top: SizeConfig.widthMultiplier * 3,
                ),
                child: Text(
                  articleText != null
                      ? HtmlUnescape().convert(articleText!.title!.rendered!)
                      : "",
                  maxLines: 2,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: height / 5.3,
                      fontFamily: 'AppleGaramondBold'),
                ),
              ),
            ],
          ),
          preferredSize: Size(double.infinity, height),
        ),
        actions: <Widget>[
          Image.asset(
            app_images.LOGO_ICON,
            scale: 3,
          ),
        ],
      ),
      body: Container(
          child: articleText != null
              ? Padding(
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 16.0, bottom: 24.0),
                  child: SingleChildScrollView(
                    child: HtmlWidget(
                      _final.replaceAll(
                          '<span>', '<span style="color:#E4B358;">'),
                      webView: true,
                      textStyle: TextStyle(
                        fontSize: SizeConfig.textMultiplier * 2.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}
