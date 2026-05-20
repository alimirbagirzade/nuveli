import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nuveli/core/network/api_exception.dart';
import 'package:nuveli/features/settings/services/account_delete_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockDio extends Mock implements Dio {}

class _MockSupabase extends Mock implements SupabaseClient {}

class _MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late _MockDio dio;
  late _MockSupabase supabase;
  late _MockGoTrueClient auth;

  setUpAll(() {
    registerFallbackValue(Options());
  });

  setUp(() {
    dio = _MockDio();
    supabase = _MockSupabase();
    auth = _MockGoTrueClient();
    when(() => supabase.auth).thenReturn(auth);
  });

  AccountDeleteService build() =>
      AccountDeleteService(dio: dio, supabase: supabase);

  test('calls DELETE /me then signs out locally', () async {
    when(() => dio.delete<dynamic>('/me')).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 200,
          data: {'status': 'deleted'},
        ));
    when(() => auth.signOut()).thenAnswer((_) async {});

    await build().deleteAccount();

    verify(() => dio.delete<dynamic>('/me')).called(1);
    verify(() => auth.signOut()).called(1);
  });

  test('rethrows ApiException from backend so UI can surface message', () async {
    final apiErr = ApiException(
      requestOptions: RequestOptions(path: '/me'),
      statusCode: 500,
      userMessage: 'Server unavailable',
    );
    when(() => dio.delete<dynamic>('/me')).thenThrow(apiErr);

    expect(build().deleteAccount(), throwsA(isA<ApiException>()));
    verifyNever(() => auth.signOut());
  });

  test('still completes if signOut throws — data is already gone', () async {
    when(() => dio.delete<dynamic>('/me')).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: '/me'),
          statusCode: 200,
        ));
    when(() => auth.signOut()).thenThrow(Exception('network'));

    // Should not throw — server-side deletion succeeded.
    await build().deleteAccount();

    verify(() => auth.signOut()).called(1);
  });
}
