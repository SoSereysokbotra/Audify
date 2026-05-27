import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(AudifyNotificationCategory category) {
    switch (category) {
      case AudifyNotificationCategory.music:
        return Icons.album_outlined;
      case AudifyNotificationCategory.playlist:
        return Icons.playlist_add_check;
      case AudifyNotificationCategory.favorite:
        return Icons.favorite_border;
      case AudifyNotificationCategory.playback:
        return Icons.error_outline;
      case AudifyNotificationCategory.account:
        return Icons.verified_user_outlined;
      case AudifyNotificationCategory.profile:
        return Icons.person_outline;
      case AudifyNotificationCategory.whatsNew:
        return Icons.bolt_outlined;
    }
  }

  Color _colorFor(AudifyNotificationCategory category) {
    switch (category) {
      case AudifyNotificationCategory.playback:
        return AppColors.error;
      case AudifyNotificationCategory.favorite:
        return Colors.pinkAccent;
      case AudifyNotificationCategory.account:
        return AppColors.warning;
      case AudifyNotificationCategory.profile:
        return Colors.lightBlueAccent;
      case AudifyNotificationCategory.music:
      case AudifyNotificationCategory.playlist:
      case AudifyNotificationCategory.whatsNew:
        return AppColors.accent;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final store = AudifyStore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Notifications', style: AppTextStyles.h2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              if (store.notifications.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: AppColors.surface,
                onSelected: (value) {
                  if (value == 'read') {
                    store.markAllNotificationsRead();
                  } else if (value == 'clear') {
                    store.clearNotifications();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'read', child: Text('Mark all as read')),
                  PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear notifications'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final notifications = store.notifications;
          if (notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: AppColors.secondaryText,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No notifications yet',
                      style: AppTextStyles.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Playlist activity, favorites, account updates, playback alerts, and new music will appear here.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final color = _colorFor(notification.category);

              return InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => store.markNotificationRead(notification.id),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? AppColors.surface.withValues(alpha: 0.65)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: notification.isRead
                          ? Colors.white.withValues(alpha: 0.04)
                          : color.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _iconFor(notification.category),
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: Colors.white,
                                      fontWeight: notification.isRead
                                          ? FontWeight.w500
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (!notification.isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 6),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.message,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _timeAgo(notification.createdAt),
                              style: AppTextStyles.helper.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
