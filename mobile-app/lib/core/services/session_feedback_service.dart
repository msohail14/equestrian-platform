import 'api_service.dart';

class SessionFeedbackService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> createFeedback(Map<String, dynamic> payload) async {
    final response = await _api.post('/session-feedback', data: payload);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> getSessionFeedback(int sessionId) async {
    final response = await _api.get('/session-feedback/session/$sessionId');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> getRiderPerformance(int riderId) async {
    final response = await _api.get('/session-feedback/rider/$riderId/performance');
    return response.data is Map<String, dynamic> ? response.data : {};
  }
}
