import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../../../model/shipper_model/order_model.dart';
import '../../../service/shipper_service/Order/Order_data.dart';

// class OrdersShipperPages extends StatelessWidget {
//   OrdersShipperPages({Key? key}) : super(key: key);
//
//   final List<String> tabs = [
//     'Đã nhận đơn',
//     'Đang vận chuyển',
//     'Đã giao',
//     'Giao thất bại',
//     'Đã huỷ',
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final formatter = NumberFormat('#,##0', 'vi_VN');
//
//     return DefaultTabController(
//       length: tabs.length,
//       child: Scaffold(
//         backgroundColor:Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 1,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: const Text(
//             'Đơn đã mua',
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//           ),
//           actions: [
//             IconButton(
//               icon: Stack(
//                 children: [
//                   const Icon(Icons.search, color: Colors.black),
//                   Positioned(
//                     right: 0,
//                     top: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: const BoxDecoration(
//                         color: Colors.red,
//                         shape: BoxShape.circle,
//                       ),
//                       constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
//                       child: const Text(
//                         '2',
//                         style: TextStyle(color: Colors.white, fontSize: 10),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               onPressed: () {},
//             ),
//           ],
//           bottom: TabBar(
//             isScrollable: true,
//             indicatorColor: const Color(0xFFEF2B39),
//             labelColor: const Color(0xFFEF2B39),
//             unselectedLabelColor: Colors.grey,
//             tabs: tabs.map((e) => Tab(text: e)).toList(),
//           ),
//         ),
//         body: TabBarView(
//           children: tabs.map((status) {
//             final filtered = orders.where((o) => o.statusText == status).toList();
//             if (filtered.isEmpty) {
//               return const Center(
//                 child: Text(
//                   'Không có đơn hàng',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               );
//             }
//             return ListView.builder(
//               itemCount: filtered.length,
//               itemBuilder: (context, index) {
//                 final order = filtered[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   color: Colors.white,
//                   child: Padding(
//                     padding: const EdgeInsets.all(12),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Header: tag + store + status
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFFEF2B39),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: const Text(
//                                     'Yêu thích',
//                                     style: TextStyle(color: Colors.white, fontSize: 10),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   order.storeName,
//                                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               'Hoàn thành',
//                               style: const TextStyle(color: Color(0xFFEF2B39), fontSize: 12),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//
//                         // Product row
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(6),
//                               child: Image.network(
//                                 order.imageUrl,
//                                 width: 60,
//                                 height: 60,
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     order.productName,
//                                     style: const TextStyle(fontSize: 14),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   const SizedBox(height: 4),
//
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           order.variant,
//                                           style: const TextStyle(color: Colors.grey, fontSize: 12),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       Text(
//                                         'x${order.quantity}',
//                                         style: const TextStyle(color: Colors.grey, fontSize: 12),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 30),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       Text(
//                                         '₫${formatter.format(order.originalPrice)}',
//                                         style: const TextStyle(
//                                           decoration: TextDecoration.lineThrough,
//                                           fontSize: 12,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(
//                                         '₫${formatter.format(order.price)}',
//                                         style: const TextStyle(
//                                           fontSize: 14,
//                                           color: Color(0xFFEF2B39),
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         // Total
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: Text.rich(
//                             TextSpan(
//                               style: const TextStyle(color: Colors.black, fontSize: 14),
//                               children: [
//                                 TextSpan(text: 'Tổng số tiền (${order.quantity} sản phẩm): '),
//                                 TextSpan(
//                                   text: '₫${formatter.format(order.total)}',
//                                   style: const TextStyle(
//                                     color: Color(0xFFEF2B39),
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
// }
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
  Map<String, List<Order>> _ordersByStatus = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final allOrders = await _orderService.getOrders();
    print('🔥 allOrders: $allOrders');

    if (allOrders.isEmpty) {
      print('No orders returned.');
    }

    // Phân loại đơn hàng theo trạng thái
    Map<String, List<Order>> result = {};
    for (var tab in tabs) {
      print('Processing tab: $tab');
      result[tab] = allOrders.where((order) => order.statusText == tab).toList();
    }

    setState(() {
      _ordersByStatus = result;
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0', 'vi_VN');

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Đơn đã mua',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.search, color: Colors.black),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: const Text(
                        '2',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: const Color(0xFFEF2B39),
            labelColor: const Color(0xFFEF2B39),
            unselectedLabelColor: Colors.grey,
            tabs: tabs.map((e) => Tab(text: e)).toList(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF2B39)))
            : TabBarView(
          children: tabs.map((status) {
            final filtered = _ordersByStatus[status] ?? [];
            if (filtered.isEmpty) {
              return const Center(
                child: Text(
                  'Không có đơn hàng',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _loadOrders,
              color: const Color(0xFFEF2B39),
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final order = filtered[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: tag + store + status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF2B39),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Yêu thích',
                                      style: TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    order.storeName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                              Text(
                                'Hoàn thành',
                                style: const TextStyle(color: Color(0xFFEF2B39), fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Customer name
                          Text(
                            'Khách hàng: ${order.customerName}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 12),

                          // Product row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  order.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.productName,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: order.description.isNotEmpty
                                              ? Text(
                                            order.description,
                                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                          )
                                              : const SizedBox(), // Widget rỗng nếu không có mô tả
                                        ),
                                        Text(
                                          'x${order.quantity}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₫${formatter.format(order.originalPrice)}',
                                          style: const TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '₫${formatter.format(order.discountedPrice)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFFEF2B39),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Total
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(color: Colors.black, fontSize: 14),
                                children: [
                                  TextSpan(text: 'Tổng số tiền (${order.quantity} sản phẩm): '),
                                  TextSpan(
                                    text: '₫${formatter.format(order.totalAmount)}',
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
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

