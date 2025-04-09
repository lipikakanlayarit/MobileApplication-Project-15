import 'package:flutter/material.dart';
import '/pages/Setting.dart';
import '/pages/Login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header image
            Container(
              width: screenWidth,
              height: screenHeight * 0.25,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Background-profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Bottom section
            Transform.translate(
              offset: const Offset(0, -30), // Moves upward to overlap
              child: Container(
                height: screenHeight * 0.75,
                width: screenWidth,
                padding: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDF2D2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Circle - overlapping
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: const Color(0xFFFDF2D2),
                        child: const CircleAvatar(
                          radius: 80,
                          backgroundImage: AssetImage('assets/images/profile.jpg'),
                        ),
                      ),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -30), // Move upwards
                      child: Column(
                        children: const [
                          Text(
                            "Lipikrit",
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Kanit',
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                          ),
                          
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.only(left: 90), // Set the start point here
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.brown[400], size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "4 Jul 2005 (20 years)",
                                style: TextStyle(fontFamily: 'Kanit', color: Colors.brown[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(Icons.phone, color: Colors.brown[400], size: 20),
                              const SizedBox(width: 10),
                              Text(
                                "090 - 999 - 9999",
                                style: TextStyle(fontFamily: 'Kanit', color: Colors.brown[700]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(Icons.email, color: Colors.brown[400], size: 20),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  "ytyjrcgvbhjkj:p@gvbhjnjkml:l.com",
                                  style: TextStyle(fontFamily: 'Kanit', color: Colors.brown[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 150),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsPage()),
                            );
                          },
                          child: const Text(
                            "Setting",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const Text("|",
                            style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 18,
                                fontWeight: FontWeight.w100,
                                color: Colors.black87)),

                        TextButton(
                          onPressed: () {
                            // Remove all previous pages from the stack, and only keep the LoginPage
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false, // This ensures that no previous pages are in the stack
                            );
                          },
                          child: const Text(
                            "Log-out",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                      ],
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





