import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:food_delivery/service/shipper_service/Order/Order_service.dart';
import 'package:food_delivery/model/shipper_model/order_model.dart';

class OrdersShipperPages extends StatelessWidget {
  const OrdersShipperPages({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderService _controller = Get.put(OrderService());
    final formatter = NumberFormat('#,###', 'vi_VN');

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn hàng'),
          bottom: TabBar(
            isScrollable: true,
            labelColor: const Color(0xFFEF2B39),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFFEF2B39),
            tabs: const [
              Tab(text: 'Đã nhận đơn'),
              Tab(text: 'Đang vận chuyển'),
              Tab(text: 'Đã giao'),
              Tab(text: 'Giao thất bại'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OrderListTab(
              status: 'Đã nhận đơn',
              formatter: formatter,
              onConfirm: _showConfirmDialog,
            ),
            _OrderListTab(
              status: 'Đang vận chuyển',
              formatter: formatter,
              onConfirm: _showConfirmDialog,
            ),
            _OrderListTab(
              status: 'Đã giao',
              formatter: formatter,
              onConfirm: _showConfirmDialog,
            ),
            _OrderListTab(
              status: 'Giao thất bại',
              formatter: formatter,
              onConfirm: _showConfirmDialog,
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );
  }
}

class _OrderListTab extends StatelessWidget {
  final String status;
  final NumberFormat formatter;
  final Function(BuildContext, String, VoidCallback) onConfirm;

  const _OrderListTab({
    required this.status,
    required this.formatter,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final OrderService _controller = Get.find<OrderService>();

    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFEF2B39)),
        );
      }

      final orders = _controller.getOrdersByStatus(status);

      if (orders.isEmpty) {
        return const Center(
          child: Text(
            'Không có đơn hàng',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.loadOrdersFor(status),
        color: const Color(0xFFEF2B39),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _OrderCard(
              order: order,
              formatter: formatter,
              onConfirm: onConfirm,
            );
          },
        ),
      );
    });
  }
}

class _OrderCard extends StatelessWidget {
  final OrderWithItems order;
  final NumberFormat formatter;
  final Function(BuildContext, String, VoidCallback) onConfirm;

  const _OrderCard({
    required this.order,
    required this.formatter,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final OrderService _controller = Get.find<OrderService>();

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF2B39),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.storeName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                if (order.status != 'delivered' &&
                    order.status != 'delivered_failed' &&
                    order.status != 'canceled')
                  TextButton(
                    onPressed:
                        () => onConfirm(
                          context,
                          'Bạn có muốn thay đổi trạng thái đơn hàng thành "Giao thất bại"?',
                          () => _controller.processDeliveredFailed(order),
                        ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    child: const Text(
                      'Giao thất bại',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                const SizedBox(width: 8),
                if (order.status != 'delivered' &&
                    order.status != 'delivered_failed' &&
                    order.status != 'canceled')
                  InkWell(
                    onTap:
                        () => onConfirm(
                          context,
                          'Bạn có muốn thay đổi trạng thái đơn hàng sang trạng thái tiếp theo?',
                          () => _controller.processNextStatus(order),
                        ),
                    child: Text(
                      order.statusText,
                      style: const TextStyle(color: Color(0xFFEF2B39)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Khách hàng: ${order.customerName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ...order.items.map(
              (item) => _OrderItem(item: item, formatter: formatter),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  children: [
                    const TextSpan(text: 'Phí giao hàng: '),
                    TextSpan(
                      text: '${formatter.format(order.shippingFee)}đ',
                      style: const TextStyle(
                        color: Color(0xFFEF2B39),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Tổng thanh toán(${order.totalProducts} món): ',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextSpan(
                      text: '${formatter.format(order.totalAmount)}đ',
                      style: const TextStyle(
                        color: Color(0xFFEF2B39),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final Order item;
  final NumberFormat formatter;

  const _OrderItem({required this.item, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Food image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Food details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: ${item.quantity}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Price
          Text(
            '${formatter.format(item.discountedPrice)}đ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEF2B39),
            ),
          ),
        ],
      ),
    );
  }
}
