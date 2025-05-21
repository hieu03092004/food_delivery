import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../authentication/authenticaion_state/authenticationCubit.dart';
class HomePages extends StatelessWidget {
  const HomePages({super.key});


  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthenticationCubit>().state;
    final int? uid = authState.user?.uid;

    print("Userid:${uid}");
    return  Scaffold(
      body: Center(
        child: Text("Trang chủ của shipper"),
      ),
    );
  }
}
