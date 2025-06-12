import 'package:flutter/material.dart';
import 'package:food_delivery/model/admin_model/orders_model.dart';
import 'order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  final int storeId;
  const OrdersPage({super.key, required this.storeId});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  Map<int, Order> _orderMap = {};
  bool _isLoading = true;

  // Trạng thái đơn hàng với nhãn tiếng Việt
  final Map<String, String> _orderStatusLabels = {
    'pending': 'Đang chờ',
    'order_received': 'Đã nhận đơn',
    'in_transit': 'Đang vận chuyển',
    'delivered': 'Đã giao',
    'delivered_failed': 'Giao thất bại',
    'canceled': 'Đã huỷ',
  };

  @override
  void initState() {
    print('widget.storeId = ${widget.storeId}');
    super.initState();
    _loadOrders();

    OrderSnapshot.listenDataChange(
      _orderMap,
      updateUI: () {
        setState(() {});
      },
    );
  }

  @override
  void dispose() {
    OrderSnapshot.unsubscribeListenOrderChange();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'order_received':
        return Colors.blue;
      case 'in_transit':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      case 'delivered_failed':
        return Colors.redAccent;
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.black45;
    }
  }

  Future<void> _loadOrders() async {
    final map = await OrderSnapshot.getOrder();
    print("Fetched orders: ${map.length}");
    for (var order in map.values) {
      print('Order ID: ${order.orderId}');
      print('  Status: ${order.status}');
      if (order.items.isEmpty) {
        print('  -> Không có sản phẩm nào trong đơn hàng này');
      } else {
        for (var item in order.items) {
          final storeId = item.product?.storeId;
          print('    -> Product: ${item.product?.name}, Store ID: $storeId');
        }
      }
    }
    setState(() {
      _orderMap = map;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _orderStatusLabels.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Quản lý đơn hàng'),
          bottom: TabBar(
            isScrollable: true,
            tabs:
                _orderStatusLabels.values
                    .map((label) => Tab(text: label))
                    .toList(),
          ),
        ),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                  children:
                      _orderStatusLabels.keys.map((statusKey) {
                        final orders =
                            _orderMap.values
                                .where(
                                  (order) =>
                                      order.status == statusKey &&
                                      order.items.any(
                                        (item) =>
                                            item.product.storeId ==
                                            widget.storeId,
                                      ),
                                )
                                .toList();

                        if (orders.isEmpty) {
                          return Center(child: Text('Không có đơn hàng.'));
                        }

                        return ListView.builder(
                          itemCount: orders.length,
                          itemBuilder: (context, index) {
                            final order = orders[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => OrderDetailPage(
                                            order: order,
                                            storeId: widget.storeId,
                                          ),
                                    ),
                                  );

                                  if (result == true) {
                                    _loadOrders(); // reload dữ liệu nếu có thay đổi
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.receipt_long,
                                            color: Colors.deepPurple,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Đơn hàng #${order.orderId}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                          Chip(
                                            label: Text(
                                              _orderStatusLabels[order
                                                      .status] ??
                                                  'Không rõ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                            backgroundColor: _getStatusColor(
                                              order.status,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Ngày đặt: ${_formatDate(order.orderDate)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${order.items.length} sản phẩm • Phí giao hàng: ${order.shippingFee} VND  ',
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                ),
      ),
    );
  }
}
