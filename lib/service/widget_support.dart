import 'package:flutter/material.dart';

class AppWidget{
  static TextStyle HeadLineTextFieldStyle(){
    return TextStyle(
      color: Colors.black,
      fontSize: 25.0,
      fontWeight: FontWeight.bold,
    );
  }
  static TextStyle SimpleTextFieldStyle(){
    return TextStyle(
      color: Colors.black,
      fontSize: 18.0,
    );
  }
  static TextStyle whiteTextFieldStyle(){
    return TextStyle(
      color: Colors.white,
      fontSize: 18.0,
      fontWeight: FontWeight.bold
    );
  }
  static TextStyle boldTextFieldStyle(){
    return TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );
  }
  static TextStyle priceTextFieldStyle(){
    return TextStyle(
      color: const Color.fromARGB(174, 0, 0, 0),
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    );
  }
}