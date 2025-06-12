// lib/customer_pages/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:food_delivery/pages/customer_pages/home/product_page.dart';
import 'package:food_delivery/service/customer_service/controller_store.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  String _searchQuery = '';
  Color themeOrange = Color(0xFFEE4D2D);

  @override
  void initState() {
    super.initState();
    // Khởi ControllerStore ngay khi widget đc tạo
    Get.put(ControllerStore());
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Khám phá món ngon",
      ),
      backgroundColor: Colors.grey[200],
      body: Container(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                hintText: 'Tìm cửa hàng...',
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
            ),

            // Featured stores carousel
            const SizedBox(height: 8),
            // const FeaturedStoreCarousel(),

            // Product grid from Stream
            Expanded(
              child: GetBuilder<ControllerStore>(
                id: 'stores',
                builder: (ctrl) {
                  // 1) Nếu đang loading → spinner
                  if (ctrl.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // 2) Dữ liệu đã load, filter như trước
                  final stores = ctrl.stores.toList();
                  final filtered = _searchQuery.isEmpty
                      ? stores
                      : stores.where((s) =>
                      s.name.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Không tìm thấy cửa hàng nào'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final store = filtered[index];
                      return GestureDetector(
                        onTap: () {
                          print("store.name: ${store.name}");
                          Get.to(() => ProductPage(store: store));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  store.imageURL,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  store.name,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),





          ],
        ),
      ),
    );
  }
}


