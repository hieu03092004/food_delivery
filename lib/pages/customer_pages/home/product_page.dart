// lib/customer_pageshome/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:food_delivery/pages/authentication/PageAuthUser.dart';
import 'package:food_delivery/pages/customer_pages/home/detailProduct_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:food_delivery/service/customer_service/Home/home_data.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';



class ProductPage extends StatefulWidget {

  final Store store;  // tên trường

  // constructor: required this.storeId (khớp trường bên trên)
  const ProductPage({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();

}

class _ProductPageState extends State<ProductPage> {
  late final Stream<List<Product>> productStream;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final _repo = HomeData();
    productStream = _repo.getDataProductsByStore(widget.store.id);
  }

  String _searchQuery = '';
  // 1. Khởi tạo formatter cho tiền tệ Việt Nam
  final NumberFormat moneyFmt = NumberFormat.simpleCurrency(
    locale: 'vi_VN',
    decimalDigits: 0,      // không hiện số thập phân
    name: 'đ',             // ký hiệu đặt cuối chuỗi
  );
  final auth = Get.find<AuthService>();
  final cartService = Get.find<CartService>();

  @override
  Widget build(BuildContext context) {
    print("Đã vào trang sản phẩm");
    return Scaffold(
      appBar:  CommonAppBar(title: widget.store.name,),
      backgroundColor: Colors.grey[200],
      body: Container(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchBar(
                hintText: 'Tìm món ăn...',
                onChanged: (q) => setState(() => _searchQuery = q),

              ),
            ),

            // Featured stores carousel
            const SizedBox(height: 8),
            // const FeaturedStoreCarousel(),

            // Product grid from Stream
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: productStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  final products = snapshot.data ?? [];
                  // Filter theo searchQuery (case-insensitive)
                  final filtered = _searchQuery.isEmpty
                      ? products
                      : products.where((p) =>
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('Không tìm thấy món nào'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final product = filtered[i];
                      final priceText       = moneyFmt.format(product.price);
                      final discountedText  = moneyFmt.format(product.discountedPrice);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailProductPage(product : product),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4), // thay Padding + margin
                          padding: const EdgeInsets.all(6),                              // padding chung
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Thumbnail: bo góc trực tiếp bằng ClipRRect
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  product.thumbnailURL,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Phần text (tên + giá)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          moneyFmt.format(product.discountedPrice),
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        const SizedBox(width: 6),
                                        if (product.discountPercentage > 0)
                                          Text(
                                            moneyFmt.format(product.price),
                                            style: const TextStyle(
                                              decoration: TextDecoration.lineThrough,
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Icon Cart
                              IconButton(
                                onPressed: () async{
                                  final loggedIn = auth.isLoggedIn;
                                  final id = auth.accountId.value;
                                  if(loggedIn){
                                    print("Đã đăng nhập");
                                    await cartService.addProductToCart(id, product.id);

                                  }
                                  else{
                                    // Chưa login, chuyển đến trang auth
                                    await Get.to(() => PageAuthUser());
                                  }

                                },
                                icon: const Icon(Icons.shopping_cart, size: 19),
                                splashRadius: 20,
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
