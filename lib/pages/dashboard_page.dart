import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'dart:math';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final List<Map<String, dynamic>> weekRank = [
      {'rank': 1, 'emoji': 'assets/images/sad-01.png', 'mood': 'Sad', 'percentage': 78.8},
      {'rank': 2, 'emoji': 'assets/images/nervous-01.png', 'mood': 'Nervous', 'percentage': 65.2},
      {'rank': 3, 'emoji': 'assets/images/Happy-01.png', 'mood': 'Happy', 'percentage': 58.3},
      {'rank': 4, 'emoji': 'assets/images/angry-01.png', 'mood': 'Angry', 'percentage': 47.5},
      {'rank': 5, 'emoji': 'assets/images/focus-01.png', 'mood': 'Focus', 'percentage': 38.9},
    ];

    final List<String> quotes = [
      "You are stronger than you think, and tomorrow needs you.",
      "Every day is a new beginning. Take a deep breath and start again.",
      "Believe in yourself and all that you are.",
      "Do what makes your soul shine.",
    ];
    
    final String randomQuote = quotes[Random().nextInt(quotes.length)];

    return Scaffold(
      backgroundColor: const Color(0xFF5A4E42),
      body: Column(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: const Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFDF2D2),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          HeaderSection(currentDate: currentDate),
          Expanded(
            child: SingleChildScrollView(
              child: BottomSection(weekRank: weekRank, randomQuote: randomQuote),
            ),
          ),

        ],
      ),
    );
  }
}

class HeaderSection extends StatefulWidget {
  final DateTime currentDate;
  const HeaderSection({required this.currentDate});

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentDate;
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
            primary: Color(0xFF556E59), 
            onPrimary: Colors.white,   
            surface: Color(0xFFB7CA79),  
            onSurface:Colors.white, 
            secondary: Color(0xFFFF6B6B),
            onBackground: Color(0xFFB7CA79), 
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF556E59), 
            ),
          ),
        ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFB7CA79),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Month header with navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF001A33)),
                  onPressed: () {
                    final previousMonth = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
                    setState(() {
                      _selectedDate = previousMonth;
                    });
                  },
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Row(
                    children: [
                      Text(
                        _getMonthName(_selectedDate.month),
                        style: const TextStyle(
                          color: Color(0xFF001A33),
                          fontFamily: 'Kanit',
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF001A33)),
                  onPressed: () {
                    final nextMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
                    setState(() {
                      _selectedDate = nextMonth;
                    });
                  },
                ),
              ],
            ),
          ),
          // Date timeline
          Expanded(
            child: EasyDateTimeLine(
              initialDate: _selectedDate,
              activeColor: const Color(0xFF556E59),
              headerProps: const EasyHeaderProps(
                showHeader: false,
              ),
              dayProps: EasyDayProps(
                width: 55,
                height: 100,
                activeDayStrStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontSize: 16,
                ),
                activeDayNumStyle: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Kanit',
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                inactiveDayStrStyle: const TextStyle(
                  color: Color(0xFF001A33),
                  fontFamily: 'Kanit',
                  fontSize: 16,
                ),
                inactiveDayNumStyle: const TextStyle(
                  color: Color(0xFF001A33),
                  fontFamily: 'Kanit',
                  fontSize: 20,
                ),
                inactiveDayStyle: DayStyle(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    border: Border.fromBorderSide(BorderSide(color: Colors.transparent)),
                  ),
                ),
                activeDayStyle: DayStyle(
                  decoration: const BoxDecoration(
                    color: Color(0xFF556E59),
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ),
              ),
              onDateChange: (selectedDate) {
                setState(() {
                  _selectedDate = selectedDate;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return monthNames[month - 1];
  }
}

class BottomSection extends StatelessWidget {
  final List<Map<String, dynamic>> weekRank;
  final String randomQuote;

  const BottomSection({required this.weekRank, required this.randomQuote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFFF8EFD4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          MoodStatsCard(weekRank: weekRank),
          const SizedBox(height: 20),
          QuoteCard(randomQuote: randomQuote),
          const SizedBox(height: 80), 
        ],
      ),
    );
  }
}

class MoodStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> weekRank;
  
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Sad':
        return const Color.fromRGBO(249, 221, 138, 1);
      case 'Nervous':
        return const Color.fromRGBO(224, 223, 218, 1);
      case 'Happy':
        return const Color.fromRGBO(171, 120, 103, 1);
      case 'Angry':
        return Colors.red.shade200;
      case 'Focus':
        return Colors.green.shade200;
      default:
        return Colors.grey;
    }
  }
  
  const MoodStatsCard({required this.weekRank});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFB7CA79),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Week Rank',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 24,
              color: Color(0xFF001A33),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Rank List Container
              Expanded(
                child: Container(
                  height: 200,
                  
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: weekRank.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 1.0),
                      child: Row(
                        children: [
                          Text('${item['rank']}.', style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 5),
                          Image.asset(item['emoji'], width: 30, height: 30),
                          const SizedBox(width: 5),
                          Text(item['mood'], style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Bar Chart Container
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: weekRank.take(3).map<Widget>((item) {
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter, 
                            children: [
                              // Bar container
                              Container(
                                width: 60,
                                height: 200, 
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  width: 60,
                                  height: item['percentage'] * 1.55, 
                                  decoration: BoxDecoration(
                                    color: _getMoodColor(item['mood']),
                                    // borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                ),
                              ),
                              
                              Positioned(
                                bottom: item['percentage'] * 1.6, 
                                child: Image.asset(
                                  item['emoji'],
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                              
                              Positioned(
                                bottom: item['percentage'] * 1.2, 
                                child: Text(
                                  '${item['percentage']}%',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
  
class QuoteCard extends StatelessWidget {
  final String randomQuote;
  const QuoteCard({required this.randomQuote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFB7CA79),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quote For Today',
            style: TextStyle(
              fontFamily: 'Kanit',
              fontSize: 24,
              fontWeight: FontWeight.normal,
              color: Color(0xFF001A33),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    randomQuote,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontStyle: FontStyle.normal,
                      color: Color(0xFF001A33),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

