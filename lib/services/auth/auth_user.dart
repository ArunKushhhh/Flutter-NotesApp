import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

@immutable
//immutable means that this class and its children and their initails are never going to change upon initialisation
class AuthUser {
  final bool isEmailVerified;

  const AuthUser(this.isEmailVerified);

  //factory initializer
  factory AuthUser.formFirebase(User user) => AuthUser(user.emailVerified);
}
