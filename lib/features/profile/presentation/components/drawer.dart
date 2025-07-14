import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubits/auth_cubit.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
            'Settings and actions',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white60,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        context.read<AuthCubit>().logout();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Log out of your account',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      )
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
