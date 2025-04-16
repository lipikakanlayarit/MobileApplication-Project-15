import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create a singleton instance of ChecklistManager
class ChecklistManager {
  // Singleton pattern
  static final ChecklistManager _instance = ChecklistManager._internal();

  factory ChecklistManager() {
    return _instance;
  }

  ChecklistManager._internal() {
    // Initialize with default values immediately
    _resetChecklist();
  }

  int stage = 1;
  int loopCount = 0;
  Map<String, bool> checklist = {};
  bool isInitialized = false;

  Future<void> initialize() async {
    if (!isInitialized) {
      await loadData();
      isInitialized = true;
    }
  }

  Future<void> loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load stage and loopCount with default values if not found
      stage = prefs.getInt('quest_stage') ?? 1;
      loopCount = prefs.getInt('quest_loop_count') ?? 0;
      
      // Reset checklist based on loaded stage
      _resetChecklist();
      
      // Load individual checklist items
      for (String key in checklist.keys) {
        bool? savedValue = prefs.getBool('quest_item_$key');
        checklist[key] = savedValue ?? false;
      }
      
      // Debug prints
      print('Loaded checklist items: ${checklist.length}');
      checklist.forEach((key, value) {
        print('Item: $key = $value');
      });
      
    } catch (e) {
      print('Error loading data: $e');
      // Continue with default values
    }
  }

  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save stage and loopCount
      await prefs.setInt('quest_stage', stage);
      await prefs.setInt('quest_loop_count', loopCount);
      
      // Save all checklist items
      for (String key in checklist.keys) {
        await prefs.setBool('quest_item_$key', checklist[key]!);
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void toggleItem(String title) {
    if (checklist.containsKey(title)) {
      checklist[title] = !checklist[title]!;
    }
  }

  double getProgress() {
    if (checklist.isEmpty) return 0.0;
    int completed = checklist.values.where((val) => val).length;
    return completed / checklist.length;
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

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  _QuestPageState createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> with WidgetsBindingObserver {
  final ChecklistManager checklistManager = ChecklistManager();
  double progress = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.detached) {
      checklistManager.saveData();
    } else if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!isLoading) {
      _refreshData();
    }
  }

  Future<void> _refreshData() async {
    await checklistManager.loadData();
    
    if (mounted) {
      setState(() {
        progress = checklistManager.getProgress();
      });
    }
  }

  Future<void> _initializeData() async {
    try {
      await checklistManager.initialize();
      
      if (mounted) {
        setState(() {
          progress = checklistManager.getProgress();
          isLoading = false;
        });
      }
      
      // Debug print to check checklist items
      print('After initialization, checklist has ${checklistManager.checklist.length} items');
      
    } catch (e) {
      print('Error initializing data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Get screen size to ensure proper layout
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 184, 220, 116),
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          children: [
            SizedBox(
              height: 380, // Fixed height for top section
              child: _buildTopSection(screenSize),
            ),
            Expanded(
              child: _buildChecklistSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(Size screenSize) {
    String backgroundImage = 'assets/images/QuestBackground-02-01.png';
    if (checklistManager.stage == 3) {
      backgroundImage = 'assets/images/QuestBackground-04-01.png';
    } else if (checklistManager.stage == 2) {
      backgroundImage = 'assets/images/QuestBackground-03-01.png';
    }

    return Stack(
      clipBehavior: Clip.none, //Prevent overflow
      children: [
        Container(
          width: screenSize.width,
          height: 380,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
        top: 40, 
        left: 0,
        right: 0,
        child: Center(
          child: Text(
            "Quest",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF2A442F),
            ),
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
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: _buildProgressBar(screenSize.width),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double screenWidth) {
    // Calculate progress bar width based on screen width
    final progressBarWidth = screenWidth * 0.7; // 70% of screen width
    
    return Center(
      child: Container(
        width: progressBarWidth,
        height: 15,
        decoration: BoxDecoration(
          color: const Color(0xFF5B5B5B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Ensure progress is a valid number between 0 and 1
            if (progress.isFinite && progress >= 0 && progress <= 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: progressBarWidth * progress,
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
    // Debug print to verify checklist content
    print('Building checklist with ${checklistManager.checklist.length} items');
    checklistManager.checklist.forEach((key, value) {
      print('  $key: $value');
    });
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 253, 242, 210),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: checklistManager.checklist.isEmpty
                ? const Center(child: Text("No quests available"))
                : ListView.builder(
                    itemCount: checklistManager.checklist.length,
                    itemBuilder: (context, index) {
                      String title = checklistManager.checklist.keys.elementAt(index);
                      bool isChecked = checklistManager.checklist[title]!;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: CheckboxTile(
                          title: title,
                          isChecked: isChecked,
                          onTap: () async {
                            setState(() {
                              checklistManager.toggleItem(title);
                              progress = checklistManager.getProgress();
                            });
                            
                            await checklistManager.saveData();
                            
                            if (progress == 1.0) {
                              _showCongratulationsDialog();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed this stage!'),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  progress = 0.0;
                  checklistManager.nextStage();
                });
                
                await checklistManager.saveData();
                Navigator.of(context).pop();
              },
              child: const Text('Thank!'),
            ),
          ],
        );
      },
    );
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
        height: 100,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isChecked ?  const Color(0xFFB7CA79) : Colors.brown,
          borderRadius: BorderRadius.circular(12),
          // Add shadow for better visibility
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildCheckbox(),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title, 
                style: TextStyle(
                  color: isChecked ? const Color(0xFF001A33) : const Color(0xFFFDF2D2),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isChecked ? const Color.from(alpha: 1, red: 0.298, green: 0.686, blue: 0.314) : Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isChecked ? Colors.green.shade700 : Colors.white,
          width: 2,
        ),
      ),
      child: isChecked
          ? const Icon(
              Icons.check,
              color: Colors.white,
              size: 20,
            )
          : null,
    );
  }
}