import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/shipper_model/Notification_model.dart';
import '../../../service/shipper_service/Notifications/Notifications_data.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd-MM-yyyy HH:mm');
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // Phân nhóm
    final todayList = notifications.where((item) {
      final dt = item.dateTime;
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).toList();

    final yesterdayList = notifications.where((item) {
      final dt = item.dateTime;
      return dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day;
    }).toList();

    Widget buildList(List<NotificationItem> items) {
      if (items.isEmpty) {
        return const Center(
          child: Text('Không có thông báo nào'),
        );
      }
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: item.iconUrl != null
                ? ClipOval(
              child: Image.network(
                item.iconUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            )
                : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping,
                color: Colors.grey,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black),
                      children: [
                        if (item.orderCode != null) ...[
                          const TextSpan(text: 'Đơn hàng '),
                          TextSpan(
                            text: item.orderCode!,
                            style: const TextStyle(color: Colors.blue),
                          ),
                          const TextSpan(text: ' '),
                        ],
                        TextSpan(text: item.message),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    dateFormatter.format(item.dateTime),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            onTap: () {
              // TODO: xử lý khi nhấn vào thông báo
            },
          );
        },
      );
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Thông báo',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Hôm nay'),
              Tab(text: 'Hôm qua'),
              Tab(text: 'Tất cả'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildList(todayList),
            buildList(yesterdayList),
            buildList(notifications),
          ],
        ),
      ),
    );
  }
}