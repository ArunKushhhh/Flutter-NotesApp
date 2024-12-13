import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();

  AuthUser? get currentUser;

  //a login function for it to allow a user to login
  Future<AuthUser> logIn({
    required String email,
    required String password,
  });

  //we also need a function to create a new user
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  //to be able to logout as well
  Future<void> logOut();

  //for email verification
  Future<void> sendEmailVerification();
}
