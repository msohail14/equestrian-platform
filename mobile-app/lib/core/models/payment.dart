class Payment {
  final int id;
  final int? userId;
  final double amount;
  final String currency;
  final String status;
  final String? provider;
  final String? transactionId;
  final DateTime? createdAt;

  Payment({
    required this.id,
    this.userId,
    required this.amount,
    this.currency = 'USD',
    this.status = 'pending',
    this.provider,
    this.transactionId,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as int,
        userId: json['user_id'] as int?,
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        currency: json['currency'] as String? ?? 'USD',
        status: json['status'] as String? ?? 'pending',
        provider: json['provider'] as String?,
        transactionId: json['transaction_id'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'currency': currency,
        'status': status,
        'provider': provider,
        'transaction_id': transactionId,
        'created_at': createdAt?.toIso8601String(),
      };
}
