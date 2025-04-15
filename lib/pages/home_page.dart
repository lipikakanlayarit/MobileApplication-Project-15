import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/pages/Chat_page.dart';
import 'package:mobile_project/models/db_helper.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 184, 132, 108),
      body: Column(
        children: <Widget>[
          HeaderSection(screenWidth: screenWidth, screenHeight: screenHeight),
          BottomSection(screenWidth: screenWidth, screenHeight: screenHeight),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const HeaderSection({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Container(
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/HomeBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.02,
              left: screenWidth * 0.11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd').format(DateTime.now()),
                    style: const TextStyle(
                      fontFamily: 'KleeOne',
                      fontSize: 100,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.15,
              left: screenWidth * 0.15,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat.MMMM().format(DateTime.now()),
                    style: const TextStyle(
                      fontFamily: 'KleeOne',
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.02,
              right: screenWidth * 0.02,
              child: Image.asset(
                'assets/images/normal-01.png',
                width: screenWidth * 0.6,
                height: screenWidth * 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomSection extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const BottomSection({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenHeight * 0.51,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 253, 242, 210),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          FeelButtonSection(screenWidth: screenWidth, screenHeight: screenHeight),
          SizedBox(height: 10),
          TodayMoodSection(screenWidth: screenWidth, screenHeight: screenHeight),
        ],
      ),
    );
  }
}

class FeelButtonSection extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const FeelButtonSection({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatPage(userId: 1)),
        );
      },
      child: Container(
        height: screenHeight * 0.22,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(183, 202, 121, 1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0x80577170),
              offset: const Offset(7, 9),
              blurRadius: 0,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "I'm Always Here \n to listen your feeling",
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
    );
  }
}

class TodayMoodSection extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;

  const TodayMoodSection({
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  State<TodayMoodSection> createState() => _TodayMoodSectionState();
}

class _TodayMoodSectionState extends State<TodayMoodSection> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _todayMessages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayMessages();
  }

  Future<void> _loadTodayMessages() async {
    try {
      final messages = await _dbHelper.getMessagesForToday();

      setState(() {
        _todayMessages = messages;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading today messages: \$e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.screenHeight * 0.2,
      width: widget.screenWidth,
      margin: EdgeInsets.symmetric(
        horizontal: widget.screenWidth * 0.05,
        vertical: widget.screenHeight * 0.01,
      ),
      padding: EdgeInsets.all(widget.screenWidth * 0.03),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(183, 202, 121, 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today Mood",
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 25,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  padding: EdgeInsets.all(widget.screenHeight * 0.025),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _todayMessages.isEmpty
                      ? Center(
                          child: Text(
                            "No messages today",
                            style: TextStyle(
                              fontFamily: 'Kanit',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _todayMessages.map((message) {
                              String timeText = 'Unknown';
                              try {
                                final timestamp = DateTime.parse(message['timestamp'] ?? '');
                                timeText = DateFormat('HH:mm').format(timestamp);
                              } catch (e) {
                                print('Error parsing timestamp: \$e');
                              }

                              return Container(
                                margin: EdgeInsets.only(right: widget.screenWidth * 0.05),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      message['emoji_path'] ?? 'assets/images/normal-01.png',
                                      width: widget.screenWidth * 0.12,
                                      height: widget.screenWidth * 0.12,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        fontFamily: 'Kanit',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                ),
        ],
      ),
    );
  }
}