// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yuk_main/admin/admin_main.dart';
import 'package:yuk_main/customer/customer_main.dart';
import 'package:yuk_main/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  late SharedPreferences pref;

  Future getStatus() async {
    pref = await SharedPreferences.getInstance();
    final bool? status = pref.getBool('status');
    final String? role = pref.getString('role');

    if (status == null || status == false){
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()
        ),
      );
    } else {
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => 
          (role == '0') 
          ? const AdminMain()
          : const CustomerMain(),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: 'splashart', 
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Image.asset('assets/splashart.png'),
          )
        )
      ),
    );
  }
}