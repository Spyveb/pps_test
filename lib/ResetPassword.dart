import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/app_images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'SizeConfig.dart';
import 'Utils.dart';
import 'color_utils.dart';

class ResetPassoword extends StatefulWidget {
  @override
  _ResetPassowordState createState() => _ResetPassowordState();
}

class _ResetPassowordState extends State<ResetPassoword> {
  var _formKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  double height = SizeConfig.heightMultiplier * 10;
  var resetErrorMessage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool validate = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Reset Passord",
        ),
        backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
        bottom: PreferredSize(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: height,
                child: Image.asset(
                  app_images.SPLASH_IMAGE,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),

              resetErrorMessage != null
                  ? Padding(
                padding: EdgeInsets.only(top: height / 1.5),
                child: Container(
                  height: height / 2.5,
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
                            'The Email does not exist in the system. Please try again.',
                            style: TextStyle(color: Colors.white, fontSize: SizeConfig.textMultiplier * 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : Container(),
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
      body: FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            SharedPreferences? pref = snapshot.data as SharedPreferences;
            return Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            decoration: InputDecoration(labelText: "Your Email", errorText: validate ? 'This field is require.' : null),
                            controller: emailController,
                            style: TextStyle(fontSize: SizeConfig.textMultiplier * 2),
                            cursorColor: Color(0xFF442d53),
                            onChanged: (string){
                              setState(() {
                                validate = false;
                              });
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Your Email";
                              } else {
                                return null;
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: ColorUtils.loginButtonGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: MaterialButton(
                        onPressed: () {
                          if(Utils.isInternetAvailable) {
                            if (emailController.text
                                .trim()
                                .isNotEmpty) {
                              setState(() {
                                validate = false;
                                resetErrorMessage = null;
                              });
                              Duration? timeDifference;
                              if (pref.getInt('reset_pass_timer') != null) {
                                int timestamp = pref.getInt('reset_pass_timer')!;
                                DateTime before = DateTime.fromMillisecondsSinceEpoch(timestamp);
                                DateTime now = DateTime.now();
                                timeDifference = now.difference(before);
                              }

                              if (timeDifference == null || timeDifference.inMinutes > 5) {
                                WebHelper.postResetPassword(emailController.text).then((value) {
                                  final response = json.decode(value!);
                                  if (response['ok'] == true) {
                                    pref.setInt('reset_pass_timer', DateTime
                                        .now()
                                        .millisecondsSinceEpoch);
                                    pref.setString('reset_pass_msg', response['msg']);
                                    showMsgDialog(response['msg']);
                                    print('PASSWORD RESET');
                                  } else {
                                    //Show error
                                    setState(() {
                                      resetErrorMessage = response;
                                    });
                                  }
                                });
                              } else {
                                //Wait Dialog
                                showMsgDialog(pref.getString('reset_pass_msg'));
                              }
                            } else {
                              setState(() {
                                validate = true;
                              });
                            }
                          } else {
                            Utils.showNoInternetSnackBarWithHide(_scaffoldKey);
                          }
                        },
                        child: Text(
                          "Reset Password",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: SizeConfig.textMultiplier * 1.8),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: ColorUtils.purpleGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: SizeConfig.textMultiplier * 1.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  showMsgDialog(String? msg) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: Text(msg!),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
