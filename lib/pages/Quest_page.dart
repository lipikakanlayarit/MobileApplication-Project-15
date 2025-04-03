import 'package:flutter/material.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  final ChecklistManager checklistManager = ChecklistManager();
  double progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 184, 220, 116),
        child: Column(
          children: [
            _buildTopSection(),
            Expanded(child: _buildChecklistSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    String backgroundImage = 'assets/images/QuestBackground-02-01.png';
    if (checklistManager.stage == 3) {
      backgroundImage = 'assets/images/QuestBackground-04-01.png';
    } else if (checklistManager.stage == 2) {
      backgroundImage = 'assets/images/QuestBackground-03-01.png';
    }

    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 380,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 20, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 232, 172).withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "🔥: ${checklistManager.loopCount}",
              style: const TextStyle(
                color: Color.fromARGB(255, 79, 43, 0),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: _buildProgressBar(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 320, 20, 0),
      child: Container(
        width: 270,
        height: 15,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 91, 91, 91),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 270 * progress,
              height: 15,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 253, 242, 210),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: ListView(
        children: checklistManager.checklist.keys.map((title) {
          return Transform.translate(
            offset: const Offset(0, -30),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CheckboxTile(
                title: title,
                isChecked: checklistManager.checklist[title]!,

                // Update progress when tapped
                onTap: () {
                  setState(() {
                    checklistManager.toggleItem(title);
                    progress = checklistManager.getProgress();

                    // Check if all tasks are done (progress is 100%)
                    if (progress == 1.0) {
                      _showCongratulationsDialog(); // Show dialog when progress is 100%
                    }
                  });
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Show congratulatory dialog when progress is 100%
  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed this stage!'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Reset progress and move to next stage
                  progress = 0.0;
                  checklistManager.nextStage();
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Thank!'),
            ),
          ],
        );
      },
    );
  }
}

class ChecklistManager {
  int stage = 1;
  int loopCount = 0;
  Map<String, bool> checklist = {};

  ChecklistManager() {
    _resetChecklist();
  }

  void toggleItem(String title) {
    checklist[title] = !checklist[title]!;
  }

  double getProgress() {
    return checklist.values.where((val) => val).length / checklist.length;
  }

  void nextStage() {
    if (stage == 3) {
      loopCount++;
      stage = 1;
    } else {
      stage++;
    }
    _resetChecklist();
  }

  void _resetChecklist() {
    if (stage == 1) {
      checklist = {
        'Did you remind yourself that you matter?': false,
        'Did you drink enough water today?': false,
        'Where do you see yourself in five years?': false,
      };
    } else if (stage == 2) {
      checklist = {
        'Did you practice deep breathing today?': false,
        'Did you take a short break from your screen?': false,
        'Did you get enough sleep last night?': false,
      };
    } else {
      checklist = {
        'Did you reflect on something positive today?': false,
        'Did you move your body for at least 5 minutes?': false,
        'Did you spend some time in nature?': false,
      };
    }
  }
}

class CheckboxTile extends StatelessWidget {
  final String title;
  final bool isChecked;
  final VoidCallback onTap;

  const CheckboxTile({
    required this.title,
    required this.isChecked,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: isChecked ?   Color.fromARGB(255, 184, 220, 116) : Colors.brown,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildCheckbox(),
            const SizedBox(width: 25),
            Expanded(child: Text(
              title, 
              style: TextStyle(
                color: isChecked ? Colors.black : Colors.white,
                fontSize: 18,))),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
  return Icon(
    isChecked ? Icons.check_rounded : Icons.check_box_outline_blank,
    color: isChecked ? Colors.green : const Color.fromARGB(255, 255, 255, 255),
    size: 35, 
    );
  }

}
