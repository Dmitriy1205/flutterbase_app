import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/bloc/auth_state.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      emit(const AuthSignedIn());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        emit(const AuthError(message: 'No user found for that email.'));
      } else if (e.code == 'wrong-password') {
        emit(
            const AuthError(message: 'Wrong password provided for that user.'));
      }
    } catch (error) {
      emit(const AuthError(message: 'An error has occurred'));
    }
  }

  Future<void> signUp(
      {required String email,
      required String password,
      required String userName,
      required File image}) async {
    emit(const AuthLoading());
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'userID': userCredential.user!.uid,
        'userName': userName,
        'email': email,
      });
      late String imageUrl;
      firebase_storage.FirebaseStorage storage =
          firebase_storage.FirebaseStorage.instance;
      await storage
          .ref('files/${userCredential.user!.uid.toString()}.png')
          .putFile(image)
          .then(
            (value) async => imageUrl = await value.ref.getDownloadURL(),
          );
      FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .update({
        'imageUrl': imageUrl,
      });

      userCredential.user!.updateDisplayName(userName);
      emit(const AuthSignedUp());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(const AuthError(message: 'The password provided is too weak.'));
      } else if (e.code == 'email-already-in-use') {
        emit(const AuthError(
            message: 'The account already exists for that email.'));
      }
    } catch (error) {
      emit(const AuthError(message: 'other error'));
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
