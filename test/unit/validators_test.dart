import 'package:flutter_test/flutter_test.dart';
import 'package:nova/core/utils/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('Email validation - valid emails', () {
      expect(Validators.validateEmail('user@whitematrix.co.in'), isNull);
      expect(Validators.validateEmail('test.developer@domain.com'), isNull);
      expect(Validators.validateEmail('name+tag@company.org'), isNull);
    });

    test('Email validation - invalid emails', () {
      expect(Validators.validateEmail(''), isNotNull);
      expect(Validators.validateEmail('invalid-email'), isNotNull);
      expect(Validators.validateEmail('user@domain'), isNotNull);
      expect(Validators.validateEmail('@domain.com'), isNotNull);
    });

    test('Phone validation - valid Indian 10-digit mobile numbers', () {
      expect(Validators.validatePhone('9876543210'), isNull);
      expect(Validators.validatePhone('8123456789'), isNull);
      expect(Validators.validatePhone('7001234567'), isNull);
      expect(Validators.validatePhone('6999888777'), isNull);
    });

    test('Phone validation - invalid numbers', () {
      expect(Validators.validatePhone(''), isNotNull);
      expect(Validators.validatePhone('1234567890'), isNotNull); // Doesn't start with 6-9
      expect(Validators.validatePhone('98765'), isNotNull); // Too short
      expect(Validators.validatePhone('98765432100'), isNotNull); // Too long
      expect(Validators.validatePhone('98765abcde'), isNotNull); // Non-digit
    });

    test('Email or Phone validation - hybrid identifier input', () {
      expect(Validators.validateEmailOrPhone('test@example.com'), isNull);
      expect(Validators.validateEmailOrPhone('9876543210'), isNull);
      expect(Validators.validateEmailOrPhone(''), isNotNull);
      expect(Validators.validateEmailOrPhone('12345'), isNotNull);
      expect(Validators.validateEmailOrPhone('not-valid-id'), isNotNull);
    });

    test('Password validation - minimum 6 characters with letter and digit', () {
      expect(Validators.validatePassword('secret1'), isNull);
      expect(Validators.validatePassword('WhiteMatrix2025'), isNull);
      expect(Validators.validatePassword('nova99'), isNull);

      expect(Validators.validatePassword(''), isNotNull);
      expect(Validators.validatePassword('abc'), isNotNull); // Too short
      expect(Validators.validatePassword('abcdef'), isNotNull); // Missing digit
      expect(Validators.validatePassword('123456'), isNotNull); // Missing letter
    });

    test('Confirm password match validation', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), isNull);
      expect(Validators.validateConfirmPassword('pass123', 'mismatch456'), isNotNull);
      expect(Validators.validateConfirmPassword('', 'pass123'), isNotNull);
    });
  });
}
