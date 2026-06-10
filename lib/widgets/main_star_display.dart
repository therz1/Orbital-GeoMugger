import 'package:flutter/material.dart';

class AppColors {
  static const Color secondaryContainerGray = Color(0xFFB0BEC5);
  static const Color ratingPrimaryColor = Color(0xFFFFD700); // Gold color for rating stars
}

// Modify to instead find avg rating then display that
class MainStarRatingWidget extends StatelessWidget {
  final int starCount;
  final double rating;
  final Color? color;
  const MainStarRatingWidget({
    super.key,
    this.starCount = 5,  // Default to 5 stars
    required this.rating,  // Default rating is 0
    this.color,  // Optional: custom color for stars
  });


  Widget buildStar(BuildContext context, int index) {
    IconData iconData;
    // rounding up/down to nearest half star
    if (rating >= index + 1) {
      iconData = Icons.star; // Full star
    } else if (rating > index && rating < index + 1) {
      iconData = Icons.star_half; // Half star
    } else {
      iconData = Icons.star_border; // Empty star
    }
    return Icon(iconData, color: color ?? AppColors.ratingPrimaryColor);
  }

  @override
  Widget build(final BuildContext context) {
    // Creating a row of stars based on the starCount
    return Row(
      children: List.generate(
        starCount,  // Generate a row with 'starCount' stars
        (final index) => buildStar(context, index),
      ),
    );
  }
}