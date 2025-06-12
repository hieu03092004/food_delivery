import 'package:flutter/material.dart';
import 'package:food_delivery/pages/customer_pages/orderDetail_page.dart';
import 'package:food_delivery/service/customer_service/controller_order.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:food_delivery/model/customer_model/order_model.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ControllerOrder()); // ControllerCart chứa orders
    final dateFmt = DateFormat('dd/MM/yyyy – HH:mm');
    final moneyFmt = NumberFormat.simpleCurrency(
      locale: 'vi_VN', decimalDigits: 0, name: 'đ',
    );

    return Scaffold(
      appBar: CommonAppBar(title:'Đơn hàng của bạn'),
      body: Obx(() {
        if (ctrl.isLoadingOrders.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Order> orders = ctrl.orders;
        if (orders.isEmpty) {
          return const Center(child: Text('Bạn chưa có đơn hàng nào'));
        }

        return RefreshIndicator(
          onRefresh: ctrl.loadOrders,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = orders[i];
              final productTotal = o.items.fold<double>(
                  0, (sum, it) => sum + it.quantity * it.product.discountedPrice);
              final total = productTotal + o.shippingFee;

              final statusColor = o.status == 'pending'
                  ? Colors.orange
                  : o.status == 'delivered'
                  ? Colors.green
                  : Colors.grey;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text('Đơn #${o.orderId}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(dateFmt.format(o.orderDate)),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(moneyFmt.format(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      o.status?.toUpperCase() ?? '',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                onTap: () => Get.to(() => OrderDetailPage(order: o)),
              );
            },
          ),
        );
      }),
    );
  }
}
