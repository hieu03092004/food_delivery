import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../../../../service/shipper_service/Profile/revenue_service.dart';
import '../../../../service/auth_servicae/AuthService.dart';

class IncomePage extends StatelessWidget {
  IncomePage({super.key}) {
    Get.put(RevenueController());
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RevenueController>();
    final authService = Get.find<AuthService>();
    final lineColor = Color(0xFFFEE0E5);
    final dotColor = Color(0x20BE54);

    return Scaffold(
      appBar: AppBar(title: const Text('Thu nhập')),
      body: Column(
        children: [
          // Date picker
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Obx(
                    () => Text(
                      'Ngày ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)}',
                    ),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: controller.selectedDate.value,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      controller.updateDate(picked);
                      controller.loadOrders(authService.accountId.value);
                    }
                  },
                ),
              ],
            ),
          ),

          // List notification-style
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.orders.isEmpty) {
                return const Center(child: Text('Không có đơn trong ngày'));
              }

              return Container(
                color: Color(0xFEF6FE),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (ctx, i) {
                    final o = controller.orders[i];
                    final time = DateFormat('HH:mm').format(DateTime.now());
                    final date = DateFormat(
                      'dd-MM-yyyy',
                    ).format(controller.selectedDate.value);

                    return TimelineTile(
                      isFirst: i == 0,
                      isLast: i == controller.orders.length - 1,
                      lineXY: 0.05,
                      beforeLineStyle: LineStyle(
                        color: lineColor,
                        thickness: 4,
                      ),
                      afterLineStyle: LineStyle(color: lineColor, thickness: 4),
                      indicatorStyle: IndicatorStyle(
                        width: 32,
                        height: 32,
                        color: Colors.white,
                        padding: const EdgeInsets.all(4),
                        iconStyle: IconStyle(
                          iconData: Icons.check_circle_outline,
                          color: Colors.green,
                          fontSize: 24,
                        ),
                      ),
                      endChild: Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                        ),
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
                              const Text(
                                'Thu nhập',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Đơn hàng ${o.orderId} đã được giao thành công với phí ship là ${o.shippingFee.toStringAsFixed(0)}VND',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
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
            }),
          ),
        ],
      ),
    );
  }
}
