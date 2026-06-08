import 'package:flutter/material.dart' ;
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

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final String review = _reviewController.text.trim();

    final String? errorResult = await LocationService().addReview(
      locationId: widget.locationId,
      review: review,
      rating: _currentRating,
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