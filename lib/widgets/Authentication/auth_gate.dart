import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_mugger/views/home_screen.dart';
import 'package:geo_mugger/views/login_screen.dart';
import 'package:geo_mugger/views/onboarding_page.dart';


//to dictate which screen to go to
class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      //check if user is logged in
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        //when loading credential so it does not just freeze.
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

//case 1: when no user log in
        if(!authSnapshot.hasData || authSnapshot.data == null) {
          return LoginScreen();
        }
        final User user = authSnapshot.data!;

//case 2: user logged in
        return FutureBuilder<DocumentSnapshot> (
          //gather user info
          future: FirebaseFirestore.instance.collection('user').doc(user.uid).get(),
          builder: (context, firestoreSnapshot) {
            if(firestoreSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }
//if user has no completed onboarding set up
            if(!firestoreSnapshot.hasData || !firestoreSnapshot.data!.exists) {
              return OnboardingPage();
            }
            final data = firestoreSnapshot.data!.data() as Map<String, dynamic> ?;
            final bool hasCompletedOnboarding = data?['hasCompletedOnboarding'] ?? false;
//final check if user completed onboarding
            if(hasCompletedOnboarding) {
              return HomePage();
            } else {
              return OnboardingPage();
            }
            },
        );
      },
    );
  }
}