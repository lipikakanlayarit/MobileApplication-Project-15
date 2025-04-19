import 'package:flutter/material.dart';
import 'package:mobile_project/bottom_navigationbar/navigation_page.dart';
import 'models/database_helper.dart'; 


void main() async {
  // Ensure Flutter bindings are initialized before accessing platform channels
  WidgetsFlutterBinding.ensureInitialized();
  

  final dbHelper = DatabaseHelper();
  await dbHelper.database; 
  
  
  await dbHelper.ensureProfileImagePathColumn();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BottomNavigationPage(),
    );
  }
}