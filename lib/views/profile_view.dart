import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_mugger/services/auth_service.dart';
import 'package:geo_mugger/views/login/welcome_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await AuthService().logout;
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const WelcomeView()),
          (route) => false,
        );
      }
    } catch (e) {
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out $e'),
          )
          );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold (
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('user').doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasError) {
              return Center(child: Text('Error loading profile: ${snapshot.error}'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.black));
            }
  
            final userData = snapshot.data?.data() as Map<String, dynamic>?;
            final String username = userData?['username'] ?? 'No Username Set';
            final String? profilePicUrl = userData?['profilePicUrl'];
            return Column(
              children: [
                SizedBox(height: 80),
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.grey,
                    backgroundImage: profilePicUrl != null ? 
                    NetworkImage(profilePicUrl) : null,
                    child: profilePicUrl == null ? 
                    const Icon(Icons.person_outline,
                    size:80,
                    color: Colors.black) : null,
                  ),
                  ),
                const SizedBox(height: 24),
                Text(username, 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
                const Spacer(),
                const Text("more info TBA!"),
                const Spacer(),


                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: 
                  SizedBox(
                    height:46,
                    width: 160,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.black,
                        elevation:4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => _handleLogout(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[Text('log out',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        SizedBox(width: 6),
                        Icon(Icons.logout, size:20) 
                        ],
                      )
                      ),
                  ),
                )
                ],
            );
          },
        ),
      ),
    );
  }
}
