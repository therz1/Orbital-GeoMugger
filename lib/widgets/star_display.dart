import 'package:flutter/material.dart';
import '../services/location_service.dart';

class AppColors {
  static const Color secondaryContainerGray = Color(0xFFB0BEC5);
  static const Color ratingPrimaryColor = Color(0xFFFFD700); // Gold color for rating stars
}

class StarRatingWidget extends StatelessWidget {
  final int starCount;
  final int rating;
  final Color? color;
  const StarRatingWidget({
    super.key,
    this.starCount = 5,  // Default to 5 stars
    this.rating = 0,  // Default rating is 0
    this.color,  // Optional: custom color for stars
  });


  Widget buildStar(BuildContext context, int index) {
    IconData iconData;
    // rounding up/down to nearest half star
    if (index < rating.floor()) {
      iconData = Icons.star; // Full star
    } else if (index < rating.ceil()) {
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