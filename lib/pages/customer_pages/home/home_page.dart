// lib/customer_pages/home/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:food_delivery/pages/customer_pages/home/product_page.dart';
import 'package:food_delivery/service/customer_service/Home/home_data.dart';
import 'package:food_delivery/widget/default_appBar.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _repo = HomeData();
  String _searchQuery = '';
  Color themeOrange = Color(0xFFEE4D2D);
  @override
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
              child: StreamBuilder<List<Store>>(
                stream: _repo.getDataHomeStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }
                  final stores = snapshot.data ?? [];
                  // Filter theo searchQuery (case-insensitive)
                  final filtered = _searchQuery.isEmpty
                      ? stores
                      : stores.where((p) =>
                      p.name.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('Không tìm thấy store nào'));
                  }
                  return ListView.separated(
                      itemBuilder: (context, index) {
                        Store store = filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductPage(store : store),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6
                            ),
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Container(
                                        width: 80,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.transparent,  // màu viền
                                            width: 4,            // độ dày viền
                                          ),
                                          borderRadius: BorderRadius.circular(12), // bo góc nếu muốn
                                          image: DecorationImage(
                                            image: NetworkImage(store.imageURL),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [
                                        Text('${store.name}',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),)
                                      ],
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );

                      },
                      separatorBuilder: (context, index) =>  SizedBox.shrink(),
                      itemCount: filtered.length);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


