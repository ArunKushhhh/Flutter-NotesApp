import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
//immutable means that this class and its children and their initails are never going to change upon initialisation
class AuthUser {
  final bool isEmailVerified;

  const AuthUser({required this.isEmailVerified});

  //factory initializer
  factory AuthUser.formFirebase(User user) => AuthUser(isEmailVerified:  user.emailVerified);

  // //chap: unit testing auth services
  // void testing() {
  //   AuthUser(isEmailVerified: true);
  // }
}
