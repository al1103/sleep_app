import 'package:flutter/material.dart';
import 'package:sleep/core/presentation/widgets/gap.dart';

class TextInput extends StatelessWidget {
  const TextInput({
    super.key,
    this.lable,
    this.controller,
    this.keyboardType,
    this.decoration,
    this.maxLines,
    this.title,
    this.errorText,
    this.validator,
    this.maxLength,
    this.onSaved,
    this.initialValue,
  });
  final String? title;
  final String? lable;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final InputDecoration? decoration;
  final int? maxLines;
  final String? errorText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final void Function(String?)? onSaved;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title?.isNotEmpty ?? false) ...[Text(title!), Gap.h8],
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLength: maxLength,
          validator: validator,
          controller: controller,
          keyboardType: keyboardType,
          initialValue: initialValue,
          decoration: decoration ??
              InputDecoration(
                filled: true,
                hintText: lable,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
          maxLines: maxLines,
          onSaved: onSaved,
        ),
      ],
    );
  }
}
