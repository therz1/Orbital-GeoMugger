import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geo_mugger/services/recommendation_service.dart';
import 'package:geo_mugger/views/home_screen.dart';
import 'package:geo_mugger/views/onboarding/set_profile_pic_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geo_mugger/views/onboarding/set_user_preference_view.dart';
import 'package:geo_mugger/views/onboarding/set_username_view.dart';

class OnboardingWrapper extends StatefulWidget {
  const OnboardingWrapper({super.key});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {

//introduce indexed for page navigation
  int _currentStep = 0;
  bool _isLoading = false;

  final PageController _pageController = PageController();
  final TextEditingController _usernameController = TextEditingController();

  XFile? _pickerFile;
  String? _webImagePreviewUrl;
  File? _capturedImage;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> _selectedTags = [];

  void _navigatePage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds:300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth:500,
        maxHeight:500,
        imageQuality: 80,
      );
      if(selected != null) {
        setState (() {
          _pickerFile = selected;

          if(kIsWeb) {
            _webImagePreviewUrl = selected.path;
          } else {
            _capturedImage = File(selected.path);
          }
        });
      }
    } catch (e) {
      debugPrint("error in picking iamge: $e");
    }
  }


//move from previously Onboarding or SetUserProfileView (statueful) file!
  Future<void> _savePreferenceAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    setState(() => _isLoading = true);

    final List<String> stringTags = _selectedTags.map((tagMap) => tagMap['name'] ?? '')
    .where((name) => name.isNotEmpty).toList();

    String? profileImageUrl;

    try {

      if (_pickerFile != null) {
        final storageRef =  FirebaseStorage.instance.ref().child('users').child(user.uid).child('profile_pic.jpg');
        if(kIsWeb) {
          final Uint8List imageBytes = await _pickerFile!.readAsBytes();
          await storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await storageRef.putFile(File(_pickerFile!.path));
        }
        profileImageUrl = await storageRef.getDownloadURL();
      }
      //storing data into firebase
      await FirebaseFirestore.instance.collection('user').doc(user.uid)
      .set({
        'username': _usernameController.text.trim(),
        'profilePicUrl': profileImageUrl,
        'preferredTags': stringTags,
        'hasCompletedOnboarding': true,
        'updatedAt' : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    final recService = RecommendationService();
    await recService.generateAndSaveRecc(user.uid);
    if (mounted){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => HomePage()),
      );
    }
  } catch (error) {
    setState(() => _isLoading = false);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error completing onboarding: $error')),
      );
    }
  }
  }



  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              SetUsernameView(
              controller: _usernameController,
              nextPage: () => _navigatePage(1),
            ),
            SetProfilePicView(
              selectedImage: _capturedImage, 
              webImageUrl: _webImagePreviewUrl, 
              pickImage: _pickImage, 
              nextPage:  () => _navigatePage(2), 
              skipPage: () { setState (() {
                _pickerFile = null;
                _webImagePreviewUrl = null;
                _capturedImage = null;
              });
                _navigatePage(2);
              },
              ),
            SetUserPreferenceView(
              selectedTags: _selectedTags,
              onStateChanged: () => setState(()=>{}),
              onSubmit: _savePreferenceAndNavigate,
            ),
            ],
          ),
        ),
      );
    }
}


