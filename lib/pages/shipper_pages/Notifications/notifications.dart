import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

import '../../../model/shipper_model/Notification_model.dart';
import '../../authentication/authenticaion_state/authenticationCubit.dart'; // đường dẫn tới file provider của bạn

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _filters = ['today', 'yesterday', 'all'];

  @override
  void initState() {
    super.initState();
    // Lần đầu load “Hôm nay”
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<NotificationProvider>();
      prov.markReadByFilter('today')
          .then((_) => prov.fetchByFilter('today'))
          .then((_) => prov.fetchUnreadCount());
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _filters.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Thông báo',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFEF2B39),
            labelColor: const Color(0xFFEF2B39),
            unselectedLabelColor: Colors.black54,
            onTap: (index) {
              final f = _filters[index];
              final prov = context.read<NotificationProvider>();
              prov.markReadByFilter(f)
                  .then((_) => prov.fetchByFilter(f))
                  .then((_) => prov.fetchUnreadCount());
            },
            tabs: const [
              Tab(text: 'Hôm nay'),
              Tab(text: 'Hôm qua'),
              Tab(text: 'Tất cả'),
            ],
          ),
        ),
        body: Consumer<NotificationProvider>(
          builder: (context, prov, _) {
            final list = prov.notifications;
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
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final bool isLast;

  const _NotificationTile({
    Key? key,
    required this.item,
    this.isLast = false,
  }) : super(key: key);

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
      beforeLineStyle:
      LineStyle(color: Colors.grey.shade300, thickness: 1),
      indicatorStyle: IndicatorStyle(
        width: 24,
        height: 24,
        color: bg,
        iconStyle:
        IconStyle(iconData: icon, color: bg.darken()),
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
                style: const TextStyle(
                    fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd-MM-yyyy HH:mm')
                    .format(item.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
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
