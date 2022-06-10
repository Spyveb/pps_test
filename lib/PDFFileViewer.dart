import 'dart:async';
import 'dart:io' show File, Platform;

import 'package:android_intent/android_intent.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:ppsflutter/AppDrawer.dart';
import 'package:printing/printing.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart' as webView;

import 'SizeConfig.dart';
import 'Utils.dart';
import 'WebHelper.dart';
import 'appThemeData.dart';

class PDFFileViewer extends StatefulWidget {
  String? fileName, uri;

  PDFFileViewer(this.fileName, this.uri);

  @override
  _PDFFileViewerState createState() => _PDFFileViewerState();
}

class _PDFFileViewerState extends State<PDFFileViewer> {
  final _completer = new Completer.sync();
  var _isLoading = true;
  bool _isForMainFrame = true;
  String? startUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var pdfData;
  bool needToOpenPrint = false;
  bool _isFileDownloaded = false;
  BuildContext? dialogContext;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((dir) {
      print('PDF URI :: ${widget.uri}');
      Dio().downloadUri(Uri.parse(widget.uri!), '${dir.path}/printDoc.pdf', options: Options(headers: {'User-Agent': 'Mozilla/5.0'})).then((value) {
        File file = File('${dir.path}/printDoc.pdf');
        pdfData = file.readAsBytesSync();
        _isFileDownloaded = true;
        print("FILE DOWNLOADED");
        if (needToOpenPrint) {
          needToOpenPrint = false;
          if (dialogContext != null) Navigator.pop(dialogContext!);
          Printing.layoutPdf(onLayout: ((PdfPageFormat format) async => pdfData));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.fileName!,
          style: TextStyle(
              fontSize: SizeConfig.isMobilePortrait ? SizeConfig.textMultiplier * 1.6 : SizeConfig.textMultiplier * 1.5),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.print),
              onPressed: () {
                if (_isFileDownloaded) {
                  Printing.layoutPdf(onLayout: ((PdfPageFormat format) async => pdfData));
                } else {
                  needToOpenPrint = true;
                  _onLoading();
                }
              }),
          IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: () {
                if (Platform.isAndroid) {
                  AndroidIntent intent = AndroidIntent(
                    action: 'action_view',
                    type: 'application/pdf',
                    data: widget.uri,
                  );
                  intent.launch();
                } else {
                  Share.share(widget.uri!);
                }
              })
        ],
        titleSpacing: 0.0,
        backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
      ),
      drawer: widget.fileName == 'Backtalk Battles Guide' ? AppDrawer(null) : null,
      body: Utils.isInternetAvailable
          ? Stack(
              children: <Widget>[
                webView.WebView(
                  initialUrl: 'https://docs.google.com/viewer?embedded=true&url=${widget.uri}',
                  debuggingEnabled: true,
                  javascriptMode: webView.JavascriptMode.unrestricted,
                  onWebViewCreated: (webView.WebViewController _controller) {
                    _completer.complete(_controller);
                    /*if (_completer.isCompleted) {
                _completer.future.then((value) {
                  webView.WebViewController webController = value;
                  webController.loadUrl(
                      'https://docs.google.com/viewer?embedded=true&url=${widget.uri}');
                });
              }*/
                  },
                  onPageFinished: (string) {
                    print("Page Loading Finish: " + string);
                    if (string == "about:blank" || startUrl != string || (_isForMainFrame && Platform.isIOS)) {
                      setState(() {
                        _isLoading = true;
                        _completer.future.then((value) {
                          webView.WebViewController webController = value;
                          webController.loadUrl('https://docs.google.com/viewer?embedded=true&url=${widget.uri}');
                        });
                      });
                    } else {
                      if (startUrl == string) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  navigationDelegate: (request) {
                    print(request);
                    _isForMainFrame = request.isForMainFrame;
                    return webView.NavigationDecision.navigate;
                  },
                  onPageStarted: (string) {
                    print("Page Loading Start: " + string);
                    startUrl = string;
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onWebResourceError: (error) {
                    print("Page Loading Error: " + error.description);
                  },
                ),
                _isLoading
                    ? Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Container(),
              ],
            )
          : Container(
              child: Builder(
                builder: (context) {
                  WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                    Utils.showNoInternetSnackBar(_scaffoldKey);
                    Timer.periodic(Duration(seconds: 2), (timer) {
                      if (Utils.isInternetAvailable) {
                        _scaffoldKey.currentState!.hideCurrentSnackBar();
                        timer.cancel();
                        setState(() {});
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

  void _onLoading() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        dialogContext = context;
        return Dialog(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Loading...'),
              ),
            ],
          ),
        );
      },
    );
  }
}
