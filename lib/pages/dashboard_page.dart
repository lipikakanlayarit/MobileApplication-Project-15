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
            margin: EdgeInsets.only(top: 20.0),
            child: Text(
              "Dashboard",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFDF2D2),
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

class HeaderSection extends StatelessWidget {
  final DateTime currentDate;
  const HeaderSection({required this.currentDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(18),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFB7CA79),
        borderRadius: BorderRadius.circular(20),
      ),
      child: EasyDateTimeLine(
        initialDate: currentDate,
        headerProps: const EasyHeaderProps(
          monthPickerType: MonthPickerType.dropDown,
          monthStyle: TextStyle(
            color: Color(0xFF001A33),
            fontFamily: 'Kanit',
            fontSize: 16,
          ),
        ),
        dayProps: EasyDayProps(
                  width: 55,
                  height: 105,
                  dayStructure: DayStructure.dayStrDayNum,
                  activeDayStyle: const DayStyle(
                    decoration: BoxDecoration(
                      color: Color(0xFF556E59),
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
      dayNumStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    dayStrStyle: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Kanit',
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  inactiveDayStyle: const DayStyle(
                    decoration: BoxDecoration(),
                    dayNumStyle: TextStyle(
                      color: Color(0xFF001A33),
                      fontSize: 20,
                      fontFamily: 'Kanit',
                    ),
                    dayStrStyle: TextStyle(
                      color: Color(0xFF001A33),
                      fontSize: 20,
                      fontFamily: 'Kanit',
                    ),
                  ),
                    todayStyle: const DayStyle(
                    decoration: BoxDecoration(
                      border: Border.fromBorderSide(
                        BorderSide(color: Color.fromRGBO(183, 202, 121, 1), width: 2),
                    ),
               ),
           ),
        ),
      ),
   );
  }
}

class BottomSection extends StatelessWidget {
  final List<Map<String, dynamic>> weekRank;
  final String randomQuote;

  const BottomSection({required this.weekRank, required this.randomQuote});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
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
        return Color.fromRGBO(249, 221, 138, 1);
      case 'Nervous':
        return Color.fromRGBO(224, 223, 218, 1);
      case 'Happy':
        return Color.fromRGBO(171, 120, 103, 1);
      case 'Angry':
        return Colors.red;
      case 'Focus':
        return Colors.green;
      default:
        return Colors.grey;

    }
  }
    MoodStatsCard({required this.weekRank});

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
              color:  Color(0xFF001A33),
            ),
          ),
          const SizedBox(height: 5),
          // weekrank list 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Rank List Container
                      Expanded(
                        child: Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: weekRank.map((item) => Container(
                              margin: const EdgeInsets.all(5),
                              child: Row(
                                children: [
                                  Text('${item['rank']}.'),
                                  const SizedBox(width: 5),
                                  Image.asset(item['emoji'], width: 30, height: 30),
                                  const SizedBox(width: 5),
                                  Text(item['mood']),
                                ],
                              ),
                            )).toList(),
                          ),
                        ),
                      ),


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
                                // width: 60,
                                height: item['percentage'] * 1.55, 
                                decoration: BoxDecoration(
                                  color: _getMoodColor(item['mood']),
                                  borderRadius: BorderRadius.circular(0),
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
                              bottom: item['percentage'] * 1.2 , 
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
                color:  Color(0xFF001A33),
              ),
            ),
            const SizedBox(height: 8),
            Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          width: 150,
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
                                color:  Color(0xFF001A33),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                 ],
                ),
              ],
            ),
          );
         }
       }