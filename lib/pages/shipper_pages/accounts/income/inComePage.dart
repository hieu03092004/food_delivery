import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../model/shipper_model/IncomeEntry.dart';
import '../../../../service/shipper_service/Profile/revenue_service.dart';
import '../../../authentication/authenticaion_state/authenticationCubit.dart';
import 'package:timeline_tile/timeline_tile.dart';
class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  DateTime _selectedDate = DateTime.now();
  Future<List<OrderShipping>>? _futureOrders;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authState = context.read<AuthenticationCubit>().state;
    final shipperId = authState.user?.uid;
    if (shipperId == null) return;

    setState(() {
      _futureOrders = OrderRepository()
          .getOrdersByDate(shipperId: shipperId, date: _selectedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDay = DateFormat('dd/MM/yyyy').format(_selectedDate);

    // màu hồng nhạt phía sau timeline
    final lineColor = Color(0xFFFEE0E5);
    // màu hồng cho dot
    final dotColor = Color(0x20BE54);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu nhập'),
      ),
      body: Column(
        children: [
          // Date picker giữ nguyên
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text('Ngày $formattedDay'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate:
                      DateTime.now().subtract(const Duration(days: 365)),
                      lastDate:
                      DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _loadOrders();
                    }
                  },
                ),
              ],
            ),
          ),

          // List notification-style
          Expanded(
            child: FutureBuilder<List<OrderShipping>>(
              future: _futureOrders,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Lỗi: ${snap.error}'));
                }
                final orders = snap.data!;
                if (orders.isEmpty) {
                  return const Center(child: Text('Không có đơn trong ngày'));
                }

                return Container(
                  color: Color(0xFEF6FE),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (ctx, i) {
                      final o = orders[i];
                      // Giờ và ngày hiển thị
                      final time = DateFormat('HH:mm').format(DateTime.now());
                      final date =
                      DateFormat('dd-MM-yyyy').format(_selectedDate);

                      return TimelineTile(
                        isFirst: i == 0,
                        isLast: i == orders.length - 1,
                        lineXY: 0.05,
                        beforeLineStyle: LineStyle(color: lineColor, thickness: 4),
                        afterLineStyle: LineStyle(color: lineColor, thickness: 4),
                        indicatorStyle: IndicatorStyle(
                          width: 32,            // đường kính vòng tròn
                          height: 32,
                          color: Colors.white,  // nền vòng
                          padding: const EdgeInsets.all(4),
                          iconStyle: IconStyle(
                            iconData: Icons.check_circle_outline,
                            color: Colors.green,// icon thành công// màu icon (ví dụ xanh)
                            fontSize: 24,                   // kích thước icon
                          ),
                        ),
                        endChild: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title cố định
                                const Text(
                                  'Thu nhập',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Nội dung
                                Text(
                                  'Đơn hàng ${o.orderId} đã được giao thành công với phí ship là ${o.shippingFee.toStringAsFixed(0)}VND',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                // Timestamp
                                Text(
                                  '$time – $date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
