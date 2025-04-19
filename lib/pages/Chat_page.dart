import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/models/db_helper.dart';

class ChatPage extends StatefulWidget {
  final int userId; // Required parameter
  final VoidCallback? onMessageSent;

  const ChatPage({super.key, required this.userId, this.onMessageSent});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  TextEditingController _controller = TextEditingController();
  String _selectedEmoji = 'assets/images/Happy-01.png'; // Default emoji
  bool _isEmojiPickerVisible = false;
  final ScrollController _scrollController = ScrollController();

  // List of emojis to display
  List<String> emojiPaths = [
    'assets/images/focus-01.png',
    'assets/images/Happy-01.png',
    'assets/images/normal-01.png',
    'assets/images/nervous-01.png',
    'assets/images/angry-01.png',
    'assets/images/sad-01.png',
  ];

  // List to store chat messages - fixed type to Map<String, dynamic>
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _dbHelper.getMessages();
      setState(() {
        _messages = messages;
      });

      // Scroll to bottom after messages are loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Error loading messages: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  // Fixed _sendMessage with proper database integration and immediate UI update
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final now = DateTime.now();
      final message = {
        'text': _controller.text,
        'emoji_path': _selectedEmoji,
        'timestamp': now.toIso8601String(),
        'is_user_message': 'true',
        'user_id': widget.userId,
      };

      // Save message text before clearing
      final messageText = _controller.text;

      // Clear text field immediately for better UX
      setState(() {
        _controller.clear();
      });

      // Insert into database and update UI
      _dbHelper
          .insertMessage(message)
          .then((id) {
            message['id'] = id;

            setState(() {
              _messages = List<Map<String, dynamic>>.from(_messages)
                ..add(message);
            });

            widget.onMessageSent?.call();

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          })
          .catchError((error) {
            print('Error saving message: $error');
            // Show error to user
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error sending message')));

            // Give back the text if sending failed
            setState(() {
              _controller.text = messageText;
            });
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              // Add confirmation dialog
              bool confirm =
                  await showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: Text('Clear Chat History'),
                          content: Text(
                            'Are you sure you want to delete all messages?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                  ) ??
                  false;

              if (confirm) {
                await _dbHelper.clearAllMessages();
                setState(() {
                  _messages.clear();
                });
              }
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // List of messages (Chat Bubbles)
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? Center(
                              child: Text(
                                'No messages yet. Start a conversation!',
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                var message = _messages[index];
                                bool isUserMessage =
                                    message['is_user_message'] == 'true';

                                // Format timestamp for display
                                String displayTime = '';
                                try {
                                  final timestamp = DateTime.parse(
                                    message['timestamp'] ?? '',
                                  );
                                  displayTime = DateFormat(
                                    'h:mm a',
                                  ).format(timestamp);
                                } catch (e) {
                                  print('Error parsing timestamp: $e');
                                  displayTime = 'Unknown time';
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 12.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        isUserMessage
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            isUserMessage
                                                ? MainAxisAlignment.end
                                                : MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          // Sender's profile emoji (Avatar)
                                          if (!isUserMessage) // For recipient
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                  message['emoji_path'] ??
                                                      _selectedEmoji,
                                                ),
                                                radius: 20,
                                              ),
                                            ),
                                          // Message bubble
                                          GestureDetector(
                                            onLongPress: () {
                                              // Show delete option
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (context) => AlertDialog(
                                                      title: Text(
                                                        'Delete Message',
                                                      ),
                                                      content: Text(
                                                        'Do you want to delete this message?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed:
                                                              () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                  ),
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            // Fixed: properly parse id to int
                                                            if (message['id'] !=
                                                                null) {
                                                              await _dbHelper
                                                                  .deleteMessage(
                                                                    int.parse(
                                                                      message['id']
                                                                          .toString(),
                                                                    ),
                                                                  );
                                                              setState(() {
                                                                _messages
                                                                    .removeAt(
                                                                      index,
                                                                    );
                                                              });
                                                            }
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                          },
                                                          child: Text('Delete'),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(12.0),
                                              constraints: BoxConstraints(
                                                maxWidth:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.7,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    isUserMessage
                                                        ? Color(
                                                          0xFF5E8B84,
                                                        ) // User's message color
                                                        : Colors
                                                            .grey[300], // Other's message color
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      15.0,
                                                    ).copyWith(
                                                      bottomRight:
                                                          isUserMessage
                                                              ? Radius.circular(
                                                                0.0,
                                                              )
                                                              : Radius.circular(
                                                                15.0,
                                                              ),
                                                      bottomLeft:
                                                          !isUserMessage
                                                              ? Radius.circular(
                                                                0.0,
                                                              )
                                                              : Radius.circular(
                                                                15.0,
                                                              ),
                                                    ),
                                              ),
                                              child: Text(
                                                message['text'] ?? '',
                                                style: TextStyle(
                                                  color:
                                                      isUserMessage
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                                softWrap: true,
                                                overflow: TextOverflow.visible,
                                              ),
                                            ),
                                          ),
                                          // User avatar
                                          if (isUserMessage) // For sender
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: AssetImage(
                                                  message['emoji_path'] ??
                                                      _selectedEmoji,
                                                ),
                                                radius: 20,
                                              ),
                                            ),
                                        ],
                                      ),
                                      // Timestamp
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.0,
                                          left: isUserMessage ? 0 : 48.0,
                                          right: isUserMessage ? 48.0 : 0,
                                        ),
                                        child: Text(
                                          displayTime,
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                  // Emoji Picker
                  if (_isEmojiPickerVisible)
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Color.fromARGB(255, 255, 249, 230),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:
                              emojiPaths.map((emoji) {
                                return GestureDetector(
                                  onTap: () => _selectEmoji(emoji),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      emoji,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  // Input area
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleEmojiPicker,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Color(0xFF5E8B84),
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
                            maxLines: null,
                            minLines: 1, // Added to prevent excessive expansion
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
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
