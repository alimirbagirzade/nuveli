import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/app_error.dart';

class CoachMessage {
  final String id;
  final String role; // user | coach
  final String content;
  final String? audioUrl;
  final bool isFallback;
  final DateTime createdAt;

  const CoachMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.isFallback,
    required this.createdAt,
    this.audioUrl,
  });

  bool get isUser => role == 'user';

  factory CoachMessage.fromJson(Map<String, dynamic> j) => CoachMessage(
        id: j['id'] as String,
        role: j['role'] as String,
        content: j['content'] as String,
        audioUrl: j['audio_url'] as String?,
        isFallback: j['is_fallback'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class CoachResponse {
  final String messageId;
  final String message;
  final bool isFallback;
  final String riskLevel;
  final String? audioUrl;

  const CoachResponse({
    required this.messageId,
    required this.message,
    required this.isFallback,
    required this.riskLevel,
    this.audioUrl,
  });

  factory CoachResponse.fromJson(Map<String, dynamic> j) => CoachResponse(
        messageId: j['message_id'] as String? ?? '',
        message: j['message'] as String,
        isFallback: j['is_fallback'] as bool? ?? false,
        riskLevel: j['risk_level'] as String? ?? 'normal',
        audioUrl: j['audio_url'] as String?,
      );

  bool get isCrisis => riskLevel == 'crisis';
}

// ─── Repository ─────────────────────────────

final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository(ref.watch(apiClientProvider));
});

class CoachRepository {
  CoachRepository(this._dio);
  final Dio _dio;

  /// Tek seferlik yanıt — thread'e yazmaz. Ses istemek için kullanılır.
  Future<CoachResponse> respond(String message, {bool wantAudio = false}) async {
    try {
      final resp = await _dio.post('/coach/respond', data: {
        'message': message,
        'want_audio': wantAudio,
      });
      return CoachResponse.fromJson(resp.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  /// Thread'de konuşma — user + coach mesajı kalıcı olarak kaydedilir.
  /// Thread'i döner (kullanıcı + koç mesajı eklenmiş halde).
  Future<({CoachMessage userMsg, CoachMessage coachMsg, String riskMode})>
      postThreadMessage(String message) async {
    try {
      final resp = await _dio.post('/coach/thread/message', data: {
        'message': message,
      });
      final data = resp.data['data'] as Map<String, dynamic>;
      return (
        userMsg: CoachMessage.fromJson(
            data['user_message'] as Map<String, dynamic>),
        coachMsg: CoachMessage.fromJson(
            data['coach_message'] as Map<String, dynamic>),
        riskMode: data['risk_mode'] as String? ?? 'normal',
      );
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }

  Future<List<CoachMessage>> getThread() async {
    try {
      final resp = await _dio.get('/coach/thread');
      final data = resp.data['data'] as Map<String, dynamic>;
      final list = data['messages'] as List;
      return list
          .map((e) => CoachMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppError.fromDio(e);
    }
  }
}

// ─── Providers ─────────────────────────────

final coachThreadProvider = FutureProvider<List<CoachMessage>>((ref) async {
  return ref.watch(coachRepositoryProvider).getThread();
});

/// Koç sohbet state notifier.
class CoachChatNotifier extends StateNotifier<AsyncValue<List<CoachMessage>>> {
  CoachChatNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }
  final CoachRepository _repo;

  /// Son risk modu (crisis/distress UI için).
  String _lastRiskMode = 'normal';
  String get lastRiskMode => _lastRiskMode;

  Future<void> _load() async {
    try {
      final messages = await _repo.getThread();
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Kullanıcı mesajı gönder, koç yanıtını bekle. Her iki mesaj da persist edilir.
  /// Optimistic UI: önce user mesajını göster, sonra gerçek verilerle replace et.
  Future<void> sendMessage(String text) async {
    final currentList = state.value ?? [];
    final optimisticUser = CoachMessage(
      id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: text,
      isFallback: false,
      createdAt: DateTime.now(),
    );
    state = AsyncValue.data([...currentList, optimisticUser]);

    try {
      final result = await _repo.postThreadMessage(text);
      _lastRiskMode = result.riskMode;

      // Optimistic'i at, gerçek ikisini ekle
      final withoutOptimistic = currentList;
      state = AsyncValue.data([
        ...withoutOptimistic,
        result.userMsg,
        result.coachMsg,
      ]);
    } catch (e) {
      // Rollback — optimistic'i kaldır
      state = AsyncValue.data(currentList);
      rethrow;
    }
  }

  Future<void> refresh() => _load();
}

final coachChatProvider =
    StateNotifierProvider<CoachChatNotifier, AsyncValue<List<CoachMessage>>>((ref) {
  return CoachChatNotifier(ref.watch(coachRepositoryProvider));
});
