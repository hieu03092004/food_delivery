import 'package:flutter/material.dart';
import '../../../model/admin_model/product_model.dart';

class PageProductDetail extends StatelessWidget {
  const PageProductDetail({super.key, required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final discountedPrice = _getDiscountedPrice(product.price, product.discountPercent);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hình ảnh sản phẩm
            if (product.thumbnailUrl.isNotEmpty)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 1, // Khung hình vuông
                    child: Image.network(
                      product.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
                    ),
                  )
                ),
              )
            else
              const Center(child: Icon(Icons.fastfood, size: 100)),

            const SizedBox(height: 24),

            /// Tên sản phẩm
            Center(
              child: Text(
                product.name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),
            if (product.description.isNotEmpty)
              Text(
                product.description,
                style: const TextStyle(fontSize: 16),
              ),

            const SizedBox(height: 16),
            Text('Danh mục: ${product.categoryName}'),
            const SizedBox(height: 4),
            Text('Đơn vị: ${product.unit}'),

            const SizedBox(height: 20),
            if (product.discountPercent > 0) ...[
              Text(
                'Giá gốc: ${product.price.toStringAsFixed(0)} ${product.unit}',
                style: const TextStyle(
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Giá khuyến mãi: $discountedPrice ${product.unit}',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '-${product.discountPercent.toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.red),
              ),
            ] else
              Text(
                'Giá: ${product.price.toStringAsFixed(0)} ${product.unit}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  /// Hàm tính giá sau khi giảm
  String _getDiscountedPrice(double price, double discountPercent) {
    final discounted = price * (1 - discountPercent / 100);
    return discounted.toStringAsFixed(0);
  }
}
