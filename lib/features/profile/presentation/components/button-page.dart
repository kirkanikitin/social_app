import 'package:flutter/material.dart';

class MyButtonPage extends StatelessWidget {
  final String title;
  final void Function()? onTab;
  const MyButtonPage({
    super.key,
    required this.title,
    required this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.secondary
        ),
        child: GestureDetector(
          onTap: onTab,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, bottom: 7, top: 7),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
      ),
    );
  }
}
