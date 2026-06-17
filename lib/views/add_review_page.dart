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

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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
      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review added successfully"), backgroundColor: Colors.green),
      );
      //Navigator.pop(context);
      _reviewController.clear();
      setState(() {
        _currentRating = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
      ),
      body: Padding(
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