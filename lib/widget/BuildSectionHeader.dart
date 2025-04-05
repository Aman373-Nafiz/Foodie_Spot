import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildSectionHeader(String title) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    ),
  );
}
