import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_app/features/auth/domain/repos/auth-repo.dart';
import '../../profile/domain/entities/profile-user.dart';
import '../domain/entities/app-user.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Future<void> _initGoogleSignIn() async {
    if (!_googleInitialized) {
      await googleSignIn.initialize();
      _googleInitialized = true;
    }
  }

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // Проверяем верификацию почты
      if (!userCredential.user!.emailVerified) {
        await firebaseAuth.signOut();
        throw Exception("Please verify your email before logging in.");
      }

      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userDoc['name'],
      );
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Отправляем письмо для подтверждения
      await userCredential.user!.sendEmailVerification();

      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await firebaseFirestore.collection('users')
          .doc(user.uid)
          .set(user.toJson());

      return user;
    } catch (e) {
      throw Exception('Register failed: $e');
    }
  }

  @override
  Future<ProfileUser?> loginWithGoogle() async {
    try {
      await _initGoogleSignIn();

      final GoogleSignInAccount? googleUser =
      await googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await firebaseAuth.signInWithCredential(credential);

      final user = userCredential.user!;
      final userDocRef = firebaseFirestore.collection("users").doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        final newUser = ProfileUser(
          uid: user.uid,
          email: user.email ?? "",
          name: user.displayName ?? "No Name",
          bio: "",
          profileImageUrl: user.photoURL ?? "",
          followers: [],
          following: [],
        );

        await userDocRef.set(newUser.toJson());
        return newUser;
      } else {
        return ProfileUser.fromJson(userDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      throw Exception("Google login failed: $e");
    }
  }

  @override
  Future<bool> isNameTaken(String name) async {
    final query = await firebaseFirestore
        .collection('users')
        .where('name', isEqualTo: name)
        .get();

    return query.docs.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
    await googleSignIn.disconnect();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }

    DocumentSnapshot userDoc = await firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) {
      return null;
    }

      return AppUser(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          name: userDoc['name'],
      );
    }
  }