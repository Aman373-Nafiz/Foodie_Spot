import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isObscure;
  final String? Function(String?)? validator;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isObscure = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black54),
            hintText: "Enter $label",
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Color(0xFFFF9B43), width: 2.0)
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.black45, width: 2.0)
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.red, width: 1.0)
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isObscure;
  final String? Function(String?)? validator;
  final VoidCallback onToggleVisibility;

  const CustomPasswordField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.isObscure,
    required this.onToggleVisibility,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          obscureText: isObscure,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.black54),
            hintText: "Enter $label",
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Color(0xFFFF9B43), width: 2.0)
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.black45, width: 2.0)
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.red, width: 1.0)
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.black54,
              ),
              onPressed: onToggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}