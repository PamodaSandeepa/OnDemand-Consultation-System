import 'package:firebaseapp/authenticate/register.dart';
import 'package:firebaseapp/authenticate/register_start.dart';
import 'package:firebaseapp/authenticate/sign_in.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  //SignIn or Register
  void toggleview() {
    setState(() =>
        showSignIn = !showSignIn); //current showSignIn value eka change wenawa
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(tv: toggleview);
    } else {
      return Register_Start(tv: toggleview);
    }
  }
}
