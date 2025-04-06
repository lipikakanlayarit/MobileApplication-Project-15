import 'package:flutter/material.dart';
import 'package:mobile_project/bottom_navigationbar/navigation_page.dart';
import '/pages/Signup_page.dart';
import '/pages/Login_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationPage(),
    );
  }
}