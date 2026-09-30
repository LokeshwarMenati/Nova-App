/// Input validation utilities for authentication forms.
abstract class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Indian 10-digit mobile number starting with 6, 7, 8, or 9
  static final RegExp _indianPhoneRegExp = RegExp(
    r'^[6-9]\d{9}$',
  );

  /// Validates that the input is either a valid email address OR a valid 10-digit Indian phone number.
  static String? validateEmailOrPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email or phone number';
    }
    final trimmed = value.trim();

    final isEmail = _emailRegExp.hasMatch(trimmed);
    final cleanPhone = trimmed.replaceAll(RegExp(r'[\s\-+()]'), '');
    // Support +91 prefix
    final phoneToCheck = cleanPhone.startsWith('91') && cleanPhone.length == 12
        ? cleanPhone.substring(2)
        : cleanPhone;
    final isPhone = _indianPhoneRegExp.hasMatch(phoneToCheck);

    if (!isEmail && !isPhone) {
      return 'Enter a valid email address or 10-digit mobile number';
    }
    return null;
  }

  /// Strict email validator.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Strict Indian 10-digit phone validator.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-+()]'), '');
    final phoneToCheck = cleanPhone.startsWith('91') && cleanPhone.length == 12
        ? cleanPhone.substring(2)
        : cleanPhone;

    if (!_indianPhoneRegExp.hasMatch(phoneToCheck)) {
      return 'Enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  /// Password must be >= 6 characters, with at least 1 letter and 1 number.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validates password confirmation match.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Calculates strength score between 0.0 and 1.0.
  static double calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 6) score += 0.25;
    if (password.length >= 10) score += 0.25;
    if (RegExp(r'[a-z]').hasMatch(password) && RegExp(r'[A-Z]').hasMatch(password)) score += 0.2;
    if (RegExp(r'\d').hasMatch(password)) score += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  /// Returns strength label for password strength bar.
  static String getPasswordStrengthLabel(double score) {
    if (score < 0.3) return 'Weak';
    if (score < 0.7) return 'Fair';
    if (score < 0.9) return 'Good';
    return 'Strong';
  }
}
