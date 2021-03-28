import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:path/path.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/Animation/animation.dart';
import 'package:firebaseapp/authenticate/register.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class Register_Start extends StatefulWidget {
  final Function tv;

  //create constructor for the Register widget
  Register_Start({this.tv});

  @override
  _Register_StartState createState() => _Register_StartState();
}

class _Register_StartState extends State<Register_Start> {
  final mainRef = FirebaseDatabase.instance;
  final cloudRef = Firestore.instance;
  String id;
  dynamic result;

  TextEditingController _passwordController = new TextEditingController();

  //-----------------------------------------------verifying email
  TextEditingController _otpController = new TextEditingController();
  bool verify = false;
  String isVerified = "";
  //-----------Send otp
  Future<void> sendOTP() async {
    EmailAuth.sessionName = "Test Session";
    var res = await EmailAuth.sendOtp(receiverMail: email);
    if (res) {}
  }

  Future<void> validation(BuildContext context) async {
    var res =
        EmailAuth.validate(receiverMail: email, userOTP: _otpController.text);

    Timer(Duration(seconds: 1), () async {
      if (res == true) {
        await sendDatabase();
        await uploadPic(context);
      } else {
        await _keyInvalid(context);
      }
    });
  }

  //Alert dialog for validation
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter Validation Key'),
            content: TextField(
              controller: _otpController,
              decoration: InputDecoration(hintText: "Validation Key"),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() async {
                    validation(context);
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
  /*
  BuildContext dialogContext;
  //-------alert box
  showAlertDialog(BuildContext context) async {
    // set up the button
    Widget okButton = FlatButton(
        child: Text("OK"),
        onPressed: () async {
          if (verifyOTP() == true) {
            await sendDatabase();
            await uploadPic(context);
          }
          await Navigator.of(dialogContext).pop();
        });

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Enter Validation Key"),
      content: TextFormField(
        controller: _otpController,
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }
  */
  //----------------------------------------------------------------

  Future<void> _keyInvalid(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Validation Key is Invalid'),
            actions: <Widget>[
              FlatButton(
                  color: Colors.green,
                  textColor: Colors.white,
                  child: Text('OK'),
                  onPressed: () {
                    setState(() async {
                      Navigator.pop(context);
                    });
                  })
            ],
          );
        });
  }

  //---------------------------------------------------

  //----------------propic

  File __image;
  String pathImg = "";

  Future getPic() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      __image = image;
      print('Image Path $__image');
      pathImg = basename(__image.path);
    });
  }

  Future uploadPic(BuildContext context) async {
    String imageName = basename(__image.path);
    StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(__image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Profile Picture uploaded");
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    });
  }

//----------------------------------------------

//-------------------Category

  String value1 = "";
  String value2 = "";
  bool isA = false;
  String sub;
  List<DropdownMenuItem<String>> category = List();
  bool disabledropdown = true;

  final Medical = {
    "1": "Mental",
    "2": "Vet",
    "3": "Dental",
  };

  final Law = {
    "1": "Criminal",
    "2": "Business",
  };

  final Education = {
    "1": "Primary",
    "2": "Maths",
    "3": "Bio",
  };

  void populateweb() {
    for (String key in Medical.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Medical[key]),
        ),
        value: Medical[key],
      ));
    }

    /* for (int v in Medical.keys) {
      multiItem.add(MultiSelectDialogItem(v, Medical[v]));
    } */
  }

  void populateapp() {
    for (String key in Law.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Law[key]),
        ),
        value: Law[key],
      ));
    }
    /*for (int v in Law.keys) {
      multiItem.add(MultiSelectDialogItem(v, Law[v]));
    } */
  }

  void populatedesktop() {
    for (String key in Education.keys) {
      category.add(DropdownMenuItem<String>(
        child: Center(
          child: Text(Education[key]),
        ),
        value: Education[key],
      ));
    }
    /*for (int v in Education.keys) {
      multiItem.add(MultiSelectDialogItem(v, Education[v]));
    } */
  }

  void selected(_value) {
    if (_value == "Medical") {
      category = [];
      populateweb();
    } else if (_value == "Law") {
      category = [];
      populateapp();
    } else if (_value == "Education") {
      category = [];
      populatedesktop();
    }

    setState(() {
      value1 = _value;
      disabledropdown = false;
      value2 = "";
    });
  }

  void secondselected(_value) {
    setState(() {
      value2 = _value;
      isA = true;
    });
  }

//--------------------------------

  final AuthService _auth = AuthService();

  final _formkey = GlobalKey<FormState>(); //help the validate

  //text field state
  String email = '';
  String password = '';
  String error = '';
  String fName = "";
  String sName = "";
  String description = "";
  String mobileNumber = "";
  String isoCode = "";
  String counrtyCode = "";
  String accountNo = "";
  var today;
  var fiftyDaysFromNow;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue[100],
        body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.blue[900],
              Colors.blue[600],
              Colors.blue[400]
            ])),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    FadeAnimation(
                        1,
                        Text(
                          "Register",
                          style: TextStyle(color: Colors.white, fontSize: 50),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    FadeAnimation(
                        1.3,
                        Text(
                          "Let's Start by  creating your account",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(17),
                          topRight: Radius.circular(17))),
                  child: SingleChildScrollView(
                      child: Column(
                    children: [
                      FadeAnimation(
                        1.4,
                        Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 17.0),
                            child: Form(
                              key: _formkey,
                              child: Column(
                                children: <Widget>[
                                  Row(children: <Widget>[
                                    SizedBox(
                                      width: 99.0,
                                    ),
                                    Center(
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 130,
                                            height: 130,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: (__image != null)
                                                      ? FileImage(__image)
                                                      : AssetImage(
                                                          'assets/anon.png')),
                                              border: Border.all(
                                                  width: 4,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                              boxShadow: [
                                                BoxShadow(
                                                    spreadRadius: 2,
                                                    blurRadius: 10,
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    offset: Offset(0, 10))
                                              ],
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                height: 46,
                                                width: 46,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    width: 4,
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                  ),
                                                  color: Colors.blue,
                                                ),
                                                child: IconButton(
                                                  onPressed: () {
                                                    getPic();
                                                  },
                                                  icon: Icon(
                                                    Icons.camera_alt,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                    /*    Align(
                                      alignment: Alignment.center,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 50.0,
                                        child: ClipOval(
                                            child: SizedBox(
                                                width: 180.0,
                                                height: 180.0,
                                                child: (__image != null)
                                                    ? Image.file(
                                                        __image,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : Image.asset(
                                                        'assets/anon.png'))),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 60.0, right: 40.0),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.camera_alt,
                                          size: 25.0,
                                        ),
                                        onPressed: () {
                                          getPic();
                                        },
                                      ),
                                    ) */
                                  ]),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Row(children: <Widget>[
                                    Expanded(
                                      flex: 7,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.person),
                                          labelText: 'First Name',
                                          labelStyle: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 15,
                                              fontFamily: 'AvenirLight'),
                                          //       hintText: 'First Name',
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 3.0)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.pinkAccent,
                                                  width: 2.0)),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            fName = val;
                                          });
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Enter first name";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 0.5,
                                    ),
                                    Expanded(
                                      flex: 8,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(Icons.person),
                                          labelText: 'Second Name',
                                          labelStyle: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 15,
                                              fontFamily: 'AvenirLight'),
                                          //      hintText: 'Second Name',
                                          fillColor: Colors.white,
                                          filled: true,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white,
                                                  width: 3.0)),
                                          focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.pinkAccent,
                                                  width: 2.0)),
                                        ),
                                        onChanged: (val) {
                                          setState(() {
                                            sName = val;
                                          });
                                        },
                                        validator: (String value) {
                                          if (value.isEmpty) {
                                            return "Enter second name";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ]),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.note),
                                      labelText: 'Description',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontFamily: 'AvenirLight'),
                                      //    hintText: 'Description',
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 3.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pinkAccent,
                                              width: 2.0)),
                                    ),

                                    //  validator: (val)=>val.isEmpty?'Enter an email':null,  //Empty or not
                                    onChanged: (val) {
                                      //val means current value in form field
                                      setState(() => description = val);
                                    },
                                    validator: (String value) {
                                      if (value.isEmpty) {
                                        return "Please enter description";
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'E-Mail',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontFamily: 'AvenirLight'),
                                      //  hintText: 'E-mail',
                                      prefixIcon: Icon(Icons.email),
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 3.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pinkAccent,
                                              width: 2.0)),
                                    ),

                                    validator: (val) => val.isEmpty
                                        ? 'Enter an email'
                                        : null, //Empty or not
                                    onChanged: (val) {
                                      //val means current value in form field
                                      setState(() => email = val);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    child: IntlPhoneField(
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      decoration: InputDecoration(
                                        labelText: 'Mobile Number',
                                        labelStyle: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontFamily: 'AvenirLight'),
                                        //  prefixIcon:Icon(Icons.mobile_screen_share),
                                        //    hintText: 'Mobile Number',
                                        fillColor: Colors.white,
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 3.0)),
                                        focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.pinkAccent,
                                                width: 2.0)),
                                      ),
                                      initialCountryCode: 'LK',
                                      onChanged: (phone) {
                                        setState(() {
                                          mobileNumber = phone.completeNumber;
                                          isoCode = phone.countryISOCode;
                                          counrtyCode = phone.countryCode;
                                        });
                                      },
                                      /*validator: (PhoneNumber) {
                    if (PhoneNumber.isEmpty) {
                      return "Please enter phone";
                    }
                    if (PhoneNumber.length < 10) {
                      return "Please enter valid phone";
                    }
                  }, */
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontFamily: 'AvenirLight'),
                                      // hintText: 'Password',
                                      prefixIcon: Icon(Icons.lock),
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 3.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pinkAccent,
                                              width: 2.0)),
                                    ),
                                    controller: _passwordController,
                                    validator: (val) => val.length < 6
                                        ? 'Invalid Password. Password should 6+ chars long'
                                        : null,
                                    obscureText: true, //don't see text
                                    onChanged: (val) {
                                      setState(() => password = val);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontFamily: 'AvenirLight'),
                                      //      hintText: 'Confirm Password',
                                      prefixIcon: Icon(Icons.lock),
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 3.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pinkAccent,
                                              width: 2.0)),
                                    ),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value.isEmpty ||
                                          value != _passwordController.text) {
                                        return 'invalid password';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {},
                                  ),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  TextFormField(
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      labelText: 'Account Number',
                                      labelStyle: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontFamily: 'AvenirLight'),
                                      prefixIcon: Icon(Icons.home),
                                      //    hintText: 'Account Number',
                                      fillColor: Colors.white,
                                      filled: true,
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white, width: 3.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.pinkAccent,
                                              width: 2.0)),
                                    ),
                                    onChanged: (val) {
                                      setState(() => accountNo = val);
                                    },
                                    validator: (String val) {
                                      if (val.isEmpty) {
                                        return "Please enter Account number";
                                      }
                                      if (val.length < 10) {
                                        return "Please enter valid Account number";
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: 30.0,
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        labelText: 'Category',
                                        labelStyle: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontFamily: 'AvenirLight'),
                                      ),
                                      items: [
                                        DropdownMenuItem<String>(
                                          value: "Medical",
                                          child: Center(
                                            child: Text("Medical"),
                                          ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: "Law",
                                          child: Center(
                                            child: Text("Law"),
                                          ),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: "Education",
                                          child: Center(
                                            child: Text("Education"),
                                          ),
                                        ),
                                      ],
                                      onChanged: (_value) => selected(_value),
                                      validator: (value) => value == null
                                          ? 'Please select your category'
                                          : null,
                                      //            hint: Text("Select Your Category"),
                                    ),
                                  ),
                                  /*Text(
                                    "$value1",
                                       style: TextStyle(
                                       fontSize: 20.0,
                                     ),
                                    ),
                                   */

                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  /*
                                     RaisedButton(
                                       child: Text("Select your sub category"),
                                       onPressed: () => _showMultiSelect(context),
                                        ),
                                    */

                                  Container(
                                    width: 340,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: DropdownButton<String>(
                                      /*           decoration: InputDecoration(
                                        labelText: 'Sub Category',
                                        labelStyle: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 15,
                                            fontFamily: 'AvenirLight'),
                                      ), */
                                      hint: Text(
                                        "Sub Category",
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      underline:
                                          Container(color: Colors.transparent),
                                      items: category,
                                      onChanged: disabledropdown
                                          ? null
                                          : (_value) => secondselected(_value),
                                      //  validator: (value) => value == null? 'Please select your sub category': null,
                                      //    hint: Text("Select Your Sub Category"),
                                      //    disabledHint:  Text("Select Your Sub Category"),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            width: 1.0, color: Colors.grey),
                                      ),
                                    ),
                                    width: 295,
                                    child: Text(
                                      "$value2",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ),
                                  /* Text(
                                      "$value2",
                                      style: TextStyle(
                                      fontSize: 20.0,
                                     ),
                                     ),
                                   */

                                  SizedBox(
                                    height: 22.0,
                                  ),
                                ],
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FadeAnimation(
                        1.7,
                        Container(
                          padding: EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: RaisedButton(
                                  onPressed: () async {
                                    if (_formkey.currentState.validate()) {
                                      await sendOTP();
                                      await _displayTextInputDialog(context);
                                    }

                                    /*  if (verify == true) {
                                      if (_formkey.currentState.validate()) {
                                        //valid or not
                                        result = await _auth
                                            .registerWithEmailAndPassword(
                                                email, password);
                                        id = result.uid.toString();
                                      }

                                      final ref =
                                          mainRef.reference().child('$id');
                                      ref.child("proPic").set(pathImg);

                                      uploadPic(context);

                                      if (_formkey.currentState.validate()) {
                                        if (result == null) {
                                          setState(() => error =
                                              'please supply a valid email');
                                        } else {
                                          ref.child("firstName").set(fName);
                                          ref.child("secondName").set(sName);
                                          ref
                                              .child("description")
                                              .set(description);
                                          ref
                                              .child("mobileNumber")
                                              .set(mobileNumber);
                                          ref
                                              .child("countryCode")
                                              .set(counrtyCode);
                                          ref
                                              .child("countryisoCode")
                                              .set(isoCode);
                                          ref.child("accountNo").set(accountNo);
                                          ref.child("field").set(value1);
                                          ref.child("subField").set(value2);
                                        }
                                      }
                                    }
                                    */

                                    /*    if (_formkey.currentState.validate()) {
                                      //valid or not
                                      dynamic result = await _auth
                                          .registerWithEmailAndPassword(
                                              email, password);
                                      String id = result.uid.toString();
                                      final ref =
                                            mainRef.reference().child('$id');
                                      if (result == null) {
                                        setState(() => error =
                                            'please supply a valid email');
                                      } else {
                                        
                                        ref.child("firstName").set(fName);
                                        ref.child("secondName").set(sName);
                                        ref
                                            .child("description")
                                            .set(description);
                                        ref
                                            .child("mobileNumber")
                                            .set(mobileNumber);
                                        ref.child("accountNo").set(accountNo);
                                        ref.child("field").set(value1);
                                        ref.child("subField").set(value2);
                                        ref.child("proPic").set(pathImg);

                                      }
                                    }  */
                                  },
                                  color: Colors.blue,
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: RaisedButton(
                                  onPressed: () {
                                    widget.tv();
                                  },
                                  color: Colors.blue,
                                  child: Text(
                                    'Log In',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                    ),
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
                      SizedBox(
                        height: 20,
                      ),
                      FadeAnimation(
                          1.7,
                          Text(
                            "Continue with social media",
                            style: TextStyle(color: Colors.grey),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      FadeAnimation(
                        1.8,
                        RaisedButton(
                            color: Colors.blue,
                            onPressed: () {
                              uploadPic(context);
                            },
                            child: Text(
                              'Register with Gmail',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      )
                    ],
                  )),
                ),
              ),
            ])));
  }

  Future<void> sendDatabase() async {
    if (_formkey.currentState.validate()) {
      //valid or not
      result = await _auth.registerWithEmailAndPassword(email, password);
      id = result.uid.toString();
    }

    final ref = mainRef.reference().child('Consultants').child('$id');
    final CollectionReference consultants = cloudRef.collection('Consultants');

    // uploadPic(context);

    if (_formkey.currentState.validate()) {
      if (result == null) {
        setState(() => error = 'please supply a valid email');
      } else {
        ref.child("firstName").set(fName);
        ref.child("secondName").set(sName);
        ref.child("description").set(description);
        ref.child("mobileNumber").set(mobileNumber);
        ref.child("countryCode").set(counrtyCode);
        ref.child("countryisoCode").set(isoCode);
        ref.child("accountNo").set(accountNo);
        ref.child("field").set(value1);
        ref.child("subField").set(value2);
        ref.child("proPic").set(pathImg);
        today = DateTime.now();
        fiftyDaysFromNow = today.add(const Duration(days: 50)).toString();
        ref.child("nameChange").set(fiftyDaysFromNow);
        await consultants.document(id).setData(
            {'id': id, 'name': fName + ' ' + sName, 'proPic': pathImg});
      }
    }
  }
}
