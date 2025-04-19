import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'dart:math';
import 'package:mobile_project/models/db_helper.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DateTime _selectedDate;
  late DateTime _weekStartDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _calculateWeekStart();
  }

  void _calculateWeekStart() {
    // Calculate the start of the week (Monday)
    _weekStartDate = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
  }

  void _updateWeek(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _calculateWeekStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> quotes = [
      "You are stronger than you think, and tomorrow needs you.",
      "Every day is a new beginning. Take a deep breath and start again.",
      "Believe in yourself and all that you are.",
      "Do what makes your soul shine.",
    ];

    final String randomQuote = quotes[Random().nextInt(quotes.length)];

    return Scaffold(
      backgroundColor: const Color(0xFF5A4E42),
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFDF2D2),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5A4E42),
      ),
      body: Column(
        children: <Widget>[
          // Pass the selected date and update callback to HeaderSection
          HeaderSectionWeekly(
            currentDate: _selectedDate,
            onWeekChanged: _updateWeek,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: BottomSection(
                randomQuote: randomQuote,
                weekStartDate: _weekStartDate,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Weekly calendar header
class HeaderSectionWeekly extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onWeekChanged;

  const HeaderSectionWeekly({
    super.key,
    required this.currentDate,
    required this.onWeekChanged,
  });

  @override
  State<HeaderSectionWeekly> createState() => _HeaderSectionWeeklyState();
}

class _HeaderSectionWeeklyState extends State<HeaderSectionWeekly> {
  late DateTime _selectedDate;
  late DateTime _weekStartDate;
  late DateTime _weekEndDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = getMondayOfWeek(widget.currentDate);
    _calculateWeekDates();
  }

  void _calculateWeekDates() {
    // Calculate the start of the week (Monday)
    _weekStartDate = _selectedDate.subtract(
      Duration(days: _selectedDate.weekday - 1),
    );
    // Calculate the end of the week (Sunday)
    _weekEndDate = _weekStartDate.add(const Duration(days: 6));
  }

  void _navigateToWeek(int direction) {
    setState(() {
      // Navigate to previous week (-1) or next week (1)
      _selectedDate = _selectedDate.add(Duration(days: 7 * direction));
      _calculateWeekDates();
      widget.onWeekChanged(_selectedDate);
    });
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
              onSurface: Colors.white,
              secondary: Color(0xFFFF6B6B),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Color(0xFF556E59)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calculateWeekDates();
        widget.onWeekChanged(_selectedDate);
      });
    }
  }

  DateTime getMondayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 18),
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFB7CA79),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Week header with navigation buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF001A33),
                  ),
                  onPressed: () => _navigateToWeek(-1),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Row(
                    children: [
                      Text(
                        '${_getMonthName(_weekStartDate.month)} ${_weekStartDate.day} - ${_getMonthName(_weekEndDate.month)} ${_weekEndDate.day}',
                        style: const TextStyle(
                          color: Color(0xFF001A33),
                          fontFamily: 'Kanit',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF001A33),
                  ),
                  onPressed: () => _navigateToWeek(1),
                ),
              ],
            ),
          ),
          // Week date timeline - Using Padding and Align instead of Center with mainAxisAlignment
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //     child: LayoutBuilder(
          //       builder: (context, constraints) {
          //         return Align(
          //           alignment: Alignment.center,
          //           child: SizedBox(
          //             // Set a fixed width to center the timeline if needed
          //             width: constraints.maxWidth,
          //             child:
                       EasyDateTimeLine(
                        key: ValueKey('week-${_weekStartDate.toString()}'),
                        initialDate: _selectedDate,
                        activeColor: const Color(0xFF556E59),
                        headerProps: const EasyHeaderProps(showHeader: false),
                        dayProps: EasyDayProps(
                          width: 45,
                          height: 80,
                          
                          activeDayStrStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontSize: 14,
                          ),
                          activeDayNumStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Kanit',
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          inactiveDayStrStyle: const TextStyle(
                            color: Color(0xFF001A33),
                            fontFamily: 'Kanit',
                            fontSize: 14,
                          ),
                          inactiveDayNumStyle: const TextStyle(
                            color: Color(0xFF001A33),
                            fontFamily: 'Kanit',
                            fontSize: 18,
                          ),
                          inactiveDayStyle: DayStyle(
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(100)),
                              border: Border.fromBorderSide(
                                BorderSide(color: Colors.transparent),
                              ),
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
                            widget.onWeekChanged(selectedDate);
                          });
                        },
                      ),
        ]
                    ),
                  );
                }
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
// }

class BottomSection extends StatelessWidget {
  final String randomQuote;
  final DateTime weekStartDate;

  const BottomSection({
    super.key,
    required this.randomQuote,
    required this.weekStartDate,
  });

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
          // Pass the week start date to MoodStatsCard
          MoodStatsCard(startOfWeek: weekStartDate),
          const SizedBox(height: 20),
          QuoteCard(randomQuote: randomQuote),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class MoodStatsCard extends StatefulWidget {
  final DateTime startOfWeek; // Add parameter to receive start of week

  const MoodStatsCard({super.key, required this.startOfWeek});

  @override
  State<MoodStatsCard> createState() => _MoodStatsCardState();
}

class _MoodStatsCardState extends State<MoodStatsCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _weekRank = [];
  bool _isLoading = true;
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;

  @override
  void initState() {
    super.initState();
    _startOfWeek = widget.startOfWeek;
    _endOfWeek = _startOfWeek.add(
      Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    _loadWeekStats();
  }

  @override
  void didUpdateWidget(MoodStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startOfWeek != widget.startOfWeek) {
      _startOfWeek = widget.startOfWeek;
      _endOfWeek = _startOfWeek.add(
        Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );
      _loadWeekStats();
    }
  }

  Future<void> _loadWeekStats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get messages for this week using the passed in start date
      final messages = await _dbHelper.getMessagesBetween(
        _startOfWeek,
        _endOfWeek,
      );

      // Count emoji usage
      Map<String, int> emojiCounts = {};

      for (var message in messages) {
        String emoji = message['emoji_path'] ?? 'unknown';
        emojiCounts[emoji] = (emojiCounts[emoji] ?? 0) + 1;
      }

      // Convert to ranking format
      List<Map<String, dynamic>> rankData = [];

      emojiCounts.forEach((emoji, count) {
        String mood = _getMoodName(emoji);

        rankData.add({
          'emoji': emoji,
          'mood': mood,
          'count': count,
          'percentage':
              messages.isEmpty
                  ? 0.0
                  : (count / messages.length * 100).toStringAsFixed(1),
        });
      });

      // Sort ranking
      rankData.sort((a, b) => b['count'].compareTo(a['count']));

      // Add rank numbers
      for (int i = 0; i < rankData.length; i++) {
        rankData[i]['rank'] = i + 1;
      }

      // Keep only top 5
      if (rankData.length > 3) {
        rankData = rankData.sublist(0, 3);
      }

      setState(() {
        _weekRank = rankData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading week stats: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getMoodName(String emoji) {
    if (emoji.contains('Happy')) return 'Happy';
    if (emoji.contains('sad')) return 'Sad';
    if (emoji.contains('angry')) return 'Angry';
    if (emoji.contains('nervous')) return 'Nervous';
    if (emoji.contains('focus')) return 'Focus';
    if (emoji.contains('normal')) return 'Normal';
    return 'Unknown';
  }

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
      case 'Normal':
        return Colors.blue.shade200;
      default:
        return Colors.grey;
    }
  }

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
          Text(
            'Week Rank',
            style: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 22,
              color: Color(0xFF001A33),
            ),
          ),
          const SizedBox(height: 10),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _weekRank.isEmpty
              ? Center(
                child: Container(
                  height: 150, // Reduced from 200 to 150
                  alignment: Alignment.center,
                  child: const Text(
                    'No mood data available for this week',
                    style: TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rank List Container
                  Expanded(
                    child: Container(
                      height: 150, // Reduced from 200 to 150
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:
                            _weekRank
                                .map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5.0,
                                      horizontal: 1.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${item['rank']}.',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        const SizedBox(width: 5),
                                        Image.asset(
                                          item['emoji'],
                                          width: 30,
                                          height: 30,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          item['mood'],
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Bar Chart Container
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:
                          _weekRank.take(3).map<Widget>((item) {
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
                                        height: 150, 
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 60,
                                          height:
                                              double.parse(
                                                item['percentage'].toString(),
                                              ) *
                                              1.55, 
                                          decoration: BoxDecoration(
                                            color: _getMoodColor(item['mood']),
                                          ),
                                        ),
                                      ),

                                      Positioned(
                                        bottom:
                                            double.parse(
                                              item['percentage'].toString(),
                                            ) *
                                            1.6, 
                                        child: Image.asset(
                                          item['emoji'],
                                          width: 60, 
                                          height: 60, 
                                        ),
                                      ),

                                      Positioned(
                                        bottom:
                                            2,
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
  const QuoteCard({super.key, required this.randomQuote});

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