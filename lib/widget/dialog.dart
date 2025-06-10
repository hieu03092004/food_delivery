import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, {required String messages, int second = 3}){
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messages), duration: Duration(seconds: second),)
  );
}