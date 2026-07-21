import 'package:flutter/material.dart';

class SetUsernameView extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback nextPage;

  const SetUsernameView({super.key, required this.controller, required this.nextPage});
  
  @override

  Widget build(BuildContext context) {
    return Padding(
      padding:const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Text('Welcome to\nGeoMugger',
          style: TextStyle(fontSize:45, fontWeight:FontWeight.bold)),
          const SizedBox(height:30),
          const Text("Profile Customisation:", style: TextStyle(fontSize:18)),
          const Text("Please tell us more about youself!", style: TextStyle(fontSize:18)),
          const SizedBox(height:40),
          const Text("Set a username:",
          style: TextStyle(fontSize: 18, fontWeight:FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter your name here",
              fillColor: Colors.grey[200],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            ),
            const Spacer(),
            Center(
              child: Center(
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, child) {
                    final bool isTextEmpty = value.text.trim().isEmpty;
                    return ElevatedButton(
                    onPressed: isTextEmpty ? null : nextPage,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: isTextEmpty ? const Color.fromARGB(255, 106, 105, 105): Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal:60, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(30)),
                    ),
                    child: const Text("next", style: TextStyle(color: Colors.black, fontSize:18)),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height:40),
        ],
      ),
    );
  }
}