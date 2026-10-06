import 'package:flutter/material.dart';

/// Shows a row of star icons plus the numeric rating.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 15,
    this.showValue = true,
    this.starColor = const Color(0xFFF2A03D),
  });

  final double rating;
  final double size;
  final bool showValue;
  final Color starColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 1; i <= 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Icon(
              rating >= i
                  ? Icons.star
                  : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border),
              size: size,
              color: starColor,
            ),
          ),
        if (showValue) ...<Widget>[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size - 1,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ],
    );
  }
}
