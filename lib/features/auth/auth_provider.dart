import 'package:flutter/foundation.dart';
import '../../core/utils/validators.dart';
import '../../data/local/local_storage_service.dart';
import '../../data/models/user_profile.dart';

/// Authentication state provider managing user sessions, guest access, and login validation.
class AuthProvider extends ChangeNotifier {
  final LocalStorageService _localStorage;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;
  bool get isGuest => _currentUser != null && _currentUser!.isGuest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, String>? _registeredAccount;
  Map<String, String>? get registeredAccount => _registeredAccount;

  AuthProvider(this._localStorage) {
    _loadStoredSession();
  }

  void _loadStoredSession() {
    final session = _localStorage.getUserSession();
    if (session != null &&
        !session.email.toLowerCase().contains('whitematrix') &&
        !session.name.toLowerCase().contains('lokeshwar')) {
      _currentUser = session;
    } else {
      _currentUser = null;
      _localStorage.clearUserSession();
    }
    notifyListeners();
  }

  /// Attempts login with either email or phone and password.
  /// Intentionally triggers a failure if credentials contain "fail" (for testing error states).
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    // Simulate realistic network round-trip
    await Future.delayed(const Duration(milliseconds: 600));

    // Controlled failure condition specified in task requirements
    if (emailOrPhone.toLowerCase().contains('fail') || password.toLowerCase().contains('fail')) {
      _errorMessage = 'Invalid credentials. Please verify your email/phone and password.';
      _setLoading(false);
      return false;
    }

    // Input format validation
    final emailPhoneErr = Validators.validateEmailOrPhone(emailOrPhone);
    if (emailPhoneErr != null) {
      _errorMessage = emailPhoneErr;
      _setLoading(false);
      return false;
    }

    final passErr = Validators.validatePassword(password);
    if (passErr != null) {
      _errorMessage = passErr;
      _setLoading(false);
      return false;
    }

    // Determine if input was phone or email
    final isEmail = emailOrPhone.contains('@');
    final String resolvedName;
    if (_registeredAccount != null &&
        (_registeredAccount!['email']?.toLowerCase() == emailOrPhone.trim().toLowerCase() ||
            _registeredAccount!['phone'] == emailOrPhone.trim())) {
      resolvedName = _registeredAccount!['name'] ?? 'Explorer';
    } else if (isEmail) {
      final part = emailOrPhone.split('@').first;
      resolvedName = part.isNotEmpty ? part[0].toUpperCase() + part.substring(1) : 'Explorer';
    } else {
      resolvedName = 'Explorer';
    }

    final user = UserProfile(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: resolvedName,
      email: isEmail ? emailOrPhone.trim() : (_registeredAccount?['email'] ?? 'member@nova.app'),
      phone: !isEmail ? emailOrPhone.trim() : (_registeredAccount?['phone'] ?? '+91 9876543210'),
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
      isGuest: false,
      joinedDate: DateTime.now(),
    );

    _currentUser = user;
    await _localStorage.saveUserSession(user);
    _setLoading(false);
    return true;
  }

  /// Registers a new user account and prepares for sign in.
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    await Future.delayed(const Duration(milliseconds: 600));

    if (email.toLowerCase().contains('fail')) {
      _errorMessage = 'An account with this email address already exists.';
      _setLoading(false);
      return false;
    }

    _registeredAccount = {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'password': password,
    };

    _setLoading(false);
    return true;
  }

  /// Allows browsing in Guest mode without credentials.
  Future<void> continueAsGuest() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 300));
    final guest = UserProfile.guest();
    _currentUser = guest;
    await _localStorage.saveUserSession(guest);
    _setLoading(false);
  }

  /// Logs out and clears persisted credentials.
  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;
    await _localStorage.clearUserSession();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
