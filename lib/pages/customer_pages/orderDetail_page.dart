// lib/customer_pages/home/order_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:food_delivery/model/customer_model/order_model.dart';

class OrderDetailPage extends StatelessWidget {
  final Order order;
  const OrderDetailPage({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy – HH:mm');
    final moneyFmt = NumberFormat.simpleCurrency(
      locale: 'vi_VN', decimalDigits: 0, name: 'đ',
    );
    final productTotal = order.items.fold<double>(
        0, (sum, it) => sum + it.quantity * it.product.discountedPrice);
    final grandTotal = productTotal + order.shippingFee;
    final status = order.status?.toUpperCase() ?? '';
    final statusColor = order.status == 'pending'
        ? Colors.orange
        : order.status == 'delivered'
        ? Colors.green
        : Colors.grey;

    return Scaffold(
      appBar: AppBar(title: Text('Đơn #${order.orderId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ngày đặt: ${dateFmt.format(order.orderDate)}'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Trạng thái: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(status, style: TextStyle(color: statusColor)),
              ],
            ),
            const Divider(height: 32),

            const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, idx) {
                  final it = order.items[idx];
                  return Row(
                    children: [
                      Expanded(child: Text(it.product.name)),
                      Text('x${it.quantity}'),
                      const SizedBox(width: 12),
                      Text(moneyFmt
                          .format(it.quantity * it.product.discountedPrice)),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 32),
            _summaryRow('Tổng tiền hàng:', moneyFmt.format(productTotal)),
            const SizedBox(height: 8),
            _summaryRow('Phí ship:', moneyFmt.format(order.shippingFee)),
            const SizedBox(height: 8),
            _summaryRow('Tổng cộng:', moneyFmt.format(grandTotal),
                bold: true),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = bold
        ? const TextStyle(fontWeight: FontWeight.w600)
        : const TextStyle();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
