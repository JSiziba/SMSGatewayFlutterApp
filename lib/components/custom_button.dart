import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../custom_colors.dart';

class CustomButton extends StatelessWidget {
  final Function() onTap;
  final String title;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.title,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CustomColors.lightPurple,
            width: 1,
          ),
        ),
        child: Center(
          child: !isLoading
              ? Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.lightPurple,
                  ),
                )
              : SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CustomColors.lightPurple,
                  ),
                ),
        ),
      ),
    );
  }
}
