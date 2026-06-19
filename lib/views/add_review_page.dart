import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' ;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/location_service.dart';
import '../widgets/Reviews/star_rating.dart';
import '../widgets/Reviews/tag_selection.dart';

class AddReviewPage extends StatefulWidget {
  final String locationId;
  final String locationName;
  final String review;
  final int rating;

  const AddReviewPage({
    super.key,
    required this.locationId,
    required this.locationName,
    required this.review,
    required this.rating,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _reviewController = TextEditingController();

  int _currentRating = 0; // Default rating value
  bool _isSaving  = false;
  bool _isLoadingTags = true;

  Map<String, List<String>> _tagMap = {};
  final List<Map<String, String>> _selectedTags = [];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    _fetchTags();
  }

  Future<void> _fetchTags() async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('metadata').doc('tags_list').get();
    if(doc.exists) {
      setState(() {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _tagMap = data.map((key, value) => MapEntry(key, List<String>.from(value),));
        _isLoadingTags = false;
      });
    }
  } catch(error) {
    debugPrint("Error fetching tag Map : $error");
    setState(() => _isLoadingTags = false);
  }
}

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



//reuse from add_location
  void _customTagInputDialog() {
  final TextEditingController customController = TextEditingController();
  String selectedCategory = 'Vibes';
  showDialog(
    context: context,
    builder: (contex) {
      return AlertDialog(
        title: const Text('Add Custom Tag'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: customController,
              decoration: const InputDecoration(hintText: 'e.g. Quiet Zone, Charging Dock'),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setDialogState) {
                return DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: ['Vibes', 'Amenities', 'Facilities near-by'].map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setDialogState(() => selectedCategory = val!),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final text = customController.text.trim();
              if(text.isNotEmpty) {
                setState(() {
                  if(!_tagMap[selectedCategory]!.contains(text)) {
                    _tagMap[selectedCategory]?.add(text);
                  }
                  if(!_selectedTags.any((t) => t['name'] == text)) {
                    _selectedTags.add({'name' : text, 'category': selectedCategory});
                  }
              });
              }
              Navigator.pop(context);
              },
            child: const Text('Add'),
            )
          ],
        );
      },
    );
  }



  void _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    // Ensure a rating is selected before submitting
    if (_currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a rating star!"), 
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final String review = _reviewController.text.trim();

    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String? errorResult = await LocationService().addReviewAndUpdateAverage(
      locationId: widget.locationId,
      review: review,
      rating: _currentRating,
      userId: userId, 
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (errorResult != null) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorResult), backgroundColor: Colors.red),
      );
      //Navigator.pop(context);
    } else {
      try {
        if (_selectedTags.isNotEmpty) {
          await LocationService().updateLocationTags(
            locationId: widget.locationId,
            userSelectedTags: _selectedTags,
          );
        }
        if(! mounted) return; 
        setState(() {
          _isSaving = false;
          _selectedTags.clear();
          _currentRating = 0;
        });
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review added successfully"), backgroundColor: Colors.green),
      );
      //Navigator.pop(context);
      _reviewController.clear();
      } catch (tagError) {
        if(!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Review saved, tags update failed: $tagError"), backgroundColor: Colors.red),
        );
      }
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
      ),
      body: _isLoadingTags ? const Center(child: CircularProgressIndicator()):
       Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                StarRating(
                  currentRating: _currentRating,
                  onRatingChanged: (rating) => setState(() => _currentRating = rating),
                ),
                const Divider(height: 20, thickness: 1),
                const Text('Features of study spots',
                style: TextStyle(fontSize:18, fontWeight: FontWeight.bold, color: Colors.purple),
                ),

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

                const SizedBox(height: 14),

                TextButton.icon(
                  style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.zero),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.purple),
                  label: const Text('Cannot find a tag? Add Custom Tag', style: TextStyle(color: Colors.purple)),
                  onPressed: _customTagInputDialog,
                  ),
    
                const SizedBox(height: 20),

                // review section
                const Text(
                  'Review', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
          
                TextFormField(
                  //expands: true,
                  minLines: 5,
                  maxLines: null,

                  textAlignVertical: TextAlignVertical.top,
                  textAlign: TextAlign.left,

                  controller: _reviewController,
                  decoration: const InputDecoration(
                    //contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 80),
                    border: OutlineInputBorder(),
                    hintText: 'Enter review',
                    //contentPadding: EdgeInsets.all(12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please give your honest review';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),


                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),

                  onPressed: _isSaving ? null : _submitReview,
                  child: _isSaving 
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Add Review', style: TextStyle(fontSize: 16)),
                )
              ]
            ),
          )
        ),
      ),
    );
  }
}