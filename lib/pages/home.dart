
import 'package:flutter/material.dart';
import 'package:food_delivery/model/burger_model.dart';
import 'package:food_delivery/model/category_model.dart';
import 'package:food_delivery/model/pizza_model.dart';
import 'package:food_delivery/service/burger_data.dart';
import 'package:food_delivery/service/category_data.dart';
import 'package:food_delivery/service/pizza_data.dart';
import 'package:food_delivery/service/widget_support.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel>categories=[];
  List<PizzaModel>pizza=[];
  List<BurgerModel>burger=[];
  String track="0";
  @override
  void initState() {
    categories=getCategories();
    pizza=getPizza();
    burger=getBurger();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 20,right: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset("images/logo.png",height:80,width: 120,fit: BoxFit.contain,),
                    Text("Order your favourite food!",style: AppWidget.SimpleTextFieldStyle(),)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset("images/boy.jpg",height: 55,width: 55,fit: BoxFit.cover,),
                  ),
                )
              ],
            ),
            SizedBox(height: 20,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left:10),
                    margin: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: Color(0xFFececf8),borderRadius: BorderRadius.circular(10)),
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search food item..."
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:Color(0xffef2b39),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Icon(Icons.search,color: Colors.white,size: 30,),
                )
              ],
            ),
            SizedBox(height: 20,),
            Container(
              height: 60,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return CategoryTile(
                    categories[index].name!,
                    categories[index].image!,
                    index.toString(),
                  );
                },
              ),
            ),
            SizedBox(height: 10,),
            track=="0"?Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  mainAxisSpacing:10.0,
                  crossAxisSpacing: 10.0),
                itemCount: pizza.length,
                itemBuilder:(context, index) {
                  return FoodTile(
                    pizza[index].name!,pizza[index].image!, pizza[index].price!);
                },),
            ):track=="1"?Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    mainAxisSpacing:10.0,
                    crossAxisSpacing: 10.0),
                itemCount: burger.length,
                itemBuilder:(context, index) {
                  return FoodTile(
                      burger[index].name!,burger[index].image!, burger[index].price!);
                },),
            ):Container(),
          ],
        ),
      ),
    ) ;
  }
  Widget FoodTile(String name,String image,String price){
    return Container(
      padding: EdgeInsets.only(left: 10,top:10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              image,
              height: 150,
              width: 150,
              fit: BoxFit.contain,
            ),
          ),
          Text(name,style: AppWidget.boldTextFieldStyle(),),
          Text("\$"+price,style: AppWidget.priceTextFieldStyle(),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 50,
                decoration: BoxDecoration(
                  color: Color(0xffef2b39),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20)),
                ),
                child: Icon(Icons.arrow_forward,color: Colors.white,size: 25,),
              ),
            ],
          )

        ],
      ),
    );
  }
  Widget CategoryTile(String name,String image,String categoryindex){
    return GestureDetector(
      onTap: () {
        track=categoryindex.toString();
        setState(() {

        });
      },
      child: track==categoryindex?Container(
        margin: EdgeInsets.only(right: 20,bottom: 10),
        child: Material(
          elevation: 3.0,
          borderRadius: BorderRadius.circular(30),

          child: Container(

            padding: EdgeInsets.only(left: 20,right: 20),

            decoration: BoxDecoration(
              color:Color(0xffef2b39),
              borderRadius: BorderRadius.circular(30),

            ),
            child: Row(
              children: [
                Image.asset(image,height: 40,width: 40,fit: BoxFit.cover,),
                SizedBox(width:10,),
                Text(name,style: AppWidget.whiteTextFieldStyle(),)
              ],
            ),
          ),
        ),
      ):Container(
        padding: EdgeInsets.only(left: 20,right: 20),
        margin: EdgeInsets.only(right: 20,bottom:10),

        decoration: BoxDecoration(color:Color(0xFFececf8),borderRadius: BorderRadius.circular(30) ),
        child: Row(
          children: [
            Image.asset(image,height: 40,width: 40,fit: BoxFit.cover,),
            SizedBox(width:10,),
            Text(name,style: AppWidget.SimpleTextFieldStyle(),)
          ],
        ),
      ),
    );
  }

}


