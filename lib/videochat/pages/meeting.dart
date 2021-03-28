import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/videochat/pages/index.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

var Token;

class Server extends StatefulWidget {
  @override
  _ServerState createState() => _ServerState();
}

// class Token {
//   final String channel;

//   Token({this.channel});

//   factory Token.fromJson(Map<String, dynamic> json) {
//     return Token(channel: json['channel']);
//   }
// }

class _ServerState extends State<Server> {
  final mainRef = FirebaseDatabase.instance;
  Map data;
  List UsersData;
  Map token;

  String channel = '';
  String startTime = '';
  String endTime = '';
  String meetingDate = '';
  final channelController = TextEditingController();
  final _fromKey = GlobalKey<FormState>();

  // getUsers() async {
  //   http.Response response = await http.get('http://10.0.2.2:4000/api/users');
  //   data = json.decode(response.body);
  //   setState(() {
  //     UsersData = data['users'];
  //   });
  // }

  Map<String, String> headers = {'content-type': 'application/json'};

  Future<void> getToken(String cname, String eTime, String mDate) async {
    http.Response response = await http.post('http://10.0.2.2:3000/rtcToken',
        headers: headers,
        body: '{"channel":"${cname}","eTime":"${eTime}","mDate":"${mDate}"}');
    token = json.decode(response.body);

    setState(() {
      Token = token['token'];
    });
    print(Token);
    // print(token['expireTimeMinute']);
  }

  Future<void> sendDatabse() async {
    final ref = mainRef.reference().child('Meeting').child('$channel');
    ref.child('token').set(Token);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
            onPressed: () => {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return Home();
                  }))
                },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Text('Make a Meeting'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  trailing: FlatButton(
                      color: Colors.lightBlue,
                      onPressed: () => {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (_) {
                              return IndexPage();
                            }))
                          },
                      child: Text(
                        'Join Meeting',
                        style: TextStyle(color: Colors.white),
                      )),
                ),
                SizedBox(
                  height: 50.0,
                ),
                Container(
                  height: 300.0,
                  decoration: BoxDecoration(color: Colors.blue[100]),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                        key: _fromKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter unique meeting name'),
                              validator: (text) {
                                if (text.isEmpty) {
                                  return 'channel name must be enter';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                channel = value;
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter meeting date MM DD YYYY'),
                              validator: (text) {
                                if (text.isEmpty) {
                                  return 'Date must be enter here';
                                }
                                return null;
                              },
                              onChanged: (String value) {
                                meetingDate = value;
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter Start Time Here HH:MM'),
                              onChanged: (String value) {
                                startTime = value;
                              },
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter End Time Here HH:MM'),
                              onChanged: (String value) {
                                endTime = value;
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                FlatButton(
                                    color: Colors.blue,
                                    onPressed: () async {
                                      if (_fromKey.currentState.validate()) {
                                        _fromKey.currentState.save();
                                        print(channel);
                                        await getToken(
                                            channel, endTime, meetingDate);
                                        await sendDatabse();
                                      }
                                    },
                                    child: Text(
                                      'Submit',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18.0),
                                    )),
                                /*     FlatButton(
                                    onPressed: () {
                                      retrieveDatabse();
                                    },
                                    child: Text(
                                      'retrieve',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18.0),
                                    )) */
                              ],
                            )
                          ],
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // body: Center(
      //   child: Container(
      //     child: Column(
      //       children: [
      //         Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: TextField(
      //             controller: channelController,
      //           ),
      //         ),
      //         FlatButton(
      //             color: Colors.amber,
      //             onPressed: () => {
      //                   getToken(channelController.text),
      //                   print(channelController.text)
      //                 },
      //             child: Text('Save')),
      //       ],
      //     ),
      //   ),
      // )
      // body: ListView.builder(
      //     itemCount: UsersData == null ? 0 : UsersData.length,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Card(
      //         child: Row(
      //           children: [
      //             CircleAvatar(
      //               backgroundImage: NetworkImage(UsersData[index]['avatar']),
      //             )
      //           ],
      //         ),
      //       );
      //     }));
    );
  }
}
