import 'package:flutter/material.dart';

class LabeledTextField extends StatefulWidget {
  const LabeledTextField(
      {super.key,
      this.controller,
      required this.label,
      this.hinttext,
      this.isPassword = false,
      this.validator});
  final TextEditingController? controller;
  final String label;
  final String? hinttext;
  final bool isPassword;
  final String? Function(String?)? validator;
  @override
  State<LabeledTextField> createState() => _LabeledTextFieldState();
}

class _LabeledTextFieldState extends State<LabeledTextField> {
  late bool _obscureText = widget.isPassword;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          cursorColor: Colors.white,
          validator: widget.validator,
          obscureText: _obscureText,
          controller: widget.controller,
          keyboardType: widget.isPassword
              ? TextInputType.visiblePassword
              : TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: widget.hinttext,
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(.3),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () {
                      _obscureText = !_obscureText;
                      if (mounted) setState(() {});
                    },
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white.withOpacity(.3),
                    ),
                  )
                : null,
          ),
        )
      ],
    );
  }
}
