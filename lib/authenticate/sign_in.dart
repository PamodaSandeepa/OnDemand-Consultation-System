import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/Animation/animation.dart';
import 'package:firebaseapp/authenticate/reset.dart';
import 'package:firebaseapp/home/home.dart';
import 'package:firebaseapp/services/auth.dart';
import 'package:firebaseapp/shared/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  final Function tv;
  //create constructor for the SignIn widget
  SignIn({this.tv});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth =
      AuthService(); //class(Auth Service widget) eke object ekak create kala

  final FirebaseAuth __auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> googleSignIn2() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      AuthResult result = await __auth.signInWithCredential(credential);

      FirebaseUser user = await __auth.currentUser();

      print(user.uid);
      return true;

      // return null;
    }
  }

  final _formkey = GlobalKey<FormState>(); //help the validate

  bool loading = false; //for loading screen

  //text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            //if loading is true then return the loading screen else back to current page
            backgroundColor: Colors.blue[100],
            /* appBar:  AppBar(
        backgroundColor: Colors.blue[400],
        elevation: 0.0, //remove drop shadow
        title: Center(child: Text('Sign in')),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text('Register'),
            onPressed: () {
              widget.tv();  //widget refers to SignIn widget.cant write this.tv cuz this refers <state> object
                            //when we call tv it's call to toggleView() function
            },
          )
        ],

      ), */
            body: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        colors: [
                      Colors.blue[900],
                      Colors.blue[600],
                      Colors.blue[400]
                    ])),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 60,
                      ),
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FadeAnimation(
                                1,
                                Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 50),
                                )),
                            SizedBox(
                              height: 10,
                            ),
                            FadeAnimation(
                                1.3,
                                Text(
                                  "Welcome Back",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30))),
                          child: SingleChildScrollView(
                              child: Column(
                            children: [
                              FadeAnimation(
                                1.4,
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20.0, horizontal: 30.0),
                                    child: Form(
                                      key: _formkey,
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                            height: 70.0,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'E-mail',
                                              prefixIcon: Icon(Icons.person),
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

                                            validator: (val) => val.isEmpty
                                                ? 'Enter an email'
                                                : null, //Empty or not
                                            onChanged: (val) {
                                              //val means curren value in form field
                                              setState(() => email = val);
                                            },
                                          ),
                                          SizedBox(
                                            height: 20.0,
                                          ),
                                          TextFormField(
                                            decoration: InputDecoration(
                                              hintText: 'Password',
                                              prefixIcon: Icon(Icons.lock),
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

                                            validator: (val) => val.length < 6
                                                ? 'Enter an password 6+ chars long'
                                                : null,
                                            obscureText: true, //don't see text
                                            onChanged: (val) {
                                              setState(() => password = val);
                                            },
                                          ),
                                        ],
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              FadeAnimation(
                                  1.5,
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => ResetScreen()),
                                    ),
                                    child: Text(
                                      "Forgot Password?",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  )),
                              SizedBox(
                                height: 20,
                              ),
                              FadeAnimation(
                                1.6,
                                Container(
                                  padding: EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: RaisedButton(
                                            onPressed: () async {
                                              if (_formkey.currentState
                                                  .validate()) {
                                                //valid or not
                                                setState(() {
                                                  loading =
                                                      true; //valid nam loading wenawa
                                                });

                                                dynamic result = await _auth
                                                    .signInWithEmailAndPassword(
                                                        email, password);
                                                if (result == null) {
                                                  setState(() {
                                                    error =
                                                        'could not sign in with those credentials';
                                                    loading = false;
                                                  });
                                                } //else is sucessfully registered.get that user back.go to (main.dart)
                                              }
                                            },
                                            color: Colors.blue,
                                            child: Text(
                                              'Log In',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0,
                                              ),
                                            )),
                                      ),
                                      SizedBox(width: 10.0),
                                      Expanded(
                                        child: RaisedButton(
                                          onPressed: () async {
                                            widget.tv();
                                          },
                                          color: Colors.blue,
                                          child: Text(
                                            'Register',
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
                                    onPressed: () async {
                                      googleSignIn2().whenComplete(() async {
                                        FirebaseUser user = await FirebaseAuth
                                            .instance
                                            .currentUser();
                                        Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) => Home()));
                                      });
                                    },
                                    color: Colors.blue,
                                    child: Text(
                                      'Sign in with Gmail',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 20.0,
                              )
                            ],
                          )),
                        ),
                      ),
                    ])));
  }
}
