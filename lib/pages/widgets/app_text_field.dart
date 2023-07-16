import 'package:flutter/material.dart';

import '../../config/theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    Key? key,
    required this.placeHolder,
    this.suffixIcon,
    this.validator,
    this.controller,
    this.obscureText = false,
    this.suffix,
    this.withBottomPadding = true,
    this.onTap,
    this.enabled = true,
    this.borderColor = Colors.white,
    this.hPadding = kdPadding,
    this.textColor = Colors.white,
  }) : super(key: key);

  final String placeHolder;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffix;
  final bool withBottomPadding;
  final void Function()? onTap;
  final bool enabled;
  final Color borderColor;
  final double hPadding;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: GestureDetector(
            onTap: onTap,
            child: TextFormField(
              enabled: enabled,
              validator: validator,
              controller: controller,
              cursorColor: kcPrimaryColor,
              obscureText: obscureText,
              style: TextStyle(color: textColor, fontSize: 14),
              decoration: InputDecoration(
                suffixIcon: suffixIcon,
                hintText: placeHolder,
                hintStyle: TextStyle(fontSize: 11, color: borderColor),
                contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                  borderRadius: BorderRadius.circular(kdBorderRadius),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: borderColor,
                  ),
                  borderRadius: BorderRadius.circular(kdBorderRadius),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(kdBorderRadius),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(kdBorderRadius),
                ),
                focusColor: borderColor,
                suffix: suffix,
              ),
            ),
          ),
        ),
        SizedBox(height: withBottomPadding ? 36 : 0),
      ],
    );
  }
}
