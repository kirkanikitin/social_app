import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoreMenu extends StatelessWidget {
  final void Function()? onDeletePressed;
  final dynamic icons;
  const MoreMenu({
    super.key,
    required this.onDeletePressed,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
        shadowColor: Colors.black,
        elevation: 20,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(15)
          ),
        ),
        offset: const Offset(0, 65),
        menuPadding: const EdgeInsets.symmetric(horizontal: 10),
        surfaceTintColor: Colors.grey,
        icon: icons,
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: onDeletePressed,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                Icon(
                  Icons.delete,
                  color: Colors.red,
                )
              ],
            ),
          ),
        ]
    );
  }
}
