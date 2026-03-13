import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final notifications = await NotificationService().getNotifications();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load notifications';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await NotificationService().markAllAsRead();
      if (mounted) {
        setState(() {
          for (var n in _notifications) {
            if (n is Map) n['is_read'] = true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _markAsRead(int index) async {
    final notification = _notifications[index];
    if (notification is! Map) return;
    if (notification['is_read'] == true) return;

    final id = notification['id'];
    if (id == null) return;

    try {
      await NotificationService().markAsRead(id);
      if (mounted) {
        setState(() => notification['is_read'] = true);
      }
    } catch (_) {}
  }

  bool get _hasUnread {
    return _notifications.any(
      (n) => n is Map && n['is_read'] != true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (!_isLoading && _hasUnread)
            TextButton(
              onPressed: _markAllRead,
              child: Text(
                'Mark All Read',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Loading notifications...');
    }
    if (_error != null) return ErrorState(message: _error!, onRetry: _loadData);
    if (_notifications.isEmpty) {
      return const EmptyState(
        message: 'No notifications yet',
        icon: Icons.notifications_none_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          if (notification is! Map) return const SizedBox.shrink();

          return _NotificationTile(
            notification: notification,
            onTap: () => _markAsRead(index),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Map notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = notification['title'] ?? '';
    final body = notification['body'] ?? notification['message'] ?? '';
    final isRead = notification['is_read'] == true;
    final createdAt = notification['created_at'] ?? '';

    String timeText = '';
    try {
      if (createdAt.isNotEmpty) {
        final dt = DateTime.parse(createdAt);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeText = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeText = '${diff.inHours}h ago';
        } else {
          timeText = DateFormat('MMM d').format(dt);
        }
      }
    } catch (_) {}

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isRead ? null : AppColors.primaryLight.withOpacity(0.05),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, right: 10),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                  if (timeText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeText,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
