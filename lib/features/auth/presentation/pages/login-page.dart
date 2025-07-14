import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/auth/presentation/pages/reset-password-page.dart';
import 'package:social_app/features/auth/presentation/widgets/login-button.dart';
import 'package:social_app/features/auth/presentation/widgets/text-field-eyes.dart';
import 'package:social_app/features/auth/presentation/widgets/text-field.dart';

class LoginPage extends StatefulWidget {
  final Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginpageState();
}

class _LoginpageState extends State<LoginPage> {
  bool _isSecurePassword = true;
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void login() {
    final String email = emailController.text;
    final String pw = pwController.text;
    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && pw.isNotEmpty) {
      authCubit.login(email, pw);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
          const SnackBar(
              content: Text(
                  'Please enter your email and password',
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
  void dispose() {
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 120),
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
              const SizedBox(height: 80),
              Text(
                'Log in to continue',
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
              const SizedBox(height: 10),
              MyTextFieldEyes(
                suffixIcon: togglePassword(),
                controller: pwController,
                hintText: 'Password',
                obcureText: _isSecurePassword,
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(
                      builder: (context) => const ResetPasswordPage()
                    ),
                  );
                },
                  child: const Padding(
                    padding: EdgeInsets.only(left: 180),
                    child: Text(
                      'Forgot Your Password?',
                      style: TextStyle(
                        fontWeight: FontWeight.w300
                      ),
                    ),
                  ),
              ),
              const SizedBox(height: 8),
              MyLoginButton(
                  onTap: login,
                  text: 'Login'
              ),
              const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Dont you have an account?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: const Text(
                        ' Register',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  Widget togglePassword() {
    return IconButton(
        onPressed: () {
          setState(() {
            _isSecurePassword = !_isSecurePassword;
          });
        },
        icon: _isSecurePassword ?
        const Icon(Icons.visibility) :
        const Icon(Icons.visibility_off_sharp),
        color: Theme.of(context).colorScheme.tertiaryFixed,
    );
  }
}
