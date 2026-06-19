import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final int currentRating;
  final ValueChanged<int> onRatingChanged;

  const StarRating({
    super.key,
    required this.currentRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                color: starValue <= currentRating ? Colors.amber : Colors.grey,
                size: 32,
              ),
              onPressed: (){ 
                onRatingChanged(starValue);
              },
            );
          }),
        ),
      ],
    );
  }

}