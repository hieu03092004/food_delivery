import 'package:flutter/material.dart';
import 'package:food_delivery/pages/admin_pages/product/product_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:food_delivery/pages/admin_pages/order/order_page.dart';
import 'package:food_delivery/pages/admin_pages/store/store_page.dart';
import 'package:food_delivery/pages/admin_pages/revenue_page.dart';

class MenuPage extends StatelessWidget {
  final int storeId;
  const MenuPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final storeStream = Supabase.instance.client
        .from('store')
        .stream(primaryKey: ['store_id'])
        .eq('store_id', storeId);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: storeStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        if (data.isEmpty)
          return const Center(child: Text("Không tìm thấy cửa hàng"));

        final store = data.first;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tài khoản'),
            backgroundColor: Colors.teal,
          ),
          body: ListView(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          store['image_url'] != null
                              ? NetworkImage(store['image_url'])
                              : null,
                      child:
                          store['image_url'] == null
                              ? const Icon(Icons.store, size: 40)
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      store['name'] ?? 'Tên cửa hàng',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              _buildNavItem(
                context,
                icon: Icons.info_outline,
                label: 'Thông tin cửa hàng',
                page: StorePage(storeId: storeId),
              ),
              _buildNavItem(
                context,
                icon: Icons.fastfood,
                label: 'Món ăn',
                page: ProductPage(storeId: storeId),
              ),
              _buildNavItem(
                context,
                icon: Icons.shopping_bag,
                label: 'Đơn hàng',
                page: OrdersPage(storeId: storeId,),
              ),
              _buildNavItem(
                context,
                icon: Icons.notifications,
                label: 'Thống kê',
                page: StoreRevenuePage(storeId: storeId),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }
}
