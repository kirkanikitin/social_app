import 'package:flutter/material.dart';

class MyTextFieldEdit extends StatelessWidget {
  final TextEditingController controller;
  final textCatapilization;
  final String hintText;
  final bool obcureText;

  const MyTextFieldEdit({
    super.key,
    required this.controller,
    required this.textCatapilization,
    required this.hintText,
    required this.obcureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.tertiaryFixed,
        textCapitalization: textCatapilization,
        textInputAction: TextInputAction.next,
        maxLines: 5,
        minLines: 2,
        maxLength: 50,
        controller: controller,
        obscureText: obcureText,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiaryFixed),
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiaryFixed),
            borderRadius: BorderRadius.circular(17),
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