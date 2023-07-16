import 'package:flutter/material.dart';
import '../../config/theme.dart';

class AppTextFieldWithLabel extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const AppTextFieldWithLabel({
    required this.label,
    this.icon,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final leftPosition = 25.0;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kdPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 2,
            spreadRadius: 2,
          )
        ],
      ),
      height: 70,
      child: Stack(
        children: [
          Positioned(
            top: 12.0,
            left: leftPosition,
            child: Row(
              children: [
                icon == null ? SizedBox() : Icon(icon, size: 12),
                icon == null ? SizedBox() : SizedBox(width: 8.0),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 6,
            left: leftPosition - 16,
            right: 0,
            child: TextFormField(
              controller: controller,
              validator: validator,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: kcPrimaryColor),
              decoration: InputDecoration(
                hintText: 'Enter your ${label.toLowerCase()}',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: kcPrimaryColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
