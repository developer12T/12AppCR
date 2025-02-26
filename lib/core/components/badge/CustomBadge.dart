import 'package:_12sale_app/core/styles/style.dart';
import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final String label;
  final String count;
  final Color backgroundColor;
  final Color labelColor;
  final Color countBackgroundColor;
  final Color countTextColor;
  final double widthFactor;
  final double countWidthFactor;

  const CustomBadge({
    Key? key,
    required this.label,
    required this.count,
    required this.backgroundColor,
    this.labelColor = Colors.white,
    this.countBackgroundColor = Colors.white,
    this.countTextColor = Colors.black,
    this.widthFactor = 4,
    this.countWidthFactor = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth / 2.2,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.2), // Shadow color with transparency
            spreadRadius: 2, // Spread of the shadow
            blurRadius: 8, // Blur radius of the shadow
            offset: const Offset(
                0, 4), // Offset of the shadow (horizontal, vertical)
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            label,
            style: Styles.white18(context),
          ),
          Container(
            margin: const EdgeInsets.all(8),
            width: screenWidth / 18,
            height: screenWidth /
                18, // Set height equal to width to make it a circle
            decoration: BoxDecoration(
              color: countBackgroundColor,
              borderRadius: BorderRadius.circular(360),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.2), // Shadow color with transparency
                  spreadRadius: 2, // Spread of the shadow
                  blurRadius: 8, // Blur radius of the shadow
                  offset: const Offset(
                      0, 4), // Offset of the shadow (horizontal, vertical)
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              count,
              textAlign: TextAlign.center,
              style: Styles.black18(context),
            ),
          ),
        ],
      ),
    );
  }
}
