import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              border: Border.all(
                color: value ? Colors.green : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
              color: value ? Colors.green : Colors.white,
            ),
            child:
                value
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: value ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
