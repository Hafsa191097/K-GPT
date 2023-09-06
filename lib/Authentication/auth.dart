import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Screens/GptScreen.dart';

class FirebaseAuthentication{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  
  
  Future<void> handleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential authResult = await _auth.signInWithCredential(credential);
        final User? userr = authResult.user;
        print('User signed in with Google: ${userr?.displayName}');
        if (userr != null) {
          
          final userData = {
            'Email': userr.email,
          };
          await saveUserDataToFirestore(userr, userData);
        }
        Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GptScreen()),
      );
      }
    } catch (error) {
      print('Google Sign-In Error: $error');
    }
  }
  Future<void> saveUserDataToFirestore(User user, Map<String, dynamic> userData) async {
    try {
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(user.uid);
      await userDocRef.set(userData);
    } catch (error) {
      print(error);
    }
  }
  Future<void> signOut() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  }

  
}