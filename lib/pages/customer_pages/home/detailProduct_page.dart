import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/model/customer_model/product_model.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:food_delivery/service/auth_servicae/AuthService.dart';
import 'package:food_delivery/service/customer_service/Cart/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class DetailProductPage extends StatefulWidget {
  final Product product;

  const DetailProductPage({super.key, required this.product});

  @override
  State<DetailProductPage> createState() => _DetailProductPageState();

}

class _DetailProductPageState extends State<DetailProductPage> {
  Color themeOrange = Color(0xFFEE4D2D);
  int quantity = 1;
  final cartService = Get.find<CartService>();
  final auth = Get.find<AuthService>();


  @override
  Widget build(BuildContext context) {

    print("Đã vào trang chi tiết sản phẩm");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Center(
                    child: Image.network(
                      widget.product.thumbnailURL,
                      height: 220,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 220,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Unit
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.product.priceText}',
                          style: const TextStyle(
                            color: Colors.deepOrangeAccent ,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,

                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          ),

          // Bottom Bar with Price and Add to Cart
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, themeOrange],
                stops: [0.5, 0.5],              // mỗi màu chiếm 50%
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),

            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      print('Đã nhấn giỏ hàng');
                      _showAddToCartModal();
                    },
                    child: Center(
                      child: Icon(Icons.shopping_cart, color: Colors.white, size: 25),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // tap ô 2
                    },
                    child: Center(
                      child: Text(
                        "Mua ngay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }



  void _showAddToCartModal() {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) =>
            Container(
              decoration: BoxDecoration(

              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.network(
                        widget.product.thumbnailURL,
                        width: 80,
                        height: 80,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.product.name}',
                              style: const TextStyle(
                                color: Colors.deepOrangeAccent ,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,

                              ),
                            ),
                            const SizedBox(height: 4),

                          ],
                        ),
                      ),
                    ],
                  ),


                  Row(

                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Số lượng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setModalState(() {
                              quantity--;
                            });
                            setState(() {});
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantity++;
                          });
                          setState(() {});
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeOrange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async{
                        print('Đã nhấn Thêm vào giỏ hàng');
                        await cartService.addProductToCart(auth.accountId.value, widget.product.id, quantity);

                      },
                      child: const Text(
                        'Thêm vào giỏ hàng',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}