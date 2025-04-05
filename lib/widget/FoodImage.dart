import 'package:flutter/material.dart';

class FoodImageWidget extends StatelessWidget {
  final String imageUrl;
  final double rating;
  final int ratingCount;

  const FoodImageWidget({
    Key? key,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          onError: (exception, stackTrace) => const Icon(Icons.error),
        ),
      ),
      // child: Align(
      //   alignment: Alignment.bottomRight,
      //   child: Container(
      //     margin: const EdgeInsets.all(12),
      //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.circular(12),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black.withOpacity(0.1),
      //           spreadRadius: 1,
      //           blurRadius: 3,
      //           offset: const Offset(0, 1),
      //         ),
      //       ],
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         const Icon(Icons.star, color: Colors.amber, size: 18),
      //         const SizedBox(width: 4),
      //         Text(
      //           rating.toStringAsFixed(1),
      //           style: const TextStyle(
      //             fontWeight: FontWeight.bold,
      //             fontSize: 16,
      //           ),
      //         ),
      //         Text(
      //           ' ($ratingCount)',
      //           style: TextStyle(
      //             color: Colors.grey.shade600,
      //             fontSize: 14,
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}