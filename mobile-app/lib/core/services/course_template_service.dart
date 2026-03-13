import 'api_service.dart';

class CourseTemplateService {
  final ApiService _api = ApiService();

  Future<List<dynamic>> getMyTemplates() async {
    final response = await _api.get('/course-templates');
    final data = response.data;
    if (data is Map && data.containsKey('data')) return data['data'] as List<dynamic>? ?? [];
    return data is List ? data : [];
  }

  Future<Map<String, dynamic>> getTemplateById(int templateId) async {
    final response = await _api.get('/course-templates/$templateId');
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> createTemplate(Map<String, dynamic> payload) async {
    final response = await _api.post('/course-templates', data: payload);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> updateTemplate(int templateId, Map<String, dynamic> payload) async {
    final response = await _api.put('/course-templates/$templateId', data: payload);
    return response.data is Map<String, dynamic> ? response.data : {};
  }

  Future<Map<String, dynamic>> deleteTemplate(int templateId) async {
    final response = await _api.delete('/course-templates/$templateId');
    return response.data is Map<String, dynamic> ? response.data : {};
  }
}
