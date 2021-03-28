/*
import 'package:firebaseapp/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class GetBatch extends StatefulWidget {
  @override
  GetBatchState createState() => new GetBatchState();
}

class GetBatchState extends State<GetBatch> {
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType;

  void _openFileExplorer() async {
    setState(() => isLoadingPath = true);
    try {
      if (isMultiPick) {
        path = null;
        paths = await FilePicker.getMultiFilePath(
            type: fileType != null ? fileType : FileType.any,
            allowedExtensions: extensions);
      } else {
        path = await FilePicker.getFilePath(
            type: fileType != null ? fileType : FileType.any,
            allowedExtensions: extensions);
        paths = null;
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      isLoadingPath = false;
      fileName = path != null
          ? path.split('/').last
          : paths != null
              ? paths.keys.toString()
              : '...';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 1,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.blueAccent,
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) => Home()));
              },
            )),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: DropdownButton(
                      hint: Text('Select file type'),
                      value: fileType,
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          child: Text('Audio'),
                          value: FileType.audio,
                        ),
                        DropdownMenuItem(
                          child: Text('Image'),
                          value: FileType.image,
                        ),
                        DropdownMenuItem(
                          child: Text('Video'),
                          value: FileType.video,
                        ),
                        DropdownMenuItem(
                          child: Text('Any'),
                          value: FileType.any,
                        ),
                      ],
                      onChanged: (value) => setState(() {
                            fileType = value;
                          })),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 200.0),
                  child: SwitchListTile.adaptive(
                    title:
                        Text('Pick multiple files', textAlign: TextAlign.right),
                    onChanged: (bool value) =>
                        setState(() => isMultiPick = value),
                    value: isMultiPick,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: RaisedButton(
                    onPressed: () => _openFileExplorer(),
                    child: Text("Open file picker"),
                  ),
                ),
                Builder(
                  builder: (BuildContext context) => isLoadingPath
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: const CircularProgressIndicator())
                      : path != null || paths != null
                          ? Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: Scrollbar(
                                  child: ListView.separated(
                                itemCount: paths != null && paths.isNotEmpty
                                    ? paths.length
                                    : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath =
                                      paths != null && paths.isNotEmpty;
                                  final int fileNo = index + 1;
                                  final String name = 'File $fileNo : ' +
                                      (isMultiPath
                                          ? paths.keys.toList()[index]
                                          : fileName ?? '...');
                                  final filePath = isMultiPath
                                      ? paths.values.toList()[index].toString()
                                      : path;
                                  return ListTile(
                                    title: Text(
                                      name,
                                    ),
                                    subtitle: Text(filePath),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        Divider(),
                              )),
                            )
                          : Container(),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
*/

import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:path/path.dart';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GetBatch extends StatefulWidget {
  @override
  _GetBatchState createState() => _GetBatchState();
}

class _GetBatchState extends State<GetBatch> {
  final mainRef = FirebaseDatabase.instance;
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
  void initState() {
    super.initState();
    getUserID();
  }
  //------------------------------------certificate uploading

  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType = FileType.any;
  List<File> files;
  File file;

  void _openFileExplorer(BuildContext context) async {
    setState(() => isLoadingPath = true);
    try {
      if (isMultiPick) {
        path = null;
        files = await FilePicker.getMultiFile(
            type: fileType != null ? fileType : FileType.any,
            allowedExtensions: extensions);

        //await FilePicker.getMultiFilePath(type: fileType != null? fileType: FileType.any, allowedExtensions: extensions);
      } else {
        file = await FilePicker.getFile(
            type: fileType != null ? fileType : FileType.any,
            allowedExtensions: extensions);
        path = file.path;
        //await FilePicker.getFilePath(type: fileType != null? fileType: FileType.any, allowedExtensions: extensions);
        paths = null;
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    uploadFile(context);
    if (!mounted) return;
    setState(() {
      isLoadingPath = false;
      fileName = path != null
          ? path.split('/').last
          : paths != null
              ? paths.keys.toString()
              : '...';
    });
  }

  Future uploadFile(BuildContext context) async {
    String fileName = basename(path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child("files").child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    final ref = mainRef.reference().child('$id');
    ref.child("files").child("1").set(path);
    setState(() {
      print("Certificate uploaded");
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Certificate Uploaded')));
    });
  }

  //------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (BuildContext context) => Home()));
            },
          )),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            SizedBox(
              height: 8.0,
            ),
            Text(
              "Upload Certificates",
              style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w500,
                  color: Colors.black),
            ),
            SizedBox(
              height: 12.0,
            ),
            Row(children: <Widget>[
              Expanded(
                flex: 3,
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 250.0),
                  child: new SwitchListTile.adaptive(
                    title: new Text(
                      'Add multiple certificates',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black),
                    ),
                    onChanged: (bool value) =>
                        setState(() => isMultiPick = value),
                    value: isMultiPick,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: OutlineButton(
                  color: Colors.blue[700],
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () => _openFileExplorer(context),
                ),
              ),
            ]),
            Builder(
              builder: (BuildContext context) => isLoadingPath
                  ? Loading()
                  : path != null || paths != null
                      ? Container(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          height: MediaQuery.of(context).size.height * 0.50,
                          child: new Scrollbar(
                              child: new ListView.separated(
                            itemCount: paths != null && paths.isNotEmpty
                                ? paths.length
                                : 1,
                            itemBuilder: (BuildContext context, int index) {
                              final bool isMultiPath =
                                  paths != null && paths.isNotEmpty;
                              final int fileNo = index + 1;
                              final String name = 'File $fileNo : ' +
                                  (isMultiPath
                                      ? paths.keys.toList()[index].toString()
                                      : fileName ?? '...');
                              final String filePath = isMultiPath
                                  ? paths.values.toList()[index].toString()
                                  : path;
                              return new ListTile(
                                title: new Text(
                                  name,
                                ),
                                //     subtitle: new Text(filePath),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    new Divider(),
                          )),
                        )
                      : Container(),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
