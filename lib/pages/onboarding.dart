import 'package:flutter/material.dart';
import 'package:food_delivery/service/widget_support.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth  = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(

        margin: EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Container(
              width: screenWidth,               // 100% chiều rộng
              height: screenHeight * 0.5,
              // 40% chiều cao màn hình
              child: Image.asset(
                "images/onboard.png",
                fit: BoxFit.cover,             // hoặc BoxFit.fill / BoxFit.contain tuỳ ý
              ),
            ),
            SizedBox(height: 20.0,),
            Text("The Fastest\nFood Delivery",style: AppWidget.HeadLineTextFieldStyle(),),
            SizedBox(height: 10,),
            Text("Craving something delicious?\nOrder now and get your favorites\n delivered fast!",
              textAlign: TextAlign.center,
              style: AppWidget.SimpleTextFieldStyle(),),
            SizedBox(height: 20,),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width/2,
              decoration: BoxDecoration(
                color:Color(0xff8c592a),
                borderRadius: BorderRadius.circular(20)

              ),
              child: Center(
                child: Text("Get started",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    ) ;
  }
}
