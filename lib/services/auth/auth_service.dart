import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  //the authService is dependant upon AuthProvider and using a const constructor initializer we are injecting a provider into it
  final AuthProvider provider;
  const AuthService(this.provider);

  //the purpose of this is to return an instance of AuthService that is already configured with FirebaseAuthProvider
  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) =>
      provider.createUser(
        email: email,
        password: password,
      );

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> logOut() => provider.logOut();

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) => provider.logIn(email: email, password: password);

  @override
  Future<void> sendEmailVerification() => provider.sendEmailVerification();
  
  //missing override is added when we initialize app function
  @override
  Future<void> initialize() => provider.initialize();
}
