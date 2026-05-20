// Unit tests for NuveliAuthException.fromSupabase — pure logic, no
// mocking needed. These map Supabase's English error strings to typed
// AuthErrorType values + user-facing messages. If the upstream
// Supabase wording shifts, these tests catch it.

import 'package:flutter_test/flutter_test.dart';
import 'package:nuveli/features/auth/models/auth_errors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('NuveliAuthException.fromSupabase — AuthException mapping', () {
    test('"Invalid login credentials" → invalidCredentials', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('Invalid login credentials'),
      );
      expect(out.type, AuthErrorType.invalidCredentials);
      expect(out.userMessage, 'Incorrect email or password.');
    });

    test('"Invalid email or password" alt phrasing also maps', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('Invalid email or password'),
      );
      expect(out.type, AuthErrorType.invalidCredentials);
    });

    test('"User already registered" → emailAlreadyRegistered', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('User already registered'),
      );
      expect(out.type, AuthErrorType.emailAlreadyRegistered);
      expect(
        out.userMessage,
        'This email is already registered. Try signing in.',
      );
    });

    test('"email_exists" code variant also maps', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('email_exists'),
      );
      expect(out.type, AuthErrorType.emailAlreadyRegistered);
    });

    test('"Password should be at least 6 characters" → weakPassword', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('Password should be at least 6 characters'),
      );
      expect(out.type, AuthErrorType.weakPassword);
    });

    test('"Email not confirmed" → emailNotConfirmed', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('Email not confirmed'),
      );
      expect(out.type, AuthErrorType.emailNotConfirmed);
      expect(
        out.userMessage,
        'Please verify your email before signing in.',
      );
    });

    test('"User not found" → userNotFound', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('User not found'),
      );
      expect(out.type, AuthErrorType.userNotFound);
    });

    test('statusCode 429 → rateLimited', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('Too many requests', statusCode: '429'),
      );
      expect(out.type, AuthErrorType.rateLimited);
    });

    test('unknown AuthException falls through to unknown type', () {
      final out = NuveliAuthException.fromSupabase(
        const AuthException('Some bizarre new error'),
      );
      expect(out.type, AuthErrorType.unknown);
      // userMessage should surface the original message in fallback case
      expect(out.userMessage, 'Some bizarre new error');
    });
  });

  group('NuveliAuthException.fromSupabase — non-AuthException errors', () {
    test('"SocketException" plain Exception → networkError', () {
      final out = NuveliAuthException.fromSupabase(
        Exception('SocketException: failed to connect'),
      );
      expect(out.type, AuthErrorType.networkError);
    });

    test('message containing "connection" → networkError', () {
      final out = NuveliAuthException.fromSupabase(
        Exception('Connection refused'),
      );
      expect(out.type, AuthErrorType.networkError);
    });

    test('generic Exception with no network hint → unknown', () {
      final out = NuveliAuthException.fromSupabase(
        Exception('something else went wrong'),
      );
      expect(out.type, AuthErrorType.unknown);
      expect(out.userMessage, 'Something went wrong. Please try again.');
      // originalMessage should be preserved for debugging
      expect(out.originalMessage, contains('something else'));
    });
  });

  group('NuveliAuthException.appleCanceled / appleFailed factories', () {
    test('appleCanceled → typed and user-facing message', () {
      final out = NuveliAuthException.appleCanceled();
      expect(out.type, AuthErrorType.appleSignInCanceled);
      expect(out.userMessage, 'Apple Sign-In was canceled.');
    });

    test('appleFailed → typed and surfaces optional original message', () {
      final out = NuveliAuthException.appleFailed('CredentialError code 1000');
      expect(out.type, AuthErrorType.appleSignInFailed);
      expect(out.userMessage, 'Apple Sign-In failed. Please try again.');
      expect(out.originalMessage, 'CredentialError code 1000');
    });
  });
}
