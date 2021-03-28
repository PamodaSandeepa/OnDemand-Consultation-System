import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebaseapp/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth
      .instance; //FirebaseAuth is a class(type of a object).we make private property name _auth
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  //Create user obj based on firebase user
  User _userFromFirebaseUser(FirebaseUser user) {
    //Firebase user to regular user method
    return user != null ? User(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
    //  .map((FirebaseUser user)=>_userFromFirebaseUser(user));  //firebaseUser mapping into our user
  }

  //Sign in anon
  Future signInAnon() async {
    try {
      AuthResult result = await _auth
          .signInAnonymously(); //AuthResult is a type of object.result is a object.
      FirebaseUser user1 = result.user; //FirebaseUser is a type of object
      return _userFromFirebaseUser(user1); //firebase user to regular user
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Sign in E-mail and Password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email,
          password:
              password); //create user with email and password (built in firebase auth method)
      FirebaseUser user2 = result.user;
      return _userFromFirebaseUser(
          user2); //firebase user to regular user based on User model(user.dart)
    } catch (e) {
      return null;
    }
  }

  //register Email and Password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password:
              password); //create user with email and password (built in firebase auth method)
      FirebaseUser user2 = result.user;
      //  return null;
      return _userFromFirebaseUser(
          user2); //firebase user to regular user based on User model(user.dart)
    } catch (e) {
      return null;
    }
  }

  //Sign out
  Future signOut() async {
    FirebaseUser user = await _auth.currentUser();
    try {
      print(user.providerData[1].providerId);
      if (user.providerData[1].providerId == 'google.com') {
        return await _googleSignIn.disconnect();
      }
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

//google sign in
  Future<bool> googleSignIn1() async {
    GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      AuthResult result = await _auth.signInWithCredential(credential);

      FirebaseUser user = await _auth.currentUser();

      print(user.uid);
      return true;

      // return null;
    }
  }

  Future<bool> validatePassword(String password) async {
    var firebaseUser = await _auth.currentUser();

    var authCredentials = EmailAuthProvider.getCredential(
        email: firebaseUser.email, password: password);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updatePassword(String password) async {
    var firebaseUser = await _auth.currentUser();
    firebaseUser.updatePassword(password);
  }
}
