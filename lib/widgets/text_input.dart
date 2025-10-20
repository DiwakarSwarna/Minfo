import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? suffixIcon;
  final bool showToggle;
  final void Function(String)? onChanged; // ✅ added

  const TextInput({
    super.key,
    required this.label,
    this.hint = '',
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.showToggle = false,
    this.onChanged, // ✅ added
  });

  @override
  State<TextInput> createState() => TextInputState();
}

class TextInputState extends State<TextInput> {
  late bool obscure;

  @override
  void initState() {
    super.initState();
    obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Colors.green, fontSize: 18),
        ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: obscure,
          validator: widget.validator,
          onChanged: widget.onChanged, // ✅ hooked here
          decoration: InputDecoration(
            hintText: widget.hint,
            // hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            //   fontSize: 16,
            //   fontWeight: FontWeight.w300,
            // ),
            suffixIcon:
                widget.showToggle
                    ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                    )
                    : null,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green.shade500, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green),
            ),
          ),
        ),
      ],
    );
  }
}
