import 'package:flutter/material.dart';

class TextFieldComment extends StatelessWidget {
  final TextEditingController controller;
  final void Function() addComment;
  const TextFieldComment({
    super.key,
    required this.controller,
    required this.addComment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 10, left: 10),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border.all(color: Theme.of(context).colorScheme.surface)
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
                child: TextField(
                  cursorColor: Colors.black54,
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  obscureText: false,
                  decoration: InputDecoration(
                      hintText: 'Add a comment',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.primaryFixed
                      )
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.blue,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_upward_rounded,
                  color: Colors.grey.shade200,
                ),
                onPressed: () {
                  addComment();
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 7),
          ],
        ),
      ),
    );
  }
}
