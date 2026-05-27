import 'package:flutter/material.dart';
import '../services/auth_service.dart';

// File contains the home screen after successful login.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoMugger Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Welcome to the GeoMugger Dashboard!'),
      ),
    );
  }
}