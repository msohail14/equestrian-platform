class NotificationModel {
  final int id;
  final int? userId;
  final int? adminId;
  final String? type;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    this.userId,
    this.adminId,
    this.type,
    this.title,
    this.body,
    this.data,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        id: json['id'] as int,
        userId: json['user_id'] as int?,
        adminId: json['admin_id'] as int?,
        type: json['type'] as String?,
        title: json['title'] as String?,
        body: json['body'] as String?,
        data: json['data'] is Map<String, dynamic>
            ? json['data'] as Map<String, dynamic>
            : null,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'admin_id': adminId,
        'type': type,
        'title': title,
        'body': body,
        'data': data,
        'is_read': isRead,
        'created_at': createdAt?.toIso8601String(),
      };
}
