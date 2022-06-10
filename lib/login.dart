import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:ppsflutter/DatabaseHelper.dart';
import 'package:ppsflutter/SizeConfig.dart';
import 'package:ppsflutter/Utils.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:ppsflutter/color_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomeScreen.dart';
import 'ResetPassword.dart';
import 'databaseModel/Bookmark.dart';
import 'databaseModel/ExpertSeries.dart';
import 'databaseModel/Notes.dart';
import 'databaseModel/SpecialityModule.dart';
import 'databaseModel/SubCategory.dart';

class Login extends StatefulWidget {
  var loginErrorMessage;

  Login(this.loginErrorMessage);

  @override
  _LoginState createState() => _LoginState(loginErrorMessage);
}

void setInitialValues(String username, String password) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
  await prefs.setString('password', password);
}

class _LoginState extends State<Login> {
  var _login;
  var _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var loginErrorMessage;
  bool _isObscureText = true;
  late DatabaseHelper dbHelper;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _LoginState(this.loginErrorMessage);

  @override
  void initState() {
    super.initState();
    DatabaseHelper.instance.databse.then((onValue) {
      dbHelper = DatabaseHelper.instance;
      SharedPreferences.getInstance().then((value) {
        value.getBool('isAppOpenFirstTime') == null
            ? isAppOpenFirstTime = true
            : isAppOpenFirstTime = false;
        if (value.getString("username") != null &&
            value.getString("password") != null) {
          setState(() {
            loginErrorMessage = null;
            _login = WebHelper.postLogin(
                    context, emailController.text, passwordController.text)
                .then((login) {
              if (WebHelper.login!.ok! &&
                  WebHelper.login!.categories != null &&
                  WebHelper.login!.subscriptions != null) {
                setInitialValues(emailController.text, passwordController.text);
                Future.wait([
                  WebHelper.postUltimateSurvival(),
                  WebHelper.postBattleTested(),
                  WebHelper.postQuickStartTutorials()
                ]).then((value) {
                  WebHelper.ultimateSurvival!.items!.forEach((element) {
                    dbHelper.insertSpecialityModule(SpecialityModule(
                            element.objectId,
                            element.title,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null)
                        .toJson());
                  });

                  WebHelper.quickStartTutorial!.items!.forEach((element) {
                    dbHelper.insertQuickStartTutorial({
                      'title': element.title,
                      'object_id': element.objectId
                    });
                  });

                  WebHelper.battleTested!.items!.forEach((element) {
                    dbHelper.insertExpertSeries(ExpertSeries(
                            element.objectId,
                            element.title,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            null)
                        .toJson());
                    element.children!.forEach((element) {
                      dbHelper.insertSubCategory(SubCategory(
                              element.objectId,
                              element.title,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null,
                              null)
                          .toJson());
                    });
                  });

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeScreen(),
                  ));
                });
              } else {
                setState(() {
                  if (!WebHelper.login!.ok!) {
                    loginErrorMessage = WebHelper.login!.msg;
                  } else {
                    loginErrorMessage =
                        'Sorry, you don\'t have any active products...';
                  }
                });
              }
            });
          });
        } else {
          setState(() {
            loginErrorMessage = null;
            _login = null;
          });
        }
      });
    });
  }

  FocusNode _focusNodeEmail = FocusNode();
  FocusNode _focusNodePassword = FocusNode();

  @override
  Widget build(BuildContext context) {
    double height = SizeConfig.heightMultiplier * 10;
    print(loginErrorMessage.toString() +
        "  " +
        Utils.isLoginFromSharedPreference.toString() +
        "  " +
        _login.toString());
    return (loginErrorMessage == null && Utils.isLoginFromSharedPreference) ||
            _login != null
        ? Scaffold(
            key: _scaffoldKey,
            body: Stack(
              children: <Widget>[
                Container(
                  child: AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.aspectRatio,
                    child: Image(
                      image: AssetImage('assets/images/splash_bg.png'),
                      fit: BoxFit.fill, // use this
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: SizeConfig.heightMultiplier * 4),
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                    ),
                  ),
                )
              ],
            ),
          )
        : Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text(
                "Member Login",
              ),
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
                    loginErrorMessage != null &&
                            !loginErrorMessage
                                .toString()
                                .contains('our website') &&
                            !loginErrorMessage.toString().contains('Sorry')
                        ? Padding(
                            padding: EdgeInsets.only(top: height / 2),
                            child: Container(
                              height: height / 2,
                              width: double.infinity,
                              decoration: BoxDecoration(color: Colors.red),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Your email or password are incorrect.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize:
                                                SizeConfig.textMultiplier *
                                                    1.3),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                            builder: (context) =>
                                                ResetPassoword(),
                                          ));
                                        },
                                        child: Text(
                                          'Forgot your password? Reset it here.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize:
                                                  SizeConfig.textMultiplier *
                                                      1.3,
                                              decoration:
                                                  TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : loginErrorMessage.toString().contains('our website')
                            ? Builder(builder: (context) {
                                List<String> msg =
                                    loginErrorMessage.toString().split('**');
                                return Container(
                                  color: Colors.red,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: HtmlWidget(
                                      "<p>" +
                                          msg[0] +
                                          "<a href='https://www.positiveparentingsolutions.com/webinar-pricing'><b> our website </b></a> " +
                                          msg[1].replaceAll('our website', '') +
                                          "</p>",
                                      hyperlinkColor: Colors.white,
                                      textStyle: TextStyle(
                                          fontSize:
                                              SizeConfig.textMultiplier * 1.4,
                                          color: Colors.white),
                                    ),
                                  ),
                                );
                              })
                            : loginErrorMessage != null
                                ? Padding(
                                    padding: EdgeInsets.only(top: height / 2),
                                    child: Container(
                                      height: height / 2,
                                      width: double.infinity,
                                      decoration:
                                          BoxDecoration(color: Colors.red),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                loginErrorMessage,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: SizeConfig
                                                            .textMultiplier *
                                                        1.3),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                  ],
                  alignment: Alignment.bottomLeft,
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
            body: loginWidget(context),
          );
  }

  @override
  void dispose() {
    super.dispose();
    loginErrorMessage = null;
    _login = null;
  }

  Widget loginWidget(BuildContext context) {
    _focusNodeEmail.addListener(() {
      setState(() {});
    });

    _focusNodePassword.addListener(() {
      setState(() {});
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Your Email",
                      prefixIcon: Icon(
                        Icons.person,
                        color: _focusNodeEmail.hasFocus
                            ? Color(0xFF442d53)
                            : Colors.grey.withAlpha(100),
                      ),
                      contentPadding: EdgeInsets.zero,
                      labelStyle: TextStyle(
                        color: _focusNodeEmail.hasFocus
                            ? Color(0xFF442d53)
                            : Colors.grey.withAlpha(100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.grey.withAlpha(100),
                        ),
                      ),
                    ),
                    controller: emailController,
                    focusNode: _focusNodeEmail,
                    style: TextStyle(fontSize: SizeConfig.textMultiplier * 2),
                    cursorColor: Color(0xFF442d53),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please enter your email";
                      } else {
                        return null;
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: TextFormField(
                      obscureText: _isObscureText,
                      focusNode: _focusNodePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        contentPadding: EdgeInsets.zero,
                        labelStyle: TextStyle(
                          color: _focusNodePassword.hasFocus
                              ? Color(0xFF442d53)
                              : Colors.grey.withAlpha(100),
                        ),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: _focusNodePassword.hasFocus
                              ? Color(0xFF442d53)
                              : Colors.grey.withAlpha(100),
                        ),
                        suffixIcon: IconButton(
                            icon: _isObscureText
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscureText = !_isObscureText;
                              });
                            }),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color: Colors.grey.withAlpha(100),
                          ),
                        ),
                      ),
                      controller: passwordController,
                      style: TextStyle(fontSize: SizeConfig.textMultiplier * 2),
                      cursorColor: Color(0xFF442d53),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter your password";
                        } else {
                          return null;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: ColorUtils.loginButtonGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: MaterialButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      DatabaseHelper.instance.databse.then((onValue) {
                        if (Utils.isInternetAvailable) {
                          setState(() {
                            loginErrorMessage = null;
                            _login = WebHelper.postLogin(
                                    context,
                                    emailController.text,
                                    passwordController.text)
                                .then((login) {
                              if (WebHelper.login!.ok! &&
                                  WebHelper.login!.categories != null &&
                                  WebHelper.login!.subscriptions != null) {
                                if (WebHelper.login!.categories != null &&
                                    WebHelper.login!.categories!.userLevel !=
                                        null &&
                                    WebHelper.login!.categories!.userLevel!.keys
                                            .first !=
                                        '3') {
                                  setInitialValues(emailController.text,
                                      passwordController.text);
                                  Future.wait([
                                    WebHelper.postUltimateSurvival(),
                                    WebHelper.postBattleTested(),
                                    WebHelper.postQuickStartTutorials()
                                  ]).then((value) {
                                    WebHelper.ultimateSurvival!.items!
                                        .forEach((element) {
                                      dbHelper.insertSpecialityModule(
                                          SpecialityModule(
                                                  element.objectId,
                                                  element.title,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null,
                                                  null)
                                              .toJson());
                                    });

                                    WebHelper.quickStartTutorial!.items!
                                        .forEach((element) {
                                      dbHelper.insertQuickStartTutorial({
                                        'title': element.title,
                                        'object_id': element.objectId
                                      });
                                    });

                                    WebHelper.battleTested!.items!
                                        .forEach((element) {
                                      dbHelper.insertExpertSeries(ExpertSeries(
                                              element.objectId,
                                              element.title,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null,
                                              null)
                                          .toJson());
                                      element.children!.forEach((element) {
                                        dbHelper.insertSubCategory(SubCategory(
                                                element.objectId,
                                                element.title,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null,
                                                null)
                                            .toJson());
                                      });
                                    });

                                    _syncData(context);
                                    Navigator.of(context)
                                        .pushReplacement(MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ));
                                  });
                                } else {
                                  setState(() {
                                    _login = null;
                                    loginErrorMessage =
                                        'You do not have access to this mobile app. Please visit **our website to upgrade to Gold or Silver membership in order to gain full access to this application.';
                                  });
                                }
                              } else {
                                print('Login Error');
                                setState(() {
                                  if (!WebHelper.login!.ok!) {
                                    _login = null;
                                    loginErrorMessage = WebHelper.login!.msg;
                                  } else {
                                    _login = null;
                                    loginErrorMessage =
                                        'Sorry, you don\'t have any active products...';
                                  }
                                });
                              }
                            });
                          });
                        } else {
                          Utils.showNoInternetSnackBarWithHide(_scaffoldKey);
                        }
                      });
                    }
                  },
                  /*Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => HomeScreen(),
                    ));*/
                  child: Text(
                    "LOGIN",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConfig.textMultiplier * 1.8),
                  ),
                ),
              ),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ResetPassoword(),
                  ));
                },
                child: Text(
                  "Forgot your password? Reset it here.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConfig.textMultiplier * 1.7,
                    color: Color(0xFF442d53),
                    decoration: TextDecoration.underline,
                  ),
                )),
            Platform.isAndroid
                ? HtmlWidget(
                    "<center>"
                            "<p style=font-size: 2vw;>"
                            "You must be enrolled in "
                            "<b><i>" +
                        appThemeData.appName +
                        "</i></b> "
                            "to login. "
                            "<br><br>"
                            "For more information <a href='mailto:help@PositiveParentingSolutions.com'><b> email us </b></a> "
                            "or attend one of our <a href='https://www.positiveparentingsolutions.com/web-free-webinars'><b>free webinars</b></a>"
                            "</p>"
                            "</center>",
                    hyperlinkColor: Color(0xFF442d53),
                    textStyle: TextStyle(
                        fontSize: SizeConfig.textMultiplier * 1.65,
                        color: Colors.grey),
                  )
                : HtmlWidget(
                    "<center>"
                            "<p style=font-size: 2vw;>"
                            "You must be enrolled in "
                            "<b><i>" +
                        appThemeData.appName +
                        "</i></b> "
                            "to login. "
                            "</p>"
                            "</center>",
                    hyperlinkColor: Color(0xFF442d53),
                    textStyle: TextStyle(
                        fontSize: SizeConfig.textMultiplier * 1.65,
                        color: Colors.grey),
                  )
          ],
        ),
      ),
    );
  }

  void _syncData(BuildContext context) async {
    print("Syncing data");
    SharedPreferences preferences = await SharedPreferences.getInstance();

    setState(() {
      WebHelper.isBookmarkSync = true;
      preferences.setBool('isBookmarkSync', true);
      WebHelper.isNoteSync = true;
      preferences.setBool('isNoteSync', true);
    });

    dbHelper.insertBookmarkFromAPI().then((value) async {
      List<Bookmark> bookmarks = [];
      List<Map<String, dynamic>> data = await dbHelper.queryAll("Bookmark");
      data.forEach((element) {
        bookmarks.add(Bookmark.fromJson(element));
      });
      WebHelper.postAddBookmark(context, bookmarks);
    });

    dbHelper.insertNoteFromAPI().then((value) async {
      List<Notes> notes = [];
      List<Map<String, dynamic>> noteData = await dbHelper.queryAll("Notes");
      noteData.forEach((element) {
        notes.add(Notes.fromJson(element));
      });
      WebHelper.postAddNotes(context, notes);
    });
  }
}
