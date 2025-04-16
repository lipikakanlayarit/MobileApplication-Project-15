import 'package:flutter/material.dart';
import 'package:mobile_project/pages/Setting.dart';
import '/pages/Login_page.dart';
import 'package:mobile_project/models/database_helper.dart' as dbHelper;
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final dbHelper.DatabaseHelper _settings = dbHelper.DatabaseHelper();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ฟังก์ชันดึงข้อมูลผู้ใช้จากฐานข้อมูล
  Future<void> _loadUserData() async {
    try {
      final String? imagePath = _userData?['profileImagePath'];
      if (imagePath != null && imagePath.isNotEmpty) {
        final File imageFile = File(imagePath);
        if (await imageFile.exists()) {
          print("Image exists at path: $imagePath");
        } else {
          print("Image does not exist at path: $imagePath");
        }
      }
      final userData = await _settings.getUserData();
      print("User data loaded: $userData"); // Debug print
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _userData = {}; // Empty map as fallback
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFDF2D2),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final String username = _userData?['username'] ?? 'User';
    final String dob = _userData?['dateOfBirth'] ?? 'Not Set';
    final String phone = _userData?['phoneNumber'] ?? 'Not Set';
    final String email = _userData?['email'] ?? 'Not Set';
    final String? imagePath = _userData?['profileImagePath'];

    print("DOB: $dob, Phone: $phone");

    return Scaffold(
      backgroundColor: const Color(0xFFFDF2D2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header image
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Background-profile.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Bottom section
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                width: double.infinity,
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
                    // Profile Circle
                    Transform.translate(
                      offset: const Offset(0, -50),
                      child: CircleAvatar(
                        radius: 90,
                        backgroundColor: const Color(0xFFFDF2D2),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              (imagePath != null && imagePath.isNotEmpty)
                                  ? FileImage(File(imagePath))
                                  : const AssetImage(
                                        'assets/images/profile.jpg',
                                      )
                                      as ImageProvider,
                        ),
                      ),
                    ),

                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Column(
                        children: [
                          Text(
                            username,
                            style: const TextStyle(
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
                      padding: const EdgeInsets.only(left: 90),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.brown[400],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "$dob",
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.brown[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(
                                Icons.phone,
                                color: Colors.brown[400],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                phone,
                                style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.brown[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Icon(
                                Icons.email,
                                color: Colors.brown[400],
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  email,
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: Colors.brown[700],
                                  ),
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
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );

                            if (result == true) {
                              _loadUserData(); // ดึงข้อมูลใหม่จากฐานข้อมูล
                            }
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

                        const Text(
                          "|",
                          style: TextStyle(
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            fontWeight: FontWeight.w100,
                            color: Colors.black87,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            // Remove all previous pages from the stack, and only keep the LoginPage
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                              (route) =>
                                  false, // This ensures that no previous pages are in the stack
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
