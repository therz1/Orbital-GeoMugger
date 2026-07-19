import 'package:flutter/material.dart';
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
            const OnboardingPage(),
            ],
          ),
        ),
      );
    }
}

