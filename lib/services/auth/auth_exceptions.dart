//from loginView

class UserNotFoundAuthException implements Exception {}

class InvalidCredentialAuthException implements Exception {}

//from registerView

class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

//Generic exceptions

//a generic auth exception to handle other firebase auth exception as well as exceptions other than firebase auth exceptions
class GenericAuthException implements Exception {}

//this excpetion is thrown if the user == null 

class UserNotLoggedInException implements Exception {}
