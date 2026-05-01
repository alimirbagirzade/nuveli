import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';
import 'meal_models.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository(ref.watch(apiClientProvider));
});

class MealRepository {
  MealRepository(this._dio);
  final Dio _dio;

  /// POST /meals/analyze
  Future<MealAnalysisResult> analyze({String? imageB64, String? description}) async {
    try {
      final resp = await _dio.post('/meals/analyze', data: {
        if (imageB64 != null) 'image_b64': imageB64,
        if (description != null) 'description': description,
      });
      return MealAnalysisResult.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// POST /meals/{id}/confirm
  Future<MealLog> confirm(String analysisId, String localDay, String mealType) async {
    try {
      final resp = await _dio.post('/meals/$analysisId/confirm', data: {
        'local_day': localDay,
        'meal_type': mealType,
      });
      return MealLog.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// POST /meals/{id}/edit
  Future<MealLog> editAndSave(String analysisId, Map<String, dynamic> edits) async {
    try {
      final resp = await _dio.post('/meals/$analysisId/edit', data: edits);
      return MealLog.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// POST /meals/manual
  Future<MealLog> manualEntry(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post('/meals/manual', data: data);
      return MealLog.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// GET /meals?local_day=...
  Future<List<MealLog>> listMeals(String localDay) async {
    try {
      final resp = await _dio.get('/meals', queryParameters: {'local_day': localDay});
      final list = resp.data['data'] as List;
      return list.map((e) => MealLog.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// DELETE /meals/{id}
  Future<void> deleteMeal(String mealId) async {
    try {
      await _dio.delete('/meals/$mealId');
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}
