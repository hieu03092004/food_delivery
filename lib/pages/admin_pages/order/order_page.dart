import 'package:flutter/material.dart';
import 'package:food_delivery/model/admin_model/orders_model.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  final int storeId;
  final String status;
  const OrdersPage({super.key, required this.storeId, required this.status});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Map<int, Order> _orderMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();

    // Lắng nghe thay đổi real-time
    OrderSnapshot.listenDataChange(
      _orderMap,
      updateUI: () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi rời widget
    OrderSnapshot.unsubscribeListenOrderChange();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    final map = await OrderSnapshot.getOrder();
    setState(() {
      _orderMap = map;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    final orders =
        _orderMap.values
            .where(
              (order) =>
                  order.status == widget.status &&
                  order.items.any(
                    (item) => item.product.storeId == widget.storeId,
                  ),
            )
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
                  builder:
                      (context) => OrderDetailPage(
                        order: order,
                        storeId: widget.storeId,
                      ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
