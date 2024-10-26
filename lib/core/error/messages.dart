class ErrorMessages {
  static String get kServerFailureMessage => 'An error occured.';
  static String get kNetworkFailureMessage =>
      'Check your internet connection and try again.\nPull down to retry.';

  // ! AUTHENTICATION ERRORS
  static String get kAuthEmailError =>
      'An error occured! Email belongs to another user!';
  static String get kAuthWrongLoginCredentials =>
      'Unable to log in with provided credentials.';
  static String get kAuthNoUserExistsWithEmail =>
      'No user exits with this e-mail address';

// ! ACCOUNT ERRORS
  static String get kAccountWrongPasswordError => 'Incorrect Old Password.';
}
