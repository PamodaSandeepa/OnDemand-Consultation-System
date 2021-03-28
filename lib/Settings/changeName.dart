import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:intl/intl.dart';
import 'package:firebaseapp/edit_profile/settings.dart';
import 'package:flutter/material.dart';

int different = 0;

class ChangeName extends StatefulWidget {
  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> {
  TextEditingController _controllerfName = new TextEditingController();
  TextEditingController _controllersName = new TextEditingController();
  final mainref = FirebaseDatabase.instance;
  String retrievedfName = "";
  String retrievedsName = "";
  FirebaseUser user;
  String id;
  bool _loading = true;

  var today;
  var fiftyDaysFromNow;

  var retrievedfiftyDaysFromNow;
  String retrieved;

  //Retrive user id from firebase
  Future<void> getUserID() async {
    final FirebaseUser userData = await FirebaseAuth.instance.currentUser();
    setState(() {
      user = userData;
      id = userData.uid.toString();
    });
  }

  //Retrieve userData from firebase
  Future<void> getUserData() async {
    final ref = mainref.reference().child('Consultants').child('$id');
    await ref.child('firstName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedfName = snapshot.value;
        _controllerfName.text = retrievedfName;
      });
    });
    await ref.child('secondName').once().then((DataSnapshot snapshot) {
      setState(() {
        retrievedsName = snapshot.value;
        _controllersName.text = retrievedsName;
      });
    });
    await ref.child('nameChange').once().then((DataSnapshot snapshot) {
      setState(() {
        retrieved = snapshot.value;

        retrievedfiftyDaysFromNow = DateTime.parse("$retrieved");

        today = DateTime.now();
        print(today);
        print(retrievedfiftyDaysFromNow);
        different = retrievedfiftyDaysFromNow.difference(today).inDays;
        print(different);
      });
    });
    _loading = false;
  }

  void initState() {
    super.initState();
    getUserID();

    Timer(Duration(seconds: 1), () {
      getUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Loading()
        : Scaffold(
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
                      builder: (BuildContext context) => SettingsPage()));
                },
              ),
            ),
            body: Container(
              padding: EdgeInsets.only(left: 16, top: 25, right: 16),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: ListView(
                  children: [
                    Text(
                      "Name",
                      style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      readOnly: different <= (0) ? false : true,
                      controller: _controllerfName,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        labelStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontFamily: 'AvenirLight'),
                        //       hintText: 'First Name',
                        fillColor:
                            different <= (0) ? Colors.white : Colors.grey[300],
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: different <= (0)
                                    ? Colors.white
                                    : Colors.grey[300],
                                width: 3.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.pinkAccent, width: 2.0)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          retrievedfName = val;
                        });
                      },
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Enter first name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      readOnly: different <= (0) ? false : true,
                      controller: _controllersName,
                      decoration: InputDecoration(
                        labelText: 'Second Name',
                        labelStyle: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontFamily: 'AvenirLight'),
                        //      hintText: 'Second Name',
                        fillColor:
                            different <= (0) ? Colors.white : Colors.grey[300],
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: different <= (0)
                                    ? Colors.white
                                    : Colors.grey[300],
                                width: 3.0)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.pinkAccent, width: 2.0)),
                      ),
                      onChanged: (val) {
                        setState(() {
                          retrievedsName = val;
                        });
                      },
                      validator: (String value) {
                        if (value.isEmpty) {
                          return "Enter second name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                        padding: EdgeInsets.all(10.0),
                        color: Colors.blueAccent[50],
                        child: Column(
                          children: [
                            different <= (0)
                                ? Text(
                                    'Please Note',
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  )
                                : Text(
                                    'Warning',
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800),
                                  ),
                            different <= (0)
                                ? Text(
                                    'If you change your name on E-Consultant, you cant change it again for 90 days. Dont add any unusual capitalization, characters and random words')
                                : Text(
                                    "Can not change your name right now. You can change your name after $different days"),
                          ],
                        )),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      color: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: () {
                        final ref = mainref
                            .reference()
                            .child('Consultants')
                            .child('$id');
                        ref.child("firstName").set(retrievedfName);
                        ref.child("secondName").set(retrievedsName);

                        if (different <= 0) {
                          today = DateTime.now();
                          fiftyDaysFromNow =
                              today.add(const Duration(days: 50)).toString();

                          ref.child("nameChange").set(fiftyDaysFromNow);
                        }
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => SettingsPage()));
                      },
                      child: different <= 0
                          ? Text("Review Change",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 1,
                                  color: Colors.black))
                          : Text("Go Back",
                              style: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 1,
                                  color: Colors.black)),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    RaisedButton(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => SettingsPage()));
                      },
                      child: Text("Cancel",
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                              color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ));
  }
}
