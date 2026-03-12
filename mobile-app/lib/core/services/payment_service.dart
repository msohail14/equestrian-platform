import 'api_service.dart';

class PaymentService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String provider,
    required String paymentType,
    String currency = 'SAR',
    int? relatedId,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _api.post('/payments/initiate', data: {
      'amount': amount,
      'provider': provider,
      'payment_type': paymentType,
      'currency': currency,
      if (relatedId != null) 'related_id': relatedId,
      if (metadata != null) 'metadata': metadata,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getPaymentStatus(String transactionId) async {
    final response = await _api.get('/payments/status/$transactionId');
    return response.data;
  }

  Future<Map<String, dynamic>> getMyPayments({int page = 1}) async {
    final response = await _api.get('/payments/my-payments', queryParameters: {
      'page': page,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> getMySubscription() async {
    final response = await _api.get('/payments/my-subscription');
    return response.data;
  }

  Future<Map<String, dynamic>> cancelSubscription(int subscriptionId) async {
    final response = await _api.patch('/payments/subscriptions/$subscriptionId/cancel');
    return response.data;
  }
}
