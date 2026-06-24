import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';

class AuthService {
  // create user with email and password
  Future<String?> signup({
    required String email,
    required String password
  }) async {
    final cleanEmail = email.trim();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: cleanEmail, password: password
      );
      final User? user = userCredential.user;
// 
      if(user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': cleanEmail,
          'hasCompletedOnboarding': false,
          'preferredTags': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
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
      final cleanEmail = email.trim();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail, 
        password: password
      );
      return null; // Successful login

    } on FirebaseAuthException catch(e) {
      // error messages
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        return 'The email address format is badly formatted.';
      } else if (e.code == 'user-disabled') {
        return 'This account has been disabled.';
      }
      return 'Login failed: ${e.message ?? "Please try again."}';
    } catch (e) {
      return 'An error occurred. Please try again.';
    }
  }

  // sign out
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
  
}