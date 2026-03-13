import 'api_service.dart';

class NotificationService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getNotifications({int page = 1, int limit = 10}) async {
    final response = await _api.get('/notifications', queryParameters: {'page': page, 'limit': limit});
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    final response = await _api.patch('/notifications/$notificationId/read');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final response = await _api.patch('/notifications/read-all');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<int> getUnreadCount() async {
    final response = await _api.get('/notifications/unread-count');
    final data = response.data;
    if (data is Map && data.containsKey('count')) return data['count'] as int? ?? 0;
    if (data is int) return data;
    return 0;
  }
}
