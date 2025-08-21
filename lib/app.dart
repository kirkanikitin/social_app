import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/data/firebase-auth-repo.dart';
import 'package:social_app/features/auth/presentation/cubits/auth-states.dart';
import 'package:social_app/features/post/data/firebase-post-repo.dart';
import 'package:social_app/features/post/presentation/cubits/post-cubit.dart';
import 'package:social_app/features/profile/data/firebase-profile-repo.dart';
import 'package:social_app/features/profile/presentation/cubits/profile-cubit.dart';
import 'package:social_app/features/storage/data/firebase-storage-repo.dart';
import 'package:social_app/home/presentation/components/navigation-bar.dart';
import 'package:social_app/themes/light-mode.dart';
import 'features/auth/presentation/cubits/auth_cubit.dart';
import 'features/auth/presentation/pages/auth-page.dart';

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final firebaseAuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();
  final firebasePostRepo = FirebasePostRepo();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
              lazy: false,
              create: (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
          ),
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                profileRepo: firebaseProfileRepo,
                storageRepo: firebaseStorageRepo,
              ),
          ),
          BlocProvider<PostCubit>(
              create: (context) => PostCubit(
                postRepo: firebasePostRepo,
                storageRepo: firebaseStorageRepo,
              ),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightMode,
            home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, authState) {
                print(authState);
                if (authState is Unauthenticated) {
                  return const AuthPage();
                }
                if (authState is Authenticated) {
                  return HomeNavBar();
                } else {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                    ),
                  );
                }
              },
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      )
                  );
                }
              },
            )
        )
    );
  }
}