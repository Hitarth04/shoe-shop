import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'dart:math' as math;

class SizeSelector extends StatelessWidget {
  final List<String> availableSizes;
  final String? selectedSize;
  final Function(String) onSizeSelected;

  const SizeSelector({
    super.key,
    required this.availableSizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define standard sizes
    final List<String> allSizes = ['6', '7', '8', '9', '10', '11', '12'];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: allSizes.map((size) {
        final bool isAvailable = availableSizes.contains(size);
        final bool isSelected = selectedSize == size;

        return GestureDetector(
          onTap: isAvailable ? () => onSizeSelected(size) : null,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The Circle Container
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppConstants.primaryColor
                      : (isAvailable ? Colors.white : Colors.grey.shade100),
                  border: Border.all(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : (isAvailable
                            ? Colors.grey.shade400
                            : Colors.grey.shade300),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isAvailable ? Colors.black : Colors.grey.shade400),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),

              // The "Strike Through" Line (Only if unavailable)
              if (!isAvailable)
                Transform.rotate(
                  angle: -math.pi / 4, // -45 degrees
                  child: Container(
                    width: 45,
                    height: 1.5, // Thickness of the line
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
