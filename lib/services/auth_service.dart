import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';

class AuthService {
  // create user with email and password
  Future<String?> signup({
    required String email,
    required String password
  }) async {

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password
      );
      return null; // Successful signup

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
      return message; 
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }


  // sign in with email and password
  Future<String?> login({
    required String email,
    required String password
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password
      );
      return null; // Successful login

    } on FirebaseAuthException catch(e) {
      // error messages
      String message = '';
      if (e.code == 'user-not-found' || e.code == 'wrong-password'){
        message = 'Invalid email or password.';
      } else {
        message = 'An error occurred. Please try again.';
      }
      return message;
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // sign out
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
  
}