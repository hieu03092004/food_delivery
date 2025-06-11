import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

import '../../../model/shipper_model/Notification_model.dart';
import '../../../service/shipper_service/Notifications/notification_service.dart';
import '../../../service/auth_servicae/AuthService.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({Key? key}) : super(key: key) {
    // Initialize notifications when the page is created
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Get.find<AuthService>();
      final userId = authService.accountId.value;

      // Chỉ khởi tạo khi đã đăng nhập
      if (userId != 0) {
        if (!Get.isRegistered<NotificationService>()) {
          debugPrint('Registering NotificationService with userId: $userId');
          Get.put(NotificationService(userId), permanent: true);
        } else {
          debugPrint('NotificationService already registered');
        }

        final service = Get.find<NotificationService>();
        await service.initializeTodayNotifications();
      } else {
        debugPrint('User not logged in, skipping notification initialization');
      }
    });
  }

  final _filters = ['today', 'yesterday', 'all'];

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final notificationService = Get.find<NotificationService>();

    // Nếu chưa đăng nhập, hiển thị thông báo
    if (!authService.isLoggedIn) {
      return const Scaffold(
        body: Center(child: Text('Vui lòng đăng nhập để xem thông báo')),
      );
    }

    return DefaultTabController(
      length: _filters.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thông báo',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFEF2B39),
            labelColor: const Color(0xFFEF2B39),
            unselectedLabelColor: Colors.black54,
            onTap: (index) {
              final f = _filters[index];
              notificationService
                  .markReadByFilter(f)
                  .then((_) => notificationService.fetchByFilter(f))
                  .then((_) => notificationService.fetchUnreadCount());
            },
            tabs: const [
              Tab(text: 'Hôm nay'),
              Tab(text: 'Hôm qua'),
              Tab(text: 'Tất cả'),
            ],
          ),
        ),
        body: Obx(() {
          if (notificationService.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEF2B39)),
            );
          }

          final list = notificationService.notifications;
          if (list.isEmpty) {
            return const Center(child: Text('Không có thông báo nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              return _NotificationTile(
                item: list[i],
                isLast: i == list.length - 1,
              );
            },
          );
        }),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final bool isLast;

  const _NotificationTile({Key? key, required this.item, this.isLast = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color bg;
    switch (item.title) {
      case 'Đang vận chuyển':
        icon = Icons.local_shipping_outlined;
        bg = Colors.yellow.shade50;
        break;
      case 'Giao kiện hàng thành công':
        icon = Icons.check_circle_outline;
        bg = Colors.green.shade50;
        break;
      case 'Hủy đơn hàng':
      case 'Giao thất bại':
        icon = Icons.cancel_outlined;
        bg = Colors.red.shade50;
        break;
      case 'Đơn hàng mới':
        icon = Icons.info_outline;
        bg = Colors.orange.shade50;
        break;
      default:
        icon = Icons.info_outline;
        bg = Colors.grey.shade200;
    }

    return TimelineTile(
      isFirst: false,
      isLast: isLast,
      beforeLineStyle: LineStyle(color: Colors.grey.shade300, thickness: 1),
      indicatorStyle: IndicatorStyle(
        width: 24,
        height: 24,
        color: bg,
        iconStyle: IconStyle(iconData: icon, color: bg.darken()),
      ),
      endChild: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                item.message,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd-MM-yyyy HH:mm').format(item.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
      alignment: TimelineAlign.manual,
      lineXY: 0.1,
    );
  }
}

extension on Color {
  Color darken([double amount = .1]) {
    final f = 1 - amount;
    return Color.fromARGB(
      alpha,
      (red * f).round(),
      (green * f).round(),
      (blue * f).round(),
    );
  }
}
