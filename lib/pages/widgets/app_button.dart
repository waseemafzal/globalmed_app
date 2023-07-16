import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AppButton extends StatelessWidget {
  AppButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundGradient = kcPrimaryColor,
    this.icon,
    this.color1 = const Color(0xff51ACE3),
    this.color2 = const Color(0xff0155C9),
  }) : super(key: key);

  final String text;
  final void Function() onTap;
  final Color? backgroundGradient;
  final IconData? icon;
  final Color color1;
  final Color color2;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(kdBorderRadius),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          // color: backgroundGradient,
          gradient: LinearGradient(
            colors: [color1, color2],
          ),
          borderRadius: BorderRadius.circular(kdBorderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon == null
                ? SizedBox.shrink()
                : Icon(
                    icon,
                    color: Colors.white,
                  ),
            icon == null ? SizedBox.shrink() : SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
