import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/authed_dio_provider.dart';

/// GDPR Article 20 — Right to Data Portability.
///
/// Pulls the user's full data dump from `GET /me/export`, writes it to a
/// timestamped JSON file in the platform's temp directory, then opens the
/// system share sheet so the user can save the file wherever they like
/// (Files app, email, AirDrop, etc.).
///
/// The temp directory is sandboxed per-app — files written there are
/// either picked up by the share sheet or cleaned by the OS, so there's
/// no lingering personal data on disk.
class DataExportService {
  final Dio _dio;

  DataExportService({required Dio dio}) : _dio = dio;

  /// Fetch the export, write it to a temp file, share. Returns the file
  /// path for callers that want to log it. Throws [ApiException] only
  /// on backend failure (rate limit, network, auth). Failures in the
  /// share-sheet step are swallowed — the export itself succeeded, the
  /// file is on disk, and the user dismissed / had no share target
  /// available (common on iOS Simulator). UI shouldn't surface that as
  /// "Could not export your data" because the data IS exported.
  Future<String> exportToFile() async {
    final response = await _fetchExport();
    final file = await _writeJsonFile(response);
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Nuveli data export',
        text:
            'Your Nuveli data export. Contains every meal, water log, weight '
            'entry, habit, and AI insight tied to your account.',
      );
    } catch (_) {
      // Simulator with no installed share targets throws PlatformException
      // here. Backend export succeeded, file is on disk — treat as success.
    }
    return file.path;
  }

  Future<Map<String, dynamic>> _fetchExport() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/me/export');
      final data = response.data;
      if (data == null) {
        throw ApiException(
          requestOptions: RequestOptions(path: '/me/export'),
          statusCode: 500,
          userMessage: 'Server returned an empty export.',
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<File> _writeJsonFile(Map<String, dynamic> snapshot) async {
    final dir = await getTemporaryDirectory();
    // Timestamped filename so re-exports don't overwrite each other in
    // the file picker preview, and so the user can tell exports apart.
    final stamp =
        DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/nuveli-export-$stamp.json');
    final pretty = const JsonEncoder.withIndent('  ').convert(snapshot);
    await file.writeAsString(pretty);
    return file;
  }
}

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  final dio = ref.watch(authedDioProvider);
  return DataExportService(dio: dio);
});
