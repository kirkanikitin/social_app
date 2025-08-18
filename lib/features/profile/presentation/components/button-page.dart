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
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.secondary
        ),
        child: GestureDetector(
          onTap: onTab,
          child: Padding(
            padding: const EdgeInsets.only(left: 40, right: 40, bottom: 6, top: 6),
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
