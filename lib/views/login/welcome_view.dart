
import 'package:flutter/material.dart';
import 'package:geo_mugger/views/login/login_view.dart';
import 'package:geo_mugger/views/login/sign_up_view.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange[900]!, Colors.orange[700]!, Colors.yellow[300]!],
          ),
        ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("Welcome to\nGeoMugger",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2),
                ),
                const SizedBox(height:60),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const LoginView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange[900]!,
                    minimumSize: const Size(200,50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4,
                  ),
                  child: const Text("login", style: TextStyle(fontWeight:FontWeight.bold, fontSize:16)),
                ),
                const SizedBox(height:20),
      
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SignUpView()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.orange[900]!,
                    minimumSize: const Size(200,50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 4
      
                  ),
                  child: const Text("sign-up", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                )
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}