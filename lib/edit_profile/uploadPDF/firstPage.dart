import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/edit_profile/uploadPDF/secondPage.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';

import 'model.dart';

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  bool isA = false;
  List<Modal> itemList = List();
  final mainReference = FirebaseDatabase.instance.reference();

  //get user id
  String id;
  FirebaseUser user;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return (itemList.length == 0) && (isA)
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 1,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => Home()));
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            body: ListView.builder(
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: GestureDetector(
                      onTap: () {
                        String passData = itemList[index].link;
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ViewPdf(),
                                settings: RouteSettings(arguments: passData)));
                      },
                      child: Stack(
                        children: <Widget>[
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/back.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Center(
                            child: Container(
                              height: 105,
                              child: Card(
                                color: Colors.blueAccent,
                                margin: EdgeInsets.all(18),
                                elevation: 7.0,
                                child: Center(
                                  child: Text(
                                    itemList[index].name +
                                        " " +
                                        (index + 1).toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                getPdfAndUpload();
              },
              child: Icon(
                Icons.file_copy,
                color: Colors.white,
              ),
              backgroundColor: Colors.blue,
            ),
          );
  }

  Future getPdfAndUpload() async {
    var rng = new Random();
    String randomName = "";
    for (var i = 0; i < 20; i++) {
      randomName += rng.nextInt(100).toString();
    }
    File file = await FilePicker.getFile(type: FileType.custom);
    String fileName = '$randomName.pdf';
    savePdf(file.readAsBytesSync(), fileName);
  }

  savePdf(List<int> asset, String name) async {
    StorageReference reference =
        FirebaseStorage.instance.ref().child('files').child(name);
    StorageUploadTask uploadTask = reference.putData(asset);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    documentFileUpload(url);
  }

  String CreateCryptoRandomString([int length = 32]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));
    return base64Url.encode(values);
  }

  void documentFileUpload(String str) {
    var data = {
      "PDF": str,
      "FileName": "Certificate",
    };
    mainReference
        .child('$id')
        .child('files')
        .child(CreateCryptoRandomString())
        .set(data)
        .then((v) {
      print("Store Successfully");
    });
  }

  @override
  void initState() {
    super.initState();
    getUserID();
    Timer(Duration(seconds: 2), () {
      mainReference
          .child('Consultants')
          .child('$id')
          .child('files')
          .once()
          .then((DataSnapshot snap) {
        //get data from firebase
        var data = snap.value;
        itemList.clear();
        data.forEach((key, value) {
          Modal m = new Modal(value['PDF'], value['FileName']);
          itemList.add(m);
        });
        setState(() {});
      });
    });
  }
}
