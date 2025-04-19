import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_project/models/db_helper.dart';


class ChatPage extends StatefulWidget {
  final int userId; 
  final VoidCallback? onMessageSent;

  const ChatPage({super.key, required this.userId, this.onMessageSent});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _isLoading = true;
  TextEditingController _controller = TextEditingController();
  String _selectedEmoji = 'assets/images/Happy-01.png'; 
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
    _dbHelper.archiveAndClearOldMessages();
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

Future<void> _deleteMessage(int index, int messageId) async {
  // First check if the widget is still mounted
  if (!mounted) return;
  
  try {
    // Optimistically update UI first
    final deletedMessage = _messages[index];
    setState(() {
      _messages.removeAt(index);
    });
    
    // Then perform database operation
    await _dbHelper.deleteMessage(messageId);
    
    // Only call refresh if still mounted
    if (mounted && widget.onMessageSent != null) {
      widget.onMessageSent!();
    }
  } catch (e) {
    print('Error deleting message: $e');
    
    // Only update UI if still mounted
    if (mounted) {
      // Put the message back on error
      setState(() {
        
      });
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting message. Please try again.'))
      );
    }
  }
}

Future<void> _clearAllMessages() async {
  // Check if the widget is still mounted
  if (!mounted) return;
  
  // Keep a backup of messages in case of error
  final backupMessages = List<Map<String, dynamic>>.from(_messages);
  
  try {
    // Optimistically update UI
    setState(() {
      _messages.clear();
    });
    
    // Then perform database operation
    await _dbHelper.clearAllMessages();
    
    // Only trigger refresh if still mounted
    if (mounted && widget.onMessageSent != null) {
      widget.onMessageSent!();
    }
  } catch (e) {
    print('Error clearing messages: $e');
    
    // Only update UI if still mounted
    if (mounted) {
      // Restore messages on error
      setState(() {
        _messages = backupMessages;
      });
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error clearing messages. Please try again.'))
      );
    }
  }
}

  Future<void> _loadMessages() async {
  setState(() {
    _isLoading = true;
  });

  try {
    // Get only today's messages
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();
    final tomorrow = DateTime(now.year, now.month, now.day + 1).toIso8601String();
    
    final db = await _dbHelper.database;
    final messages = await db.query(
      'messages',
      where: "timestamp >= ? AND timestamp < ?",
      whereArgs: [today, tomorrow],
      orderBy: 'timestamp ASC'
    );
    
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

  void _triggerRefresh() {
    print("Triggering HomePage refresh"); // Debug print
    if (widget.onMessageSent != null) {
      widget.onMessageSent!();
    }  
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

            _triggerRefresh();

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
        backgroundColor: const Color(0xFFB7CA79),
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
                              child: Text('Cancel',
                                  style: TextStyle(
                                    color: Color (0xFF5E8B84),
                                  ),
                                ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete',
                                  style: TextStyle(
                                    color: Color(0xFFBE4839),
                                  ),
                              ),
                            ),
                          ],
                        ),
                  ) ??
                  false;

              if (confirm) {
                try {
                  await _dbHelper.clearAllMessages();
                  setState(() {
                    _messages.clear();
                  });
                  // Make sure to trigger refresh AFTER the database operation completes
                  _triggerRefresh();
                } catch (e) {
                  print("Error clearing messages: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error clearing chat history'))
                  );
                }
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
                                bool isUserMessage = message['is_user_message'] == 'true';

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
                                                          child: Text('Cancel',
                                                              style: TextStyle(
                                                                color: Color(0xFF5E8B84),
                                                              ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            try {
                                                              if (message['id'] != null) {
                                                                int messageId = int.parse(
                                                                  message['id'].toString(),
                                                                );
                                                                
                                                                // Delete from database
                                                                await _dbHelper.deleteMessage(messageId);
                                                                
                                                                // Remove from local list
                                                                setState(() {
                                                                  _messages.removeAt(index);
                                                                });
                                                                
                                                                // Trigger refresh AFTER deletion is complete
                                                                _triggerRefresh();
                                                                
                                                                Navigator.pop(context);
                                                              }
                                                            } catch (e) {
                                                              print("Error deleting message: $e");
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(content: Text('Error deleting message'))
                                                              );
                                                              Navigator.pop(context);
                                                            }
                                                          },
                                                          child: Text('Delete',
                                                              style: TextStyle(
                                                                color: Color(0xFFBE4839),
                                                              ),
                                                          ),
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