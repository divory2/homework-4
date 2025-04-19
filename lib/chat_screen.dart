import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  late final types.User _user;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final firebaseUser = _auth.currentUser!;
    _user = types.User(
      id: firebaseUser.uid,
      firstName: firebaseUser.email?.split('@')[0],
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    await FirebaseFirestore.instance.collection('messages').add({
      'text': message.text,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'userId': _user.id,
      'userEmail': _auth.currentUser?.email,
    });
  }

  List<types.Message> _transformMessages(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return types.TextMessage(
        id: doc.id,
        author: types.User(id: data['userId'] ?? 'unknown'),
        createdAt: data['createdAt'],
        text: data['text'] ?? '',
      );
    }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final messages = _transformMessages(snapshot.data!);

          return Chat(
            messages: messages,
            onSendPressed: _handleSendPressed,
            user: _user,
          );
        },
      ),
    );
  }
}
