import 'package:flutter/material.dart';
import 'add_location_page.dart';
import 'home_view.dart';
import 'saved_view.dart';
import 'profile_view.dart';

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
    const SavedView(),       // <- TBA
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


