import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery/pages/dialog/dialogs.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../model/admin_model/product_model.dart';
import '../../../permission/permission_helper.dart';
import '../supabase_helper.dart';

class PageAddProduct extends StatefulWidget {
  PageAddProduct({super.key, required this.storeId});
  final int storeId;

  @override
  State<PageAddProduct> createState() => _PageAddProductState();
}

class _PageAddProductState extends State<PageAddProduct> {
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
    _fetchCategories();
  }
  Future<void> _fetchCategories() async {
    try {
      // Truy vấn danh mục từ bảng product
      final response = await Supabase.instance.client
          .from('product')
          .select('category_name')
          .eq('store_id', widget.storeId);

      final categoryList = (response as List)
          .map((item) => item['category_name'] as String)
          .toSet()
          .toList();

      setState(() {
        categories = categoryList;
      });
    } catch (e) {
      // Xử lý ngoại lệ
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi kết nối: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thêm sản phẩm"),
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
              child: _xFile == null
                  ? Icon(Icons.image, size: 80, color: Colors.grey)
                  : Image.file(File(_xFile!.path), fit: BoxFit.cover),
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
                  child: const Text("Chọn ảnh"),
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
                  return "Vui lòng nhập tên sản phẩm";
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
                  return "Vui lòng nhập giá sản phẩm";
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

            // Nút "Thêm"
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final categoryToSave = isAddingNewCategory
                        ? txtNewCategory.text.trim()
                        : selectedCategory;

                    if (_xFile == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vui lòng chọn ảnh sản phẩm")),
                      );
                      return;
                    }
                    if (categoryToSave == null || categoryToSave.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vui lòng nhập hoặc chọn danh mục")),
                      );
                      return;
                    }
                    if (_xFile != null && categoryToSave != null) {
                      showSnackBar(context, message: "Đang thêm.... ${txtTen.text}", seconds: 10);

                      // Tạo object sản phẩm (chưa có product_id)
                      Product product = Product(
                        name: txtTen.text,
                        price: double.parse(txtGia.text),
                        unit: txtUnit.text.isNotEmpty ? txtUnit.text : "VND",
                        thumbnailUrl: '',
                        categoryName: categoryToSave!,
                        discountPercent: txtDiscount.text.isNotEmpty ? double.parse(txtDiscount.text) : 0.00,
                        description: txtMoTa.text,
                        isDeleted: isDeleted,
                        storeId: widget.storeId,
                      );

                      // Thêm sản phẩm vào DB và lấy lại bản ghi có ID
                      final response = await Supabase.instance.client
                          .from('product')
                          .insert(product.toMap()..remove('product_id')) // bỏ ID nếu đang là null
                          .select()
                          .single();  // lấy lại bản ghi mới có product_id

                      final insertedProduct = Product.fromMap(response);

                      // Tạo tên file ảnh với product_id
                      String fileName = 'product_${insertedProduct.id}.jpg';

                      // Upload ảnh với tên mới
                      var imageUrl = await uploadImage(
                        image: File(_xFile!.path),
                        bucket: "images",
                        path: "food/$fileName",
                      );

                      // Cập nhật lại thumbnail_url trong DB với URL của ảnh mới
                      await Supabase.instance.client
                          .from('product')
                          .update({'thumbnail_url': imageUrl})
                          .eq('product_id', insertedProduct.id!);

                      showSnackBar(context, message: "Đã thêm sản phẩm ${txtTen.text}", seconds: 2);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Vui lòng chọn ảnh và danh mục")),
                      );
                    }
                  },
                  child: const Text("Thêm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
