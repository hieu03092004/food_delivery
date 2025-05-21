import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../../../model/shipper_model/order_model.dart';
import '../../../service/shipper_service/Order/Order_data.dart';
import '../../authentication/authenticaion_state/authenticationCubit.dart';


class OrdersShipperPages extends StatefulWidget {
  OrdersShipperPages({Key? key}) : super(key: key);

  @override
  _OrdersShipperPagesState createState() => _OrdersShipperPagesState();
}


class _OrdersShipperPagesState extends State<OrdersShipperPages> {
  final OrderService _orderService = OrderService();
  final Map<String, String> _nextStatusMap = {
    'order_received': 'in_transit',
    'in_transit': 'delivered',
  };
  final Map<String, String> _dbToUiStatusMap = {
    'order_received': 'Đã nhận đơn',
    'in_transit': 'Đang vận chuyển',
    'delivered': 'Đã giao',
    'delivered_failed': 'Giao thất bại',
    'canceled': 'Đã huỷ',
  };
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
  Future<void> _onStatusTap(OrderWithItems order) async {
    print('Order:$order');
    final currentDb = order.status;
    final nextDb = _nextStatusMap[currentDb];
    if (nextDb == null) return;

    final oldUi = _dbToUiStatusMap[currentDb]!;
    final newUi = _dbToUiStatusMap[nextDb]!;

    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': nextDb})
          .eq('order_id', order.id);
      // ... (notification, FCM như cũ) ...
      String content = '';
      String titleNotifications='';
      print(newUi);
      if(newUi=='Đã giao'){
        content='Đơn hàng ${order.id} của bạn đã được giao thành công';
        titleNotifications='Giao kiện hàng thành công';
      }
      else{
        content='Đơn hàng ${order.id} của bạn đang trong quá trình vận chuyển';
        titleNotifications='Đang vận chuyển';
      }
      final tokenRes = await Supabase.instance.client
          .from('account')
          .select('tokendevice')
          .eq('account_id', order.customerId)
          .single();
      final String? deviceToken = tokenRes['tokendevice'] as String?;
      if (deviceToken == null) {
        print('⚠️ User ${order.customerId} chưa có deviceToken');
      } else {
        print('👉 Device token: $deviceToken');
      }

      await Supabase.instance.client
          .from('notification')
          .insert({
        'recipient_id': order.customerId,
        'order_id'    : order.id,
        'message'     : content,
        'title'       : titleNotifications
      });
      try {
        print(content);
        final response = await http.post(
          Uri.parse('https://flutter-notifications.vercel.app/send'),  // Thêm cổng 3000
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'deviceToken':deviceToken ,
            'title': 'Cập nhật đơn hàng',
            'body': content,
          }),
        );
        print(response);
        // Kiểm tra trạng thái HTTP response
        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Thành công - mã trạng thái 2xx
          print('📦 Gửi FCM thành công: ${response.body}');

          // Nếu cần phân tích thêm nội dung phản hồi JSON
          try {
            final responseData = jsonDecode(response.body);
            // Xử lý dữ liệu phản hồi nếu cần
            print('📦 Chi tiết phản hồi: $responseData');
          } catch (jsonError) {
            print('⚠️ Lỗi phân tích JSON phản hồi: $jsonError');
          }
        } else {
          // Thất bại - mã trạng thái không phải 2xx
          print('⚠️ Gửi FCM thất bại: ${response.statusCode} - ${response.body}');
        }
      } catch (httpError) {
        // Bắt lỗi khi gửi request HTTP (lỗi kết nối, timeout, v.v.)
        print('❌ Lỗi kết nối khi gửi FCM: $httpError');
      }
      setState(() {
        order.status = nextDb;
        order.statusText = newUi;
        _ordersByStatus[oldUi]?.remove(order);
        _ordersByStatus.putIfAbsent(newUi, () => []);
        _ordersByStatus[newUi]!.insert(0, order);
      });
    } catch (e) {
      print('❌ Lỗi khi đổi trạng thái: $e');
    }
  }
  Future<void> _onDeliveredFailedTap(OrderWithItems order) async {
    // Cố định hai giá trị
    const String nextDb = 'delivered_failed';
    const String newUi = 'Giao thất bại';

    final String oldDb = order.status;
    final String oldUi = _dbToUiStatusMap[oldDb]!;

    try {
      // 1. Cập nhật trên Supabase
      await Supabase.instance.client
          .from('orders')
          .update({'status': nextDb})
          .eq('order_id', order.id);

      // 2. Tạo nội dung thông báo
      final String content = 'Đơn hàng ${order.id} của bạn đã giao thất bại';
      final String notificationTitle='Giao thất bại';

      // 3. Lấy deviceToken của khách
      final tokenRes = await Supabase.instance.client
          .from('account')
          .select('tokendevice')
          .eq('account_id', order.customerId)
          .single();
      final String? deviceToken = tokenRes['tokendevice'] as String?;
      if (deviceToken == null) {
        print('⚠️ User ${order.customerId} chưa có deviceToken');
      } else {
        print('👉 Device token: $deviceToken');
      }

      // 4. Ghi log notification vào Supabase
      await Supabase.instance.client.from('notification').insert({
        'recipient_id': order.customerId,
        'order_id': order.id,
        'message': content,
        'title':notificationTitle
      });

      // 5. Gửi FCM qua HTTP
      try {
        final response = await http.post(
          Uri.parse('https://flutter-notifications.vercel.app/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'deviceToken': deviceToken,
            'title': 'Cập nhật đơn hàng',
            'body': content,
          }),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('📦 Gửi FCM thành công: ${response.body}');
          try {
            final responseData = jsonDecode(response.body);
            print('📦 Chi tiết phản hồi: $responseData');
          } catch (jsonError) {
            print('⚠️ Lỗi phân tích JSON: $jsonError');
          }
        } else {
          print('⚠️ Gửi FCM thất bại: ${response.statusCode} - ${response.body}');
        }
      } catch (httpError) {
        print('❌ Lỗi khi gửi FCM: $httpError');
      }

      // 6. Cập nhật UI local và danh sách _ordersByStatus
      setState(() {
        order.status = nextDb;
        order.statusText = newUi;

        // Bỏ khỏi danh sách cũ
        _ordersByStatus[oldUi]?.remove(order);

        // Thêm vào danh sách mới
        _ordersByStatus.putIfAbsent(newUi, () => []);
        _ordersByStatus[newUi]!.insert(0, order);
      });
    } catch (e) {
      print('❌ Lỗi khi đổi trạng thái sang Giao thất bại: $e');
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
