import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final textCatapilization;
  final String hintText;
  final bool obcureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.textCatapilization,
    required this.hintText,
    required this.obcureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: TextField(
        inputFormatters: [LowerCaseTextFormatter()],
        cursorColor: Theme.of(context).colorScheme.tertiaryFixed,
        textCapitalization: textCatapilization,
        textInputAction: TextInputAction.next,
        controller: controller,
        obscureText: obcureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiaryFixed),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiaryFixed),
            borderRadius: BorderRadius.circular(20),
          ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
        ),
      ),
    );
  }
}
