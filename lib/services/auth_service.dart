import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  Future<bool> signup({
    required String email,
    required String password
  }) async {

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password
      );
      return true; // Successful signup

    } on FirebaseAuthException catch(e) {
      // error messages
      String message = '';
      if (e.code == 'weak-password'){
        message = 'Weak Password.';
      } else if (e.code == 'email-already-in-use'){
        message = 'An account already exists with that email';
      } else {
        message = 'An error occurred. Please try again.';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return false;
    }
  }

}