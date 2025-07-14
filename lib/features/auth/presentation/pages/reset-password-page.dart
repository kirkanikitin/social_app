import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_app/features/auth/presentation/widgets/text-field.dart';

import '../widgets/login-button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    final String email = emailController.text;
    if (email.isNotEmpty) {
      try {
        await firebaseAuth.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(vertical: 250, horizontal: 30),
                backgroundColor: Theme.of(context).colorScheme.primary,
                content: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Image(
                        image: AssetImage('lib/assets/icons/done-icon.png'),
                        width: 150,
                      ),
                       Text(
                         'Done',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                       ),
                      SizedBox(height: 20),
                      Text(
                        'We have sent messages to your email address.',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
              );
            }
        );
      } on FirebaseAuthException catch (e) {
        print(e);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          }
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your email',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text(
          'Reset Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Image(
              image: AssetImage('lib/assets/icons/icon.png'),
              width: 160,
            ),
            const Text(
              'Instagrym',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 45,
              ),
            ),
            const SizedBox(height: 130),
            Text(
              'Enter your email address to continue',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 17,
                color: Theme.of(context).colorScheme.secondaryFixed,
              ),
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: emailController,
              textCatapilization: TextCapitalization.none,
              hintText: 'Email',
              obcureText: false,
            ),
            const SizedBox(height: 15),
            MyLoginButton(
                onTap: passwordReset,
                text: 'Reset'
            ),
          ],
        ),
      ),
    );
  }
}
