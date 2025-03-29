import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPage> {
  TextEditingController _controller = TextEditingController();
  String _selectedEmoji = 'assets/images/Happy-01.png'; // Default emoji
  bool _isEmojiPickerVisible = false;

  // List of emojis to display
  List<String> emojiPaths = [
    'assets/images/focus-01.png',
    'assets/images/Happy-01.png',
    'assets/images/normal-01.png',
    'assets/images/nervous-01.png',
    'assets/images/angry-01.png',
    'assets/images/sad-01.png',
  ];

  // List to store chat messages
  List<Map<String, String>> _messages = [];

  void _toggleEmojiPicker() {
    setState(() {
      _isEmojiPickerVisible = !_isEmojiPickerVisible;
    });
  }

  void _selectEmoji(String emoji) {
    setState(() {
      _selectedEmoji = emoji;
      _isEmojiPickerVisible = false; // Hide emoji picker after selection
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _controller.text,
          'emoji': _selectedEmoji,
          'isUserMessage': 'true', // Mark as user message
        });
        _controller.clear(); // Clear the text field
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMMMd().format(DateTime.now()),
          style: TextStyle(
            fontFamily: 'kleeOne',
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color.fromRGBO(183, 202, 121, 1),
      ),
      body: Column(
        children: [
          // List of messages (Chat Bubbles)
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                bool isUserMessage = message['isUserMessage'] == 'true';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: isUserMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      // Sender's profile emoji (Avatar)
                      if (!isUserMessage) // For recipient
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(message['emoji']!),
                            radius: 20,
                          ),
                        ),
                      // Message bubble
                      Container(
                        padding: EdgeInsets.all(12.0),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isUserMessage
                              ? Color(0xFF5E8B84) // User's message color
                              : Colors.grey[300], // Other's message color
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15.0),
                            topRight: Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: Radius.circular(0.0),
                          ),
                        ),
                        child: Text(
                          message['text']!,
                          style: TextStyle(
                            color: isUserMessage ? Colors.white : Colors.black,
                          ),
                          softWrap: true, // Automatically wrap text
                          overflow: TextOverflow.visible, // Ensure the text doesn't get cut off
                        ),
                      ),
                      // For sender (show avatar after the bubble)
                      if (isUserMessage) // For sender
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(message['emoji']!),
                            radius: 20,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Emoji Picker (Now placed just above the text input)
          if (_isEmojiPickerVisible)
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: emojiPaths.map((emoji) {
                    return GestureDetector(
                      onTap: () => _selectEmoji(emoji),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(emoji, width: 40, height: 40),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _toggleEmojiPicker,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF5E8B84), // Button background color
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Image.asset(
                      _selectedEmoji,
                      width: 30,
                      height: 30,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null, // Make the TextField multiline
                    keyboardType: TextInputType.multiline, // Ensure multiline keyboard
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}