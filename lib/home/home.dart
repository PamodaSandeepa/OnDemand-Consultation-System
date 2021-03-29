import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/edit_profile/edit_profile.dart';
import 'package:firebaseapp/edit_profile/settings.dart';
import 'package:firebaseapp/edit_profile/uploadPDF/firstPage.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:firebaseapp/videochat/pages/meeting.dart';
import 'package:firebaseapp/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/shared/loading.dart';

class Home extends StatefulWidget {
  @override
  _ConsultantState createState() => _ConsultantState();
}

class _ConsultantState extends State<Home> {
  final AuthService _auth =
      AuthService(); //make a object of AuthService class in auth.dart file

  //-------------------- dp
  final mainref = FirebaseDatabase.instance;
  String retrievedproPic = "";
  String retrievedfName = "";
  String retrievedsName = "";
  String fullName = "";
  String id;
  FirebaseUser user;
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }

  String url = "";
  bool isImg = true;
  bool _loading = true;

  Future<void> getUserData() async {
    final ref = mainref.reference().child('Consultants').child('$id');
    await ref.child('proPic').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedproPic = snapshot.value;
      });
    });
    await ref.child('firstName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedfName = snapshot.value;
      });
    });
    await ref.child('secondName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedsName = snapshot.value;
      });
    });
    fullName = retrievedfName + " " + retrievedsName;
    if (retrievedproPic == "") {
      url =
          "https://inlandfutures.org/wp-content/uploads/2019/12/thumbpreview-grey-avatar-designer.jpg";
      isImg = false;
    } else {
      await downloadImage();
    }
    _loading = false;
  }

  Future downloadImage() async {
    StorageReference _reference =
        FirebaseStorage.instance.ref().child("$retrievedproPic");
    String downloadAddress = await _reference.getDownloadURL();
    setState(() {
      url = downloadAddress;
    });
  }

  //--------------------
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> checkAuthentication() async {
    auth.onAuthStateChanged.listen((user) async {
      if (user == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      }
    });
  }

  DateTime _pickedDate;
  TimeOfDay fromTime;
  TimeOfDay toTime;

  @override
  void initState() {
    super.initState();
    getUserID();
    Timer(Duration(seconds: 2), () {
      getUserData();
    });
    _pickedDate = DateTime.now();
    fromTime = TimeOfDay.now();
    toTime = TimeOfDay.now();
  }

  pickedDate() async {
    DateTime date = await showDatePicker(
        context: context,
        initialDate: _pickedDate,
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5));
    if (date != null) {
      setState(() {
        _pickedDate = date;
      });
    }
  }

  pickedFromTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: fromTime);
    if (fromTime != null) {
      setState(() {
        fromTime = t;
      });
    } else {
      fromTime = TimeOfDay.now();
    }
  }

  pickedToTime() async {
    TimeOfDay t = await showTimePicker(context: context, initialTime: toTime);
    if (toTime != null) {
      setState(() {
        toTime = t;
      });
    } else {
      toTime = TimeOfDay.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
            drawer: Drawer(
              child: Column(children: [
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(children: [
                          Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: NetworkImage(url)),
                              border: Border.all(
                                  width: 4, color: Colors.blueAccent[200]),
                              boxShadow: [
                                BoxShadow(
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(0, 10))
                              ],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 3,
                                    color: Colors.white,
                                  ),
                                  color: Colors.blue,
                                ),
                                child: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.verified_sharp,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                        ]),
                        SizedBox(
                          height: 12.0,
                        ),
                        Text(
                          fullName,
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(
                          height: 4.0,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            border: Border.all(color: Colors.red),
                            boxShadow: [
                              BoxShadow(
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  color: Colors.black.withOpacity(0.1),
                                  offset: Offset(0, 10))
                            ],
                          ),
                          child: Text(
                            "Verified Consultant",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                //Now let's Add the button for the Menu
                //and let's copy that and modify it

                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => EditProfilePage()));
                  },
                  leading: Icon(
                    Icons.edit,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Edit Profile"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => FirstPage()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.file_copy,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Add Certificate"),
                ),
                ListTile(
                  onTap: () {},
                  leading: Icon(
                    Icons.notifications,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Notification"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => SettingsPage()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.settings,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Settings"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (BuildContext context) => Server()));
                  },
                  tileColor: Colors.white30,
                  leading: Icon(
                    Icons.video_call,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Video Chat"),
                ),
                ListTile(
                  onTap: () async {
                    await _auth.signOut();
                    await checkAuthentication();
                  },
                  leading: Icon(
                    Icons.exit_to_app,
                    color: Colors.blueAccent,
                  ),
                  title: Text("Sign Out"),
                ),
              ]),
            ),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.blueAccent,
              elevation: 1,
              title: Text(
                'Busy Date',
                //     style: TextStyle(color: Colors.blueAccent),
              ),

              /*
          FlatButton.icon(
              onPressed: () async {
                await _auth.signOut(); //calling a Sign out method
              },
              icon: Icon(
                Icons.person,
                size: 20.0,
              ),
              label: Text("Logout")),
          FlatButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        EditProfilePage())); //calling a Sign out method
              },
              icon: Icon(
                Icons.edit,
                size: 20.0,
                color: Colors.blueAccent,
              ),
              label: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.blueAccent),
              )) */
            ),
            body: Container(
              child: GestureDetector(
                child: Column(
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Select Date and Time',
                          style: TextStyle(fontSize: 25.0),
                        )
                      ],
                    ),
                    ListTile(
                      leading: Text(
                        'Date',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      title: Text(
                          '${_pickedDate.year}-${_pickedDate.month}-${_pickedDate.day}'),
                      trailing: IconButton(
                          icon: Icon(Icons.date_range),
                          onPressed: () => {pickedDate()}),
                    ),
                    ListTile(
                      leading: Text(
                        'From',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      title: Text("${fromTime.hour}:${fromTime.minute}"),
                      trailing: IconButton(
                          icon: Icon(Icons.watch_later_outlined),
                          onPressed: () => {pickedFromTime()}),
                    ),
                    ListTile(
                      leading: Text(
                        'To',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      title: Text("${toTime.hour}:${fromTime.minute}"),
                      trailing: IconButton(
                          icon: Icon(Icons.watch_later_outlined),
                          onPressed: () => {pickedToTime()}),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RaisedButton(
                          color: Colors.amber,
                          onPressed: () => {},
                          child: Text('Save'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }
}

/*class Home extends StatelessWidget {
  final AuthService _auth =
      AuthService(); //make a object of AuthService class in auth.dart file

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        title: Text(
          "Home",
          style: TextStyle(color: Colors.blueAccent),
        ),
        actions: <Widget>[
          /*  FlatButton.icon(
              onPressed: () async {
                await _auth.signOut(); //calling a Sign out method
              },
              icon: Icon(
                Icons.person,
                size: 20.0,
              ),
              label: Text("Logout")),*/
          FlatButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) =>
                        EditProfilePage())); //calling a Sign out method
              },
              icon: Icon(
                Icons.edit,
                size: 20.0,
                color: Colors.blueAccent,
              ),
              label: Text(
                "Edit Profile",
                style: TextStyle(color: Colors.blueAccent),
              ))
        ],
      ),
    );
  }
}
*/
