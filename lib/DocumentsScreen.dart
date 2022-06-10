import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ppsflutter/Document.dart';
import 'package:ppsflutter/PDFFileViewer.dart';
import 'package:ppsflutter/Utils.dart';
import 'package:ppsflutter/WebHelper.dart';
import 'package:ppsflutter/appThemeData.dart';
import 'package:ppsflutter/webModel/Documents.dart';

import 'AppDrawer.dart';
import 'PDFTextContent.dart';
import 'SizeConfig.dart';

class DocumentsScreen extends StatefulWidget {
  @override
  _DocumentsScreenState createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  List<Document> documentsList = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Documents",
            style: TextStyle(
                fontSize:
                    SizeConfig.isMobilePortrait ? SizeConfig.textMultiplier * 1.6 : SizeConfig.textMultiplier * 1.5),
          ),
        ),
        titleSpacing: 0.0,
        backgroundColor: Utils.getColorFromHex(appThemeData.appBarColor),
      ),
      drawer: AppDrawer(null),
      body: Container(
        child: buildDocumentList(),
      ),
    );
  }

  Widget buildDocumentList() {
    return FutureBuilder(
      future: WebHelper.fetchDocumentList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          Documents documents = snapshot.data as Documents;
          documentsList.clear();
          for (int i = 0; i < documents.items!.length; i++) {
            documentsList.add(Document(true, null, null, documents.items![i].title));
            for (int j = 0; j < documents.items![i].children!.length; j++) {
              documentsList.add(
                  Document(false, documents.items![i].children![j].title, documents.items![i].children![j].url, null));
            }
          }

          return ListView.builder(
            itemCount: documentsList.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Utils.getColorFromHex("#f0f0f0")),
                  ),
                ),
                child: documentsList[index].isHeading()!
                    ? InkWell(
                        child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(documentsList[index].getSectionHeading()!,
                            style: TextStyle(
                                fontSize: SizeConfig.textMultiplier * 2.3,
                                fontFamily: 'AppleGaramondBold',
                                color: Utils.getColorFromHex("#478f8a"))),
                      ))
                    : InkWell(
                        onTap: () {
                          String link = documentsList[index].documentUrl!;
                          String fileName = link.substring(link.lastIndexOf('/') + 1).replaceAll('.pdf', '');
                          //print('FILE NAME ::: $fileName');
                          /*if (Utils.pdfList.contains(fileName)) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => PDFTextContent(Utils.getPdfId(fileName))));
                          } else {*/
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PDFFileViewer(documentsList[index].getDocumentName(), link)));
                          //}
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(documentsList[index].documentName!,
                              style: TextStyle(
                                  fontSize: SizeConfig.textMultiplier * 2,
                                  fontFamily: 'AppleGaramondItalic',
                                  color: Utils.getColorFromHex("#8c8c8c"))),
                        ),
                      ),
              );
            },
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
