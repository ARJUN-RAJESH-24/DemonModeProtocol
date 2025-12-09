class AuthService {
  static Future<bool> hasBiometrics() async {
    return false; // Feature disabled
  }

  static Future<bool> authenticate() async {
    return true; // Always allow
  }
}
