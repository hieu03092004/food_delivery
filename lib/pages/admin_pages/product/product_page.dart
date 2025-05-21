import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:food_delivery/async_widget.dart';
import 'package:food_delivery/pages/admin_pages/product/product_add_page.dart';
import 'package:food_delivery/pages/admin_pages/product/product_detail_page.dart';
import 'package:food_delivery/pages/admin_pages/product/product_update_page.dart';
import '../../../model/admin_model/product_model.dart';
import '../../dialog/dialogs.dart';

class ProductPage extends StatelessWidget {
  ProductPage({super.key, required this.storeId});
  final int storeId;
  late BuildContext myContext;

  /// Tính giá sau khi áp dụng giảm giá
  String _getDiscountedPrice(double price, double discountPercent) {
    final discounted = price * (1 - discountPercent / 100);
    return discounted.toStringAsFixed(0);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sản phẩm theo danh mục')),
      body: StreamBuilder<List<Product>>(
        stream: ProductSnapshot.getProductStream(),
        builder: (context, snapshot) {
          return AsyncWidget(
            snapshot: snapshot,
            builder: (context, snapshot) {
              final allProducts = snapshot.data!
                  .where((p) => p.storeId == storeId)
                  .toList();

              final categories = allProducts
                  .map((p) => p.categoryName)
                  .toSet()
                  .toList()
                ..sort();

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  myContext = context;
                  final category = categories[index];
                  final productsInCategory = allProducts
                      .where((p) => p.categoryName == category)
                      .toList();

                  return ExpansionTile(
                    title: Text(category),
                    children: productsInCategory.map<Widget>((product) {
                      return Slidable(
                        key: ValueKey(product.id),
                        endActionPane: ActionPane(
                          extentRatio: 0.6,
                          motion: const ScrollMotion(),
                          children: [
                            SlidableAction  (
                              onPressed: (context) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PageUpdateProduct(product: product),
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
                                    myContext,
                                    "Bạn có muốn xoá sản phẩm '${product.name}' không?"
                                );

                                if (confirm == 'ok') {
                                  await ProductSnapshot.delete(product.id!);
                                  ScaffoldMessenger.of(myContext).showSnackBar(
                                    SnackBar(
                                      content: Text("Đã xoá sản phẩm '${product.name}'"),
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
                            color: product.isDeleted ? Colors.grey.shade100 : null,
                            child: ListTile(
                              leading: product.thumbnailUrl.isNotEmpty
                                  ? Image.network(
                                product.thumbnailUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                                  : const Icon(Icons.fastfood, size: 40),
                              title: Text(
                                product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: product.description.isNotEmpty
                                  ? Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: product.isDeleted ? Colors.grey : null,
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
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      '${_getDiscountedPrice(product.price, product.discountPercent)} ${product.unit}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '-${product.discountPercent.toStringAsFixed(0)}%',
                                      style: const TextStyle(color: Colors.red, fontSize: 12),
                                    ),
                                  ] else
                                    Text(
                                      '${product.price.toStringAsFixed(0)} ${product.unit}',
                                      style: const TextStyle(
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
                                    builder: (context) => PageProductDetail(product: product),
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
              builder: (context) => PageAddProduct(storeId: storeId),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
