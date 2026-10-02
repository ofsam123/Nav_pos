import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    Key? key,
    required this.text,
    required this.bColor,
    required this.textColor,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final Color bColor, textColor;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: (10), bottom: (5)),
        padding: EdgeInsets.symmetric(horizontal: (14), vertical: (12)),
        decoration: BoxDecoration(
          color: bColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0x809A9A9A),
              blurRadius: 10.0,
              offset: Offset(2.0, 2.0),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: textColor, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
