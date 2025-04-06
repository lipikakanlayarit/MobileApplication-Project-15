import 'package:flutter/material.dart';

import 'package:mobile_project/pages/Articles_page.dart';
import 'package:mobile_project/pages/Profile_page.dart';
import 'package:mobile_project/pages/Quest_page.dart';
import 'package:mobile_project/pages/dashboard_page.dart';
import 'package:mobile_project/pages/home_page.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {

  int myCurrentIndex = 0;
  List page = const[
    HomePage(),
    ArticlesPage(),
    QuestPage(),
    DashboardPage(),
    ProfilePage(),
    
  ];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(


      bottomNavigationBar: BottomNavigationBar(
        
        
        currentIndex: myCurrentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromARGB(255, 90, 78, 66),
        selectedItemColor: Color.fromARGB(255, 253, 242, 210),
        unselectedItemColor: Color.fromARGB(255, 119, 104, 88),
        

        onTap: (index){
          setState(() {
            myCurrentIndex = index;
          });
        },
        
        items: const [ 
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined),label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined),label: 'Article'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined),label: 'Quest'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined),label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outlined),label: 'Profile'),
      ],
      ),
      body: page[myCurrentIndex]
    );
  }
}