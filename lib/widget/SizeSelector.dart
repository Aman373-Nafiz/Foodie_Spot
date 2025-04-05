import 'package:flutter/material.dart';

class SizeSelectorWidget extends StatelessWidget {
  final List<dynamic> sizes;
  final String selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelectorWidget({
    Key? key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if size data is available
    if (sizes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Size',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSizeButton('Small', sizes.length > 0 ? sizes[0].toString() : '', selectedSize == 'Small'),
              const SizedBox(width: 12),
              if (sizes.length > 1)
                _buildSizeButton('Medium', sizes[1].toString(), selectedSize == 'Medium'),
              const SizedBox(width: 12),
              if (sizes.length > 2)
                _buildSizeButton('Large', sizes[2].toString(), selectedSize == 'Large'),
            ],
          ),
        ],
      ),
    );
  }

  // Size Button
  Widget _buildSizeButton(String label, String size, bool isSelected) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onSizeSelected(label);
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.deepOrange : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}