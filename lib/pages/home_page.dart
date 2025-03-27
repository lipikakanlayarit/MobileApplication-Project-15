import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white10,
      ),
      home: Scaffold(
      backgroundColor: const Color(0xFFF3EAD3), 
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              width: screenWidth,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/HomeBackground-01.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  //  date
                  Positioned(
                      top: screenHeight * 0.09,
                      left: screenWidth * 0.10,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                DateFormat.d().format(DateTime.now()), 
                                style: const TextStyle(
                                  fontFamily: 'KleeOne',
                                  fontSize: 60,
                                  color: Colors.white,
                                ),
                              ),
                              
                            ],
                          ),
                          // month
                          Padding(
                            padding: const EdgeInsets.only(left:10), 
                            child: Text(
                              DateFormat.MMMM().format(DateTime.now()), // เดือน
                              style: const TextStyle(
                                fontFamily: 'KleeOne',
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // รูปกระต่าย
                  Positioned(
                    bottom: screenHeight * 0.05,
                    right: screenWidth * 0.05,
                    child: Image.asset(
                      'assets/images/normal-01.png',
                      width: screenWidth * 0.5,
                      height: screenWidth * 0.5,
                    ),
                  ),

                  // (It's gonna be okay)
                  Positioned(
                    top: screenHeight * 0.05,
                    right: screenWidth * 0.12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E315A),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        "It's gonna\nbe okay",
                        style: TextStyle(
                          fontFamily: 'KleeOne',
                          color: Colors.white,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // "How do you feel"
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
              // padding: EdgeInsets.all(screenHeight * 0.02),
              decoration: BoxDecoration(
                color:  Color.fromRGBO(183, 202, 121,1),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(87, 113, 112, 0.5),
                    offset: const Offset(7, 9), 
                    blurRadius: 0, 
                    // spreadRadius: 5, 
                  ),
                  // BoxShadow(
                  //   color: Color.fromRGBO(87, 113, 112, 0.6), 
                  //   offset: Offset(0, 10), 
                  //   blurRadius: 0,
                  //   spreadRadius: 5,
                  // ),
                ],
              ),
              child: const Center(
                child: Text(
                  "How do you feel,\nI'm Always Here.",
                  style: TextStyle(
                    fontFamily: 'KleeOne',
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Today Mood
          Expanded(
            flex: 1,
            child: Container(
              width: screenWidth,
               margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
              padding: EdgeInsets.all(screenWidth * 0.03),
              decoration: BoxDecoration(
                color:  Color.fromRGBO(183, 202, 121,1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today Mood",
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.all(screenHeight * 0.025),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(6, (index) {
                        return Column(
                          children: [
                            Image.asset(
                              'assets/images/normal-01.png',
                              width: screenWidth * 0.08,
                              height: screenWidth * 0.08,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "${10 + index * 2}:00",
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}

