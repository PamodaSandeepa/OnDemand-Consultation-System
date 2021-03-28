import 'dart:convert';
import 'dart:io';

import 'dart:math';

//import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/models/user.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:path/path.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Register extends StatefulWidget {
  // final Function tv1;
  //create constructor for the Register widget
  // Register({this.tv1});

  String id;
  dynamic result;
  Register({this.id, this.result});

  @override
  _RegisterState createState() => _RegisterState(id, result);
}

class _RegisterState extends State<Register> {
  String id;
  dynamic result;
  _RegisterState(this.id, this.result);
  final mainReference =
      FirebaseDatabase.instance.reference().child('Consultant');
  final mainRef = FirebaseDatabase.instance;

  String name = "";
  String description = "";
  String mobileNumber = "";
  String accountNo = "";

  //certificate uploading
  String fileName;
  String path;
  Map<String, String> paths;
  List<String> extensions;
  bool isLoadingPath = false;
  bool isMultiPick = false;
  FileType fileType = FileType.any;
  List<File> files;
  File file;

  void _openFileExplorer() async {
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
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      print("Certificate uploaded");
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Certificate Uploaded')));
    });
  }

  //image uploading
  File __image;

  Future getPic() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      __image = image;
      print('Image Path $__image');
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

  Future getCertificate() async {
    var rng = new Random();
    String randomName = "";
    for (var i = 0; i < 20; i++) {
      print(rng.nextInt(100));
      randomName += rng.nextInt(100).toString(); //generate
    }

    //  File file = await FilePicker.getFile(type: FileType.custom ); //get pdf and stored in variable
    String fileName = '${randomName}.pdf';
    //  savePdf(file.readAsBytesSync(), fileName);
  }

  savePdf(List<int> asset, String name) async {
    StorageReference reference = FirebaseStorage.instance.ref().child(name);
    StorageUploadTask uploadTask = reference.putData(asset);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    documentFileUpload(url); //function call
  }

  void documentFileUpload(String str) {
    var data = {
      "PDF": str,
      "FileName": "My new Book", //store data
    };
    mainReference.child(CreateCryptoRandomString()).set(data).then((v) {
      print("Store Successfully");
    });
  }

  String CreateCryptoRandomString([int length = 32]) {
    final Random _random = Random.secure();
    var values = List<int>.generate(
        length, (index) => _random.nextInt(256)); //generate key
    return base64Url.encode(values);
  }

  String value1 = "";
  String value2 = "";
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
    });
  }

  void secondselected(_value) {
    setState(() {
      value2 = _value;
    });
  }

  /* List<MultiSelectDialogItem<int>> multiItem = List();

  void _showMultiSelect(BuildContext context) async {
    multiItem = [];
    if (value1 == "Medical") {
      category = [];
      populateweb();
    } else if (value1 == "Law") {
      category = [];
      populateapp();
    } else if (value1 == "Education") {
      category = [];
      populatedesktop();
    }
    final items = multiItem;
    // final items = <MultiSelectDialogItem<int>>[
    //   MultiSelectDialogItem(1, 'India'),
    //   MultiSelectDialogItem(2, 'USA'),
    //   MultiSelectDialogItem(3, 'Canada'),
    // ];

    final selectedValues = await showDialog<Set<int>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          items: items,
          initialSelectedValues: [1].toSet(),
        );
      },
    );

    String value2 = selectedValues.toString();

    print(selectedValues);
  }
  */

  // final List<String> category= ['Medical','Law','Sport','Education'];
  // final AuthService _auth=AuthService();

  final _formkey = GlobalKey<FormState>(); //help the validate

  //text field state
  String email = '';
  String password = '';
  String error = '';

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final ref = mainRef.reference().child('$id');
    return loading
        ? Loading()
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            backgroundColor: Colors.blue[50],
            appBar: AppBar(
              backgroundColor: Colors.blue[900],
              elevation: 0.0, //remove drop shadow
              title: Text('Registeration form'),
              // actions: <Widget>[
              //   FlatButton.icon(
              //    icon: Icon(Icons.person),
              //   label: Text('Sign In'),
              //    onPressed: ()  {
              //   widget.tv1();  //widget refers to Register widget.cant write this.tv cuz this refers <state> object
              //    },
              //   )
              //  ],
            ),
            body: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                child: Form(
                  key: _formkey,
                  child: ListView(
                    children: <Widget>[
                      Row(children: <Widget>[
                        SizedBox(
                          width: 99.0,
                        ),
                        Align(
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
                                        : Image.asset('assets/anon.png'))),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 60.0, right: 40.0),
                          child: IconButton(
                            icon: Icon(
                              Icons.camera_alt,
                              size: 30.0,
                            ),
                            onPressed: () {
                              getPic();
                            },
                          ),
                        )
                      ]),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          //  prefixIcon: Icon(Icons.person),
                          hintText: 'Name',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                        ),
                        onChanged: (val) {
                          setState(() {
                            name = val;
                          });
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter name";
                          }
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          //   prefixIcon: Icon(Icons.note),
                          hintText: 'Description',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
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
                      IntlPhoneField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          //     prefixIcon: Icon(Icons.mobile_screen_share),
                          hintText: 'Mobile Number',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                        ),
                        initialCountryCode: 'IN',
                        onChanged: (phone) {
                          setState(() => mobileNumber = phone.completeNumber);
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
                      SizedBox(
                        height: 20.0,
                      ),
                      TextFormField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          //   prefixIcon: Icon(Icons.home),
                          hintText: 'Account Number',
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 3.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.pinkAccent, width: 2.0)),
                        ),
                        onChanged: (val) {
                          setState(() => accountNo = val);
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return "Please enter Account number";
                          }
                          if (value.length < 10) {
                            return "Please enter valid Account number";
                          }
                        },
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      DropdownButtonFormField<String>(
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
                        hint: Text("Select Your Category"),
                      ),
                      /*Text(
                  "$value1",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                */

                      SizedBox(
                        height: 10.0,
                      ),
                      /*
                RaisedButton(
                  child: Text("Select your sub category"),
                  onPressed: () => _showMultiSelect(context),
                ),
                */

                      DropdownButtonFormField<String>(
                        items: category,
                        onChanged: disabledropdown
                            ? null
                            : (_value) => secondselected(_value),
                        validator: (value) => value == null
                            ? 'Please select your sub category'
                            : null,
                        hint: Text("Select your sub category"),
                        disabledHint: Text("Select your sub category"),
                      ),
                      /* Text(
                  "$value2",
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                */

                      SizedBox(
                        height: 32.0,
                      ),
                      Text(
                        'Upload Certificates',
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                      Row(children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints.tightFor(width: 200.0),
                          child: new SwitchListTile.adaptive(
                            title: new Text('Add multiple certificates',
                                textAlign: TextAlign.left),
                            onChanged: (bool value) =>
                                setState(() => isMultiPick = value),
                            value: isMultiPick,
                          ),
                        ),
                        FloatingActionButton(
                          backgroundColor: Colors.blue[700],
                          child: Icon(Icons.add),
                          onPressed: () => _openFileExplorer(),
                        ),
                      ]),
                      Builder(
                        builder: (BuildContext context) => isLoadingPath
                            ? Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: const CircularProgressIndicator())
                            : path != null || paths != null
                                ? new Container(
                                    padding:
                                        const EdgeInsets.only(bottom: 30.0),
                                    height: MediaQuery.of(context).size.height *
                                        0.50,
                                    child: new Scrollbar(
                                        child: new ListView.separated(
                                      itemCount:
                                          paths != null && paths.isNotEmpty
                                              ? paths.length
                                              : 1,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final bool isMultiPath =
                                            paths != null && paths.isNotEmpty;
                                        final int fileNo = index + 1;
                                        final String name = 'File $fileNo : ' +
                                            (isMultiPath
                                                ? paths.keys.toList()[index]
                                                : fileName ?? '...');
                                        final filePath = isMultiPath
                                            ? paths.values
                                                .toList()[index]
                                                .toString()
                                            : path;
                                        return new ListTile(
                                          title: new Text(
                                            name,
                                          ),
                                          subtitle: new Text(filePath),
                                        );
                                      },
                                      separatorBuilder:
                                          (BuildContext context, int index) =>
                                              new Divider(),
                                    )),
                                  )
                                : new Container(),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      RaisedButton(
                        onPressed: () async {
                          if (_formkey.currentState.validate()) {
                            ref.child("name").set(name);
                            ref.child("description").set(description);
                            ref.child("mobileNumber").set(mobileNumber);
                            ref.child("accountNo").set(accountNo);
                            ref.child("field").set(value1);
                            ref.child("subField").set(value2);
                            // ref.child("proPic").set(__image.path);
                            //      ref.child("file").set(path);

                            //  uploadPic(context);
                            //    uploadFile(context);
                            setState(() {
                              loading = true;
                            });
                            if (id == null) {
                              setState(() {
                                error =
                                    'could not sign in with those credentials';
                                loading = false;
                              });
                            }
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => Home()));
                          }
                        },
                        color: Colors.blue[700],
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                    ],
                  ),
                )),
          );
  }
}
