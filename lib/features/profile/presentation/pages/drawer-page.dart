import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../themes/theme-cubit.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themecubit = context.watch<ThemeCubit>();
    bool isDarkMode = themecubit.isDarkMode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: const Text(
            'Settings and actions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Divider(
                thickness: 5,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 18),
                child: Text(
                  'Topic',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 15),
               Row(
                children: [
                  const SizedBox(width: 15),
                  Image(
                    image: const AssetImage('lib/assets/icons/moon.png'),
                    width: 26,
                    color: Theme.of(context).colorScheme.inverseSurface,
                  ),
                  const SizedBox(width: 20),
                  Text(
                      'Dark Mode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                  ),
                  const Spacer(),
                  CupertinoSwitch(
                      value: isDarkMode,
                      onChanged: (value) {
                        themecubit.toggleTheme();
                      }
                  ),
                  const SizedBox(width: 15),
                ],
              ),
              const SizedBox(height: 15),
              Divider(
                thickness: 5,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.only(left: 18),
                child: Text(
                    'entrance',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthCubit>().logout();
                  Navigator.pop(context);
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}
