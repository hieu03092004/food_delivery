import 'package:flutter/material.dart';
import 'package:food_delivery/async_widget.dart';
import '../../../model/admin_model/orders_model.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatelessWidget {
  OrdersPage({super.key, required this.storeId});
  final int storeId;

  final Map<String, String> orderStatuses = {
    'pending': 'Đang chờ',
    'order_received': 'Đã nhận đơn',
    'in_transit': 'Đang vận chuyển',
    'delivered': 'Đã giao',
    'delivered_failed': 'Giao thất bại',
    'canceled': 'Đã huỷ',
  };

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: orderStatuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Đơn hàng'),
          bottom: TabBar(
            isScrollable: true,
            tabs: orderStatuses.values.map((e) {
              return Tab(text: e);
            }).toList(),
          )
        ),
        body: TabBarView(
          children: orderStatuses.keys.map((statusKey) {
            return OrderListTab(
              status: statusKey,
              storeId: storeId,
            );
          }).toList(),
        ),

      ),
    );
  }
}

class OrderListTab extends StatelessWidget {
  final String status;
  final int storeId;

  const OrderListTab({
    Key? key,
    required this.status,
    required this.storeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Order>>(
      stream: OrderSnapshot.getOrderStream(),
      builder: (context, snapshot) {
        return AsyncWidget(
          snapshot: snapshot,
          builder: (context, snapshot) {
            final orders = snapshot.data!
                .where((order) =>
            order.status == status &&
                order.items.any(
                        (item) => item.product.storeId == storeId))
                .toList();

            if (orders.isEmpty) {
              return const Center(child: Text('Không có đơn hàng.'));
            }

            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Đơn #${order.orderId}'),
                    subtitle: Text(
                      'Ngày: ${order.orderDate.toLocal().toString().split(' ')[0]} - '
                          '${order.items.length} sản phẩm',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order, storeId: storeId,),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}




