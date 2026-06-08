import 'package:flutter/material.dart';
import '../views/add_location_page.dart';
import '../views/home_view.dart';
import '../views/saved_view.dart';
import '../views/profile_view.dart';
import '../services/auth_service.dart';
import '../views/login_screen.dart';

// File contains the home screen after successful login.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _viewOptions = [
    const HomeView(),
    const SavedView(),       
    const AddLocationPage(),
    const ProfileView(),     // <- TBA
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                onPressed: () async {
              await AuthService().logout();
                };
              }
            },
          ),
        ],
      ),
      
      body: _viewOptions[_selectedIndex],
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


