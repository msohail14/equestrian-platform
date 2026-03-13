import 'api_service.dart';

class BookingService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getBookingStables() async {
    final response = await _api.get('/bookings/stables');
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<List<dynamic>> getStableCoaches(int stableId) async {
    final response = await _api.get('/bookings/stables/$stableId/coaches');
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<List<dynamic>> getCoachSlots(int coachId, String date) async {
    final response = await _api.get('/bookings/coaches/$coachId/slots', queryParameters: {'date': date});
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<List<dynamic>> getStableHorses(int stableId, {String? discipline, String? level}) async {
    final params = <String, dynamic>{};
    if (discipline != null) params['discipline'] = discipline;
    if (level != null) params['level'] = level;
    final response = await _api.get('/bookings/stables/$stableId/horses', queryParameters: params);
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> payload) async {
    final response = await _api.post('/bookings', data: payload);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> payForBooking(int bookingId, Map<String, dynamic> payload) async {
    final response = await _api.post('/bookings/$bookingId/pay', data: payload);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final response = await _api.patch('/bookings/$bookingId/cancel');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<List<dynamic>> getMyBookings({int page = 1, int limit = 10}) async {
    final response = await _api.get('/bookings/my', queryParameters: {'page': page, 'limit': limit});
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<List<dynamic>> getCoachBookings({int page = 1, int limit = 10}) async {
    final response = await _api.get('/bookings/coach/my', queryParameters: {'page': page, 'limit': limit});
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }
}
