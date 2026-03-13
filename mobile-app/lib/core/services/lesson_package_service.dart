import 'api_service.dart';

class LessonPackageService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getCoachPackages(int coachId) async {
    final response = await _api.get('/packages/coach/$coachId');
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> getPackageById(int packageId) async {
    final response = await _api.get('/packages/$packageId');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> purchasePackage(int packageId) async {
    final response = await _api.post('/packages/$packageId/purchase');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<List<dynamic>> getMyPackages() async {
    final response = await _api.get('/packages/my');
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }
}
