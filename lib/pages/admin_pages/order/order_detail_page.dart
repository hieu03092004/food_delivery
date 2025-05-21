import 'package:flutter/material.dart';
import 'package:food_delivery/pages/dialog/dialogs.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/admin_model/orders_model.dart';
import 'assign_shipper_page.dart';

class OrderDetailPage extends StatelessWidget {
  OrderDetailPage({super.key, required this.order, required this.storeId});
  final Order order;
  final int storeId;

  /// Tính giá sau khi áp dụng giảm giá
  double _getDiscountedPrice(double price, double discountPercent) {
    return price * (1 - discountPercent / 100);
  }

  /// Tính tổng tiền của đơn hàng
  double get totalAmount {
    double itemsTotal = order.items.fold(0.0, (sum, item) {
      final unitPrice = item.product.discountPercent > 0
          ? _getDiscountedPrice(item.product.price, item.product.discountPercent)
          : item.product.price;
      return sum + unitPrice * item.quantity;
    });
    return itemsTotal + order.shippingFee;
  }

  Future<void> _assignShipper(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssignShipperPage(
          storeId: storeId,
          orderId: order.orderId,
        ),
      ),
    );

    if (result == true && context.mounted) {
      Navigator.pop(context);
    }
  }
  @override
  Widget build(BuildContext context) {
    print('🔍 order.status: ${order.status}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Đơn hàng ${order.orderId}'),
        actions: <Widget>[
          if ((order.status ?? '').toLowerCase() == 'pending') ...[
            IconButton(
              icon: const Icon(Icons.delivery_dining),
              // tooltip: 'Phân công',
              onPressed: () => _assignShipper(context),
            )
          ],
        ],
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(12),
            child: Text(
              'Ngày đặt: ${order.orderDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: order.items.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = order.items[index];
                final price = item.product.discountPercent > 0
                    ? _getDiscountedPrice(item.product.price, item.product.discountPercent)
                    : item.product.price;
                final totalPrice = price * item.quantity;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.thumbnailUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    item.product.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Số lượng: ${item.quantity}'),
                  trailing: Text(
                    '${(_getDiscountedPrice(item.product.price, item.product.discountPercent) * item.quantity).toStringAsFixed(0)} ${item.product.unit}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                _buildPriceRow('Tạm tính:', totalAmount - order.shippingFee),
                _buildPriceRow('Phí vận chuyển:', order.shippingFee.toDouble()),
                SizedBox(height: 8),
                _buildPriceRow('Tổng thanh toán:',
                    totalAmount, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} đ',
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.red : Colors.black87,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
