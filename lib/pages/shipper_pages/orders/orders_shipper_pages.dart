import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../../model/shipper_model/order_model.dart';
import '../../../service/shipper_service/Order/Order_service.dart';
import '../../authentication/authenticaion_state/authenticationCubit.dart';


class OrdersShipperPages extends StatefulWidget {
  OrdersShipperPages({Key? key}) : super(key: key);

  @override
  _OrdersShipperPagesState createState() => _OrdersShipperPagesState();
}


class _OrdersShipperPagesState extends State<OrdersShipperPages> {
  final OrderService _orderService = OrderService();
  final List<String> tabs = [
    'Đã nhận đơn',
    'Đang vận chuyển',
    'Đã giao',
    'Giao thất bại',
    'Đã huỷ',
  ];

  bool _isLoading = false;
  // Chú ý: giờ đây là List<OrderWithItems>
  Map<String, List<OrderWithItems>> _ordersByStatus = {};

  late final int _userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationCubit>().state;
    final uid = authState.user?.uid;
    if (uid == null) throw Exception('User chưa login');
    _userId = uid;
    _loadOrdersFor(tabs[0]);
  }

  Future<void> _loadOrdersFor(String uiStatus) async {
    setState(() => _isLoading = true);
    try {
      final list = await _orderService.getOrdersByUiStatus(uiStatus, _userId);
      setState(() {
        _ordersByStatus[uiStatus] = list;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading $uiStatus: $e');
      setState(() => _isLoading = false);
    }
  }

  // Thay đổi signature để nhận OrderWithItems
  // Xử lý cập nhật trạng thái tiếp theo
  Future<void> _onStatusTap(OrderWithItems order) async {
    print('Order: $order');

    final result = await _orderService.processOrderStatusUpdate(order);

    if (result.success) {
      setState(() {
        order.status = result.newDbStatus!;
        order.statusText = result.newStatus!;
        _ordersByStatus[result.oldStatus!]?.remove(order);
        _ordersByStatus.putIfAbsent(result.newStatus!, () => []);
        _ordersByStatus[result.newStatus!]!.insert(0, order);
      });
    } else {
      // Hiển thị thông báo lỗi nếu cần
      print('❌ ${result.message}');
      // Có thể show SnackBar hoặc Dialog để thông báo lỗi cho user
    }
  }
  // Xử lý cập nhật trạng thái thành "Giao thất bại"
  Future<void> _onDeliveredFailedTap(OrderWithItems order) async {
    final result = await _orderService.processOrderDeliveredFailed(order);

    if (result.success) {
      setState(() {
        order.status = result.newDbStatus!;
        order.statusText = result.newStatus!;
        _ordersByStatus[result.oldStatus!]?.remove(order);
        _ordersByStatus.putIfAbsent(result.newStatus!, () => []);
        _ordersByStatus[result.newStatus!]!.insert(0, order);
      });
    } else {
      // Hiển thị thông báo lỗi nếu cần
      print('❌ ${result.message}');
      // Có thể show SnackBar hoặc Dialog để thông báo lỗi cho user
    }
  }


  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'vi_VN');

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Đơn hàng', style: TextStyle(color: Colors.black)),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFFEF2B39),
            labelColor: const Color(0xFFEF2B39),
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
            onTap: (i) => _loadOrdersFor(tabs[i]),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF2B39)))
            : TabBarView(
          children: tabs.map((status) {
            final groupedOrders = _ordersByStatus[status] ?? [];
            if (groupedOrders.isEmpty) {
              return const Center(
                child: Text('Không có đơn hàng', style: TextStyle(color: Colors.grey)),
              );
            }
            return RefreshIndicator(
              onRefresh: () => _loadOrdersFor(status),
              color: const Color(0xFFEF2B39),
              child: ListView.builder(
                itemCount: groupedOrders.length,
                itemBuilder: (context, index) {
                  final order = groupedOrders[index];
                  print('DiscountedPrice $index: ${order.items[0].discountedPrice}');
                  print('Quantity $index: ${order.items[0].quantity}');
                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
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
                                  Text(order.storeName,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Spacer(),
                              if(order.status!='delivered' && order.status!='delivered_failed' && order.status!='canceled')
                                TextButton(
                                  onPressed: () {
                                    _onDeliveredFailedTap(order);
                                  },

                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
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
                              InkWell(
                                onTap: () => _onStatusTap(order),
                                child: Text(order.statusText,
                                    style: const TextStyle(color: Color(0xFFEF2B39))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Khách hàng: ${order.customerName}',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),

                          // Danh sách sản phẩm
                          ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(item.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image_not_supported),
                                      )),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.productName,
                                          style: const TextStyle(fontSize: 14),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          if (item.description.isNotEmpty)
                                            Expanded(
                                              child: Text(item.description,
                                                  style: const TextStyle(
                                                      color: Colors.grey, fontSize: 12),
                                                  overflow: TextOverflow.ellipsis),
                                            ),
                                          Text('x${item.quantity}',
                                              style: const TextStyle(
                                                  color: Colors.grey, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (item.quantity != null && item.discountedPrice != null)
                                  Text(
                                    '${formatter.format(item.discountedPrice! * item.quantity!)}đ',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFFEF2B39),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  Text(
                                    'Chưa có giá hoặc số lượng',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          )),

                          const Divider(),
                          SizedBox(height: 8,),
                            // khoảng cách nhỏ
                          // Hiển thị phí giao hàng
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tổng tiền
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(fontSize: 14),
                                children: [
                                  TextSpan(text: 'Tổng thanh toán(${order.totalProducts} món): ',style: TextStyle(color: Colors.grey)),
                                  TextSpan(
                                    text:
                                    '${formatter.format(order.totalAmount)}đ',
                                    style: const TextStyle(
                                        color: Color(0xFFEF2B39),
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
