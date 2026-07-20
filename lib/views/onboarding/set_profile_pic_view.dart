import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SetProfilePicView extends StatelessWidget {
  final File? selectedImage;
  final String? webImageUrl;
  final VoidCallback pickImage;
  final VoidCallback nextPage;
  final VoidCallback skipPage;
  
  const SetProfilePicView({
    super.key,
    required this.selectedImage,
    required this.webImageUrl,
    required this.pickImage,
    required this.nextPage,
    required this.skipPage,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = (kIsWeb && webImageUrl != null) || (!kIsWeb && selectedImage !=null);


    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height:30),
          const Text('Welcome to\nGeoMugger',
          style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold,)),
          const SizedBox(height:30),
          const Text("Profile Customisation:", style: TextStyle(fontSize:18)),
          const Text("Would you like to set a profile picture?", style: TextStyle(fontSize:18)),
          const Spacer(),

          Center(
            child: GestureDetector(
            onTap: pickImage,
            child: Container(
              height: 160,
              width:160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
                image: hasImage?
                DecorationImage(
                  image: kIsWeb ? NetworkImage(webImageUrl!) as ImageProvider:
                  FileImage(selectedImage!) as ImageProvider,
                  fit: BoxFit.cover,) : null,
              ),
              child: ! hasImage ?
              const Icon( Icons.add, size:80, color: Colors.black) : null,
            ),
          ),
          ),

          const Spacer(),
          Center(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed:  hasImage ? nextPage : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasImage ? Colors.orange: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal:60, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),),
                     
                  ),
                  child: const Text("submit", style: TextStyle(color: Colors.black, fontSize: 18))
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: skipPage,
                  child: const Text("skip for now",
                  style: TextStyle(decoration: TextDecoration.underline,
                  color: Colors.grey,
                  fontSize: 16,),),
                ),
              ],
            ),
          ),
          const SizedBox(height:20),
        ],
      ),
    );
  }
}