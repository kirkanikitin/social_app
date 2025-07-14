import 'package:flutter/material.dart';

class MyTextFieldEyes extends StatelessWidget {
  final Widget suffixIcon;
  final TextEditingController controller;
  final String hintText;
  final bool obcureText;

  const MyTextFieldEyes({
    super.key,
    required this.suffixIcon,
    required this.controller,
    required this.hintText,
    required this.obcureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        cursorColor: Theme.of(context).colorScheme.tertiaryFixed,
        textInputAction: TextInputAction.next,
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
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
