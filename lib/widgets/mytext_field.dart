import 'package:flutter/material.dart';

class MytextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final TextEditingController controller;
  
  const MytextField({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white12,
        hintText: hintText,

        hintStyle: TextStyle(color: Colors.white),
        prefixIcon: prefixIcon,
        prefixIconColor: Colors.white,

        suffixIconColor: Colors.white,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
