import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/admin_model/product_model.dart';
import '../../../permission/permission_helper.dart';
import '../../dialog/dialogs.dart';
import '../supabase_helper.dart';

class PageUpdateProduct extends StatefulWidget {
  PageUpdateProduct({super.key, required this.product});
  final Product product;
  @override
  State<PageUpdateProduct> createState() => _PageUpdateProductState();
}

class _PageUpdateProductState extends State<PageUpdateProduct> {
  TextEditingController txtId = TextEditingController();
  TextEditingController txtTen = TextEditingController();
  TextEditingController txtGia = TextEditingController();
  TextEditingController txtMoTa = TextEditingController();
  TextEditingController txtUnit = TextEditingController();
  TextEditingController txtDiscount = TextEditingController();
  bool isDeleted = false;
  bool isAddingNewCategory = false;
  TextEditingController txtNewCategory = TextEditingController();
  String? selectedCategory;
  XFile? _xFile;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    txtId.text = widget.product.id.toString();
    txtGia.text = widget.product.price.toString();
    txtTen.text = widget.product.name;
    txtMoTa.text = widget.product.description ?? "";
    txtUnit.text = widget.product.unit;
    txtDiscount.text = widget.product.discountPercent.toString();
    selectedCategory = widget.product.categoryName;
    isDeleted = widget.product.isDeleted;
    _fetchCategories();
  }
  Future<void> _fetchCategories() async {
    try {
      // Truy vấn danh mục từ bảng product
      final response = await Supabase.instance.client
          .from('product')
          .select('category_name')
          .eq('store_id', widget.product.storeId);

      final categoryList = (response as List)
          .map((item) => item['category_name'] as String)
          .toSet()
          .toList();

      setState(() {
        categories = categoryList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi kết nối: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật sản phẩm"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần chọn hình ảnh sản phẩm
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _xFile != null
                  ? Image.file(File(_xFile!.path), fit: BoxFit.cover)
                  : widget.product.thumbnailUrl.isNotEmpty
                  ? Image.network(widget.product.thumbnailUrl, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 80, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    var hasPermission = await requestPermission(Permission.photos);
                    if (hasPermission) {
                      var xImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (xImage != null)
                        setState(() {
                          _xFile = xImage;
                        });
                    }
                  },
                  child: Text("Chọn ảnh"),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Trường nhập liệu cho "Tên sản phẩm"
            TextFormField(
              controller: txtTen,
              decoration: InputDecoration(
                labelText: "Tên sản phẩm",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên sản phẩm';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Trường nhập liệu cho "Giá"
            TextFormField(
              controller: txtGia,
              decoration: InputDecoration(
                labelText: "Giá",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập giá sản phẩm';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            // Trường nhập liệu cho "Đơn vị"
            TextFormField(
              controller: txtUnit,
              decoration: InputDecoration(
                labelText: "Đơn vị",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),
            // Trường nhập liệu cho "Mô tả"
            TextFormField(
              controller: txtMoTa,
              decoration: InputDecoration(
                labelText: "Mô tả",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16),
            // Trường nhập liệu cho "Phần trăm giảm giá"
            TextFormField(
              controller: txtDiscount,
              decoration: InputDecoration(
                labelText: "Giảm giá (%)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 16),
            isAddingNewCategory
                ? TextFormField(
              controller: txtNewCategory,
              decoration: InputDecoration(
                labelText: "Tên danh mục mới",
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      isAddingNewCategory = false;
                      txtNewCategory.clear();
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên danh mục';
                }
                return null;
              },
            )
                : Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      ...categories.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      )),
                      DropdownMenuItem(
                        value: '__add_new__',
                        child: Text('+ Thêm danh mục mới'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == '__add_new__') {
                        setState(() {
                          isAddingNewCategory = true;
                          selectedCategory = null;
                        });
                      } else {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
                    validator: (value) {
                      if (!isAddingNewCategory && (value == null || value.isEmpty)) {
                        return 'Vui lòng chọn danh mục';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            SwitchListTile(
              title: Text("Ẩn sản phẩm"),
              value: isDeleted,
              onChanged: (value) {
                setState(() {
                  isDeleted = value;
                });
              },
            ),
            // Nút "Cập nhật"
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final categoryToSave = isAddingNewCategory
                        ? txtNewCategory.text.trim()
                        : selectedCategory;

                    if (categoryToSave == null || categoryToSave.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vui lòng nhập hoặc chọn danh mục")),
                      );
                      return;
                    }
                    showSnackBar(context, message: "Đang cập nhật.... ${txtTen.text}", seconds: 10);

                    final updatedProduct = Product(
                      id: widget.product.id,
                      name: txtTen.text,
                      description: txtMoTa.text,
                      discountPercent: double.parse(txtDiscount.text),
                      thumbnailUrl: widget.product.thumbnailUrl,
                      isDeleted: isDeleted,
                      storeId: widget.product.storeId,
                      price: double.parse(txtGia.text),
                      unit: txtUnit.text,
                      categoryName: categoryToSave,
                    );

                    // Cập nhật thông tin sản phẩm trong DB
                    await Supabase.instance.client
                        .from('product')
                        .update(updatedProduct.toMap())
                        .eq('product_id', widget.product.id!);

                    if (_xFile != null) {
                      var imageUrl = await updateImage(
                        image: File(_xFile!.path),
                        bucket: "images",
                        path: "food/product_${widget.product.id}.jpg",
                        upsert: true,
                      );
                      await Supabase.instance.client
                          .from('product')
                          .update({'thumbnail_url': imageUrl})
                          .eq('product_id', widget.product.id!);
                    }

                    showSnackBar(context, message: "Đã cập nhật.... ${txtTen.text}", seconds: 2);
                    Navigator.pop(context);
                  },
                  child: Text("Cập nhật"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
