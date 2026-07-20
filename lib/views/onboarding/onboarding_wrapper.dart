import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final PageController _pageController = PageController();
  final TextEditingController _usernameController = TextEditingController();

  XFile? _pickerFile;
  String? _webImagePreviewUrl;
  File? _capturedImage;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? selected = await _picker.pickImage(
        source: ImageSource.gallery,
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

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds:300),
      curve: Curves.easeInOut
    );
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
              nextPage: () {_nextPage();},
            ),
            SetProfilePicView(selectedImage: _capturedImage, webImageUrl: _webImagePreviewUrl, pickImage: _pickImage, nextPage: _nextPage, skipPage: _nextPage),
            const SetUserPreferenceView(),
            ],
          ),
        ),
      );
    }
}

