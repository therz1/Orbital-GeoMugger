import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geo_mugger/widgets/Reviews/tag_selection.dart';
import 'home_view.dart';

//stateful widget because we are keeping track of the tag selection
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  //basically the same as tag_selection logic in add_review and add_location
  final Map<String, List<String>> _tagMap = {
    'Vibes': ['Bright', 'Cozy', 'Chill', 'Dark Academia', 'Library', 'Quiet', 'White noise'],
    'Amenities': ['Air con', 'Comfortable seats', 'Discussion Area', 'Lamp', 'Multiple seats', 'Power Outlet', 'Printer', 'Standing desk' 'Wifi'],
    'Facilities near-by': ['Bus stop', 'Bookshop', 'Car park', 'Convenience store', 'Food Court', 'Garden', 'Public toilet', 'Mall', 'MRT']
  }; //from main.dart

  final List<Map<String, String>> _selectedTags = [];
  bool _isLoading = false;

//reuse from add_location
  Color _tagColor(String cateogry) {
  switch(cateogry) {
    case 'Vibes':
      return const Color.fromARGB(255, 2, 224, 254);
    case 'Amenities':
      return const Color.fromARGB(255, 255, 153, 0);
    case 'Facilities near-by':
      return const Color.fromARGB(255, 112, 187, 69);
    default:
      return Colors.transparent;
  }
  }

  //logic after submission of onboarding page
  Future<void> _savePreferenceAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;
    setState(() => _isLoading = true);

    final List<String> stringTags = _selectedTags.map((tagMap) => tagMap['name'] ?? '')
    .where((name) => name.isNotEmpty).toList();

    try {
      //storing data into firebase
      await FirebaseFirestore.instance.collection('user').doc(user.uid)
      .set({
        'preferredTags': stringTags,
        'hasCompletedOnboarding': true,
        'updatedAt' : FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    if (mounted){
      Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (context) => HomeView()),
      );
    }
  } catch (tagError) {
    setState(() => _isLoading = false);
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving tag preference: $tagError')),
      );
    }
  }
  }
  @override

  Widget build(BuildContext context) {
    //Standard UI stuff
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white
        ),
        child: SafeArea(
          child: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.black)) 
          : Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  children: [
                    SizedBox(height: 20),
                    const Text("What do you look for\nin a study spot?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.3,
                    ),
                    ),
                    SizedBox(height: 20),
                    //reusing tag selection logic from add_locationa again!
                    
                    TagSelection(categoryTitle: 'Vibes', tags: _tagMap['Vibes'] ?? [], selectedTags: _selectedTags, 
                    getTagColor: _tagColor,
                    onTagsAdded: (tag) => setState(() => _selectedTags.add(tag)), 
                    onTagRemoved: (tagName) => setState(() => _selectedTags.removeWhere((t) => t['name'] == tagName)),),

                    TagSelection(categoryTitle: 'Amenities', tags: _tagMap['Amenities'] ?? [], selectedTags: _selectedTags, 
                    getTagColor: _tagColor,
                    onTagsAdded: (tag) => setState(() => _selectedTags.add(tag)), 
                    onTagRemoved: (tagName) => setState(() => _selectedTags.removeWhere((t) => t['name'] == tagName)),),

                    TagSelection(categoryTitle: 'Facilities near-by', tags: _tagMap['Facilities near-by'] ?? [], selectedTags: _selectedTags, 
                    getTagColor: _tagColor,
                    onTagsAdded: (tag) => setState(() => _selectedTags.add(tag)), 
                    onTagRemoved: (tagName) => setState(() => _selectedTags.removeWhere((t) => t['name'] == tagName)),),

                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(28)),
                      elevation: 4,
                    ),
                    onPressed: _selectedTags.isEmpty ? null
                    : _savePreferenceAndNavigate, 
                    child: Text("Get Recommendations", style: TextStyle(fontSize:16, fontWeight:FontWeight.bold),
                    ),
                    ),
                  ),
                  ),
            ],
          ),
    ),
    ),
    );
  }
}
