import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import '../widgets/login-button.dart';
import '../widgets/text-field-eyes.dart';
import '../widgets/text-field.dart';
import 'package:social_app/features/auth/presentation/cubits/auth-states.dart';

class RegisterPage extends StatefulWidget {
  final Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isSecurePassword = true;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  void register() {
    final String name = nameController.text.trim();
    final String email = emailController.text.trim();
    final String pw = pwController.text.trim();
    final authCubit = context.read<AuthCubit>();

    if (email.isNotEmpty && name.isNotEmpty && pw.isNotEmpty) {
      authCubit.register(name, email, pw);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields'),
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    pwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
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
                const SizedBox(height: 30),
                Text(
                  'Register to continue',
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondaryFixed,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: nameController,
                  textCatapilization: TextCapitalization.sentences,
                  hintText: 'Name',
                  obcureText: false,
                ),
                const SizedBox(height: 10),
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
                const SizedBox(height: 15),
                MyLoginButton(
                  onTap: register,
                  text: 'Register',
                ),
                const SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Do you already have an account?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: const Text(
                        ' Log in',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      icon: _isSecurePassword
          ? const Icon(Icons.visibility)
          : const Icon(Icons.visibility_off_sharp),
      color: Theme.of(context).colorScheme.tertiaryFixed,
    );
  }
}
