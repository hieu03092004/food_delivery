import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:food_delivery/model/admin_model/product_model.dart';

class StoreRevenuePage extends StatefulWidget {
  StoreRevenuePage({super.key, required this.storeId});
  final int storeId;

  @override
  State<StoreRevenuePage> createState() => _StoreRevenuePageState();
}

class _StoreRevenuePageState extends State<StoreRevenuePage> {
  DateTime selectedDate = DateTime.now();
  double? revenue;
  bool isLoading = false;

  // Danh sách thống kê từng món ăn
  List<MapEntry<int, Map<String, dynamic>>> productStats = [];

  Future<void> fetchRevenue() async {
    setState(() {
      isLoading = true;
      revenue = null;
      productStats = [];
    });

    final supabase = Supabase.instance.client;

    final start = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final end = start.add(Duration(days: 1));

    try {
      final data = await supabase
          .from('orders')
          .select('order_id, order_date, status, shipping_fee, order_item(quantity, product(*))')
          .eq('status', 'delivered')
          .gte('order_date', start.toIso8601String())
          .lt('order_date', end.toIso8601String());

      double totalRevenue = 0.0;
      Map<int, Map<String, dynamic>> stats = {};

      for (var orderMap in data) {
        final orderItems = orderMap['order_item'] as List<dynamic>;
        double orderTotal = 0.0;

        for (var item in orderItems) {
          final productMap = item['product'];
          if (productMap == null) continue;

          final product = Product.fromMap(productMap);
          if (product.storeId != widget.storeId) continue;

          final quantity = item['quantity'] as int;
          final price = product.price;
          final discount = product.discountPercent;

          final itemRevenue = (price * (1 - discount / 100)) * quantity;
          orderTotal += itemRevenue;

          if (!stats.containsKey(product.id)) {
            stats[product.id!] = {
              'product': product,
              'quantity': 0,
              'revenue': 0.0,
            };
          }

          stats[product.id]!['quantity'] += quantity;
          stats[product.id]!['revenue'] += itemRevenue;
        }

        if (orderTotal > 0) {
          final shippingFee = (orderMap['shipping_fee'] ?? 0).toDouble();
          orderTotal += shippingFee;
        }

        totalRevenue += orderTotal;
      }

      // Sắp xếp theo doanh thu giảm dần
      final sortedStats = stats.entries.toList()
        ..sort((a, b) => (b.value['revenue'] as double).compareTo(a.value['revenue'] as double));

      setState(() {
        revenue = totalRevenue;
        productStats = sortedStats;
      });
    } catch (e) {
      print('❌ Lỗi khi lấy dữ liệu: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      fetchRevenue();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRevenue();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text("Thống kê doanh thu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text('Chọn ngày: $formattedDate'),
              onPressed: pickDate,
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : productStats.isEmpty
                ? Text('Không có dữ liệu đơn hàng hôm đó.')
                : Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: productStats.length,
                      itemBuilder: (context, index) {
                        final stat = productStats[index].value;
                        final product = stat['product'] as Product;
                        final quantity = stat['quantity'] as int;
                        final itemRevenue = stat['revenue'] as double;

                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('Số lượng: $quantity'),
                          trailing: Text(
                            '${itemRevenue.toStringAsFixed(0)} đ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  Divider(),
                  Text(
                    'Tổng doanh thu: ${revenue!.toStringAsFixed(0)} đ',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
