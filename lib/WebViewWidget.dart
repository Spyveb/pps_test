import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/webModel/WebSpecialityModule.dart';
import 'package:webview_flutter/webview_flutter.dart';


class WebViewWidget extends StatelessWidget {

  String url;

  WebViewWidget(this.url);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: WebHelper.fetchSpecialityModule(url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print("WebView");
          WebSpecialityModule module = snapshot.data as WebSpecialityModule;
          return WebView(
            initialUrl: buildWebString(module.acf!.appContent!),
          );
        } else {
          return Center(child: CircularProgressIndicator(),);
        }
      },
    );
  }

  /*WebView(
  initialUrl: webUrl,
  javascriptMode: JavascriptMode.unrestricted,
  onWebViewCreated: (WebViewController webViewController) {
  _controller.complete(webViewController);
  },
  onPageFinished: (val) {
  setState(() {
  _isLoading = false;
  });
  },
  ),
*/
  String buildWebString(String data) {
    return Uri.dataFromString(data,
        mimeType: "text/html", encoding: Encoding.getByName('utf-8'))
        .toString();
  }
}


