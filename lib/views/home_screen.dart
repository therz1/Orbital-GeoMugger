import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_location_page.dart';
import 'home_view.dart';
import 'saved_view.dart';
import 'profile_view.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// File contains the home screen after successful login.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //generate location ID for every new location added. need to change from stateless to stateful
    final String newLocationId = FirebaseFirestore.instance.collection('locations').doc().id;
    Widget currentBodyView;
    switch(_selectedIndex) {
      case 0:
        currentBodyView = const HomeView();
        break;
      case 1:
        currentBodyView = const SavedView();
        break;
      case 2:
        currentBodyView = AddLocationPage(locationId: newLocationId);
        break;
      case 3:
        currentBodyView = const ProfileView();
        break;
      default:
        currentBodyView = const HomeView();
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('GeoMugger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            tooltip: 'Logout',
            onPressed: () async {
              // 1. Trigger the Firebase sign out routine pipeline
              await AuthService().logout();

              // 2. Clear navigation stack and bounce back to the login gateway
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
                }
            },
          ),
        ],
      ),
      
      body: currentBodyView,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orange[900]!,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.add_location_alt), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],

        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );  
  }
}


