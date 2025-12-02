import 'package:flutter/material.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'call_screen.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  final int otherUserId;
  final String otherUserName;

  const ChatScreen({super.key, required this.otherUserId, required this.otherUserName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<ChatMessage> _messages = [];
  ChatUser? _currentUser;
  ChatUser? _otherUser;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getInt('user_id');
    
    setState(() {
      _currentUser = ChatUser(id: myId.toString(), firstName: "Me");
      _otherUser = ChatUser(id: widget.otherUserId.toString(), firstName: widget.otherUserName);
    });

    _listenToMessages();
  }

  void _listenToMessages() {
    _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .listen((List<Map<String, dynamic>> data) {
          if (!mounted) return;
          
          // Filter messages between ME and THEM
          final filtered = data.where((m) => 
            (m['sender_id'].toString() == _currentUser!.id && m['receiver_id'].toString() == _otherUser!.id) ||
            (m['sender_id'].toString() == _otherUser!.id && m['receiver_id'].toString() == _currentUser!.id)
          ).toList();

          setState(() {
            _messages = filtered.map((m) {
              return ChatMessage(
                text: m['content'],
                user: m['sender_id'].toString() == _currentUser!.id ? _currentUser! : _otherUser!,
                createdAt: DateTime.parse(m['created_at']),
              );
            }).toList().reversed.toList(); // DashChat needs reversed list
          });
    });
  }

  void _sendMessage(ChatMessage message) async {
    // Optimistic Update
    setState(() {
      _messages.insert(0, message);
    });

    await _supabase.from('messages').insert({
      'content': message.text,
      'sender_id': int.parse(_currentUser!.id),
      'receiver_id': int.parse(_otherUser!.id),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName, style: const TextStyle(color: Colors.black, fontSize: 16)),
                const Text("Online", style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // --- NEW VIDEO CALL LOGIC HERE ---
          IconButton(
            icon: const Icon(Icons.videocam, color: Colors.blue), 
            onPressed: () {
              // Generate a unique channel ID based on User IDs (Smallest ID first)
              // This ensures both users join "chat_1_5" instead of "chat_5_1"
              final myId = int.parse(_currentUser!.id);
              final otherId = int.parse(_otherUser!.id);
              final channelId = myId < otherId ? "call_${myId}_$otherId" : "call_${otherId}_$myId";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CallScreen(channelName: channelId),
                ),
              );
            }
          ),
          // ---------------------------------
          IconButton(icon: const Icon(Icons.call, color: Colors.green), onPressed: () {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice Call starting...")));
          }),
        ],
      ),
      body: DashChat(
        currentUser: _currentUser!,
        onSend: _sendMessage,
        messages: _messages,
        inputOptions: const InputOptions(
          alwaysShowSend: true,
          sendOnEnter: true,
          inputDecoration: InputDecoration(
            hintText: "Type a message...",
            border: InputBorder.none,
            filled: true,
            fillColor: Color(0xFFF5F5F5),
          )
        ),
      ),
    );
  }
}