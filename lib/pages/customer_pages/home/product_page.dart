// lib/customer_pageshome/pages/product_page.dart
import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:food_delivery/pages/authentication/PageAuthUser.dart';
import 'package:food_delivery/pages/customer_pages/home/detailProduct_page.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';

import 'package:food_delivery/service/customer_service/controller_cart.dart';
import 'package:food_delivery/service/customer_service/controller_product.dart';
import 'package:food_delivery/widget/default_appBar.dart';

import 'package:intl/intl.dart';
import 'package:get/get.dart';


class ProductPage extends StatefulWidget {
  final Store store;

  const ProductPage({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String _searchQuery = '';

  // formatter tiền tệ
  final moneyFmt = NumberFormat.simpleCurrency(
    locale: 'vi_VN', decimalDigits: 0, name: 'đ',
  );

  final auth = Get.find<AuthService>();
  final cartService = Get.find<ControllerCart>();

  late final ControllerProduct _ctrl;

  @override
  void initState() {
    super.initState();
    // Khởi ControllerProduct với tag = storeId
    _ctrl = ControllerProduct.of(widget.store.id);
    // onReady của controller sẽ tự load data + realtime listen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.store.name),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              hintText: 'Tìm món ăn...',
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
          ),
          const SizedBox(height: 8),

          // danh sách products
          Expanded(
            child: GetBuilder<ControllerProduct>(
              tag: '${widget.store.id}',

              builder: (controller) {
                // 1) Đang load dữ liệu
                if (controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2) Lỗi khi fetch
                if (controller.loadError != null) {
                  return Center(child: Text('Lỗi: ${controller.loadError}'));
                }
                // 3) Dữ liệu đã về
                final products = controller.products
                    .where((p) =>
                _searchQuery.isEmpty ||
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();

                if (products.isEmpty) {
                  return const Center(child: Text('Không tìm thấy món nào'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final product = products[i];
                    return GestureDetector(
                      onTap: () =>
                          Get.to(() => DetailProductPage(product: product)),
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                product.thumbnailURL,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image, size: 100),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        moneyFmt.format(product.discountedPrice),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14),
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
                            IconButton(
                              onPressed: () async {
                                if (auth.isLoggedIn) {
                                  await cartService
                                      .addProductToCart(product.id);
                                } else {
                                  Get.to(() => PageAuthUser());
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
    );
  }
}
