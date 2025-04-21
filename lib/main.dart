import 'package:flutter/material.dart';
import 'pages/Login_page.dart';
import 'models/database_helper.dart'; 


void main() async {
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
    return  MaterialApp(
      home: LoginPage(),
    );
  }
}