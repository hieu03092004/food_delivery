import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_delivery/async_widget.dart';
import 'package:food_delivery/pages/admin_pages/product/product_add_page.dart';
import 'package:food_delivery/pages/admin_pages/product/product_detail_page.dart';
import 'package:food_delivery/pages/admin_pages/product/product_update_page.dart';
import 'package:food_delivery/model/admin_model/product_model.dart';
import 'package:food_delivery/pages/dialog/dialogs.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.storeId});
  final int storeId;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late Future<Map<int, Product>> _future;
  Map<int, Product> _products = {};

  @override
  void initState() {
    super.initState();
    _loadData();

    // Lắng nghe realtime và tự update UI
    ProductSnapshot.listenDataChange(
      _products,
      updateUI: () {
        _loadData();
      },
    );
  }

  void _loadData() {
    _future = ProductSnapshot.getProduct().then((data) {
      // Lưu dữ liệu để listenDataChange cập nhật đúng
      _products = data;
      return data;
    });
    setState(() {});
  }

  @override
  void dispose() {
    ProductSnapshot.unsubscribeListenProductChange();
    super.dispose();
  }

  /// Tính giá sau giảm
  String _getDiscountedPrice(double price, double discountPercent) {
    final discounted = price * (1 - discountPercent / 100);
    return discounted.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sản phẩm theo danh mục")),
      body: FutureBuilder<Map<int, Product>>(
        future: _future,
        builder: (context, snapshot) {
          return AsyncWidget(
            snapshot: snapshot,
            builder: (context, snapshot) {
              final allProducts =
                  snapshot.data!.values
                      .where((p) => p.storeId == widget.storeId)
                      .toList();

              final categories =
                  allProducts.map((p) => p.categoryName).toSet().toList()
                    ..sort();

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final productsInCategory =
                      allProducts
                          .where((p) => p.categoryName == category)
                          .toList();

                  return ExpansionTile(
                    title: Text(category),
                    children:
                        productsInCategory.map<Widget>((product) {
                          return Slidable(
                            key: ValueKey(product.id),
                            endActionPane: ActionPane(
                              extentRatio: 0.6,
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PageUpdateProduct(
                                              product: product,
                                            ),
                                      ),
                                    );
                                  },
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  icon: Icons.edit,
                                  label: 'Cập nhật',
                                ),
                                SlidableAction(
                                  onPressed: (context) async {
                                    final confirm = await showConfirmDialog(
                                      context,
                                      "Bạn có muốn xoá sản phẩm '${product.name}' không?",
                                    );
                                    if (confirm == 'ok') {
                                      await ProductSnapshot.delete(product.id!);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Đã xoá sản phẩm '${product.name}'",
                                          ),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete_forever,
                                  label: 'Xoá',
                                ),
                              ],
                            ),
                            child: Opacity(
                              opacity: product.isDeleted ? 0.5 : 1.0,
                              child: Container(
                                color:
                                    product.isDeleted
                                        ? Colors.grey.shade100
                                        : null,
                                child: ListTile(
                                  leading:
                                      product.thumbnailUrl.isNotEmpty
                                          ? Image.network(
                                            product.thumbnailUrl,
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          )
                                          : Icon(Icons.fastfood, size: 40),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle:
                                      product.description.isNotEmpty
                                          ? Text(
                                            product.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color:
                                                  product.isDeleted
                                                      ? Colors.grey
                                                      : null,
                                            ),
                                          )
                                          : null,
                                  trailing: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (product.discountPercent > 0) ...[
                                        Text(
                                          '${product.price.toStringAsFixed(0)} ${product.unit}',
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '${_getDiscountedPrice(product.price, product.discountPercent)} ${product.unit}',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          '-${product.discountPercent.toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ] else
                                        Text(
                                          '${product.price.toStringAsFixed(0)} ${product.unit}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PageProductDetail(
                                              product: product,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageAddProduct(storeId: widget.storeId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
