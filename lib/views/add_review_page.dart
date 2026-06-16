import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' ;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../services/location_service.dart';

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

  final ImagePicker _picker = ImagePicker();
  
  XFile? _pickerFile;          // Stores the cross-platform image file reference
  String? _webImagePreviewUrl;  // Stores the browser blob URL string (Web only)
  File? _capturedImage;         // Stores the native File pointer (Mobile only)

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
      imageFile: _pickerFile,
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

  Future<void> _takePhoto() async {
    try {
      // 📸 This single line works perfectly on Web, Android, and iOS!
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70, 
        maxWidth: 1200,
      );

      if (photo != null) {
        setState(() {
          // 1. Save the main cross-platform file container for Firebase
          _pickerFile = photo; 

          // 2. Setup the visual preview based on where the app is running
          if (kIsWeb) {
            // Web browsers look at the XFile path as a temporary blob URL
            _webImagePreviewUrl = photo.path; 
          } else {
            // Mobile devices need a standard File system pointer
            _capturedImage = File(photo.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening camera: $e')),
      );
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
                // Photo Section
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color:Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _pickerFile == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Click to Snap a Photo (Optional)', style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: kIsWeb
                                ? Image.network(_webImagePreviewUrl!, fit: BoxFit.cover, width: double.infinity)
                                : Image.file(_capturedImage!, fit: BoxFit.cover, width: double.infinity),
                          ),
                  ),
                ),
                
                // rating section
                const Text(
                  'Rating', 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    final int starValue = index + 1;
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: starValue <= _currentRating ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                      onPressed: (){ 
                        setState(() => _currentRating = starValue);
                      },
                    );
                  }),
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