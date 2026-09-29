class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'emailRequired';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return 'emailInvalid';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'passwordRequired';
    if (value.length < 6) return 'passwordMinLength';
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) return 'passwordRequired';
    if (value != password) return 'passwordMismatch';
    return null;
  }

  static String? validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) return 'error';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'error';
    return null;
  }
}
