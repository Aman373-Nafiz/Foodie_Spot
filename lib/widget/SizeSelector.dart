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
              _buildSizeButton('6', sizes.length > 0 ? sizes[0].toString() : '', selectedSize == '6'),
              const SizedBox(width: 12),
              if (sizes.length > 1)
                _buildSizeButton('9', sizes[1].toString(), selectedSize == '9'),
              const SizedBox(width: 12),
              if (sizes.length > 2)
                _buildSizeButton('12', sizes[2].toString(), selectedSize == '12'),
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