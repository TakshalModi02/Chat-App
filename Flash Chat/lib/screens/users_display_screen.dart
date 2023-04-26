import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/chat_tile.dart';

class UserDsiplayScreen extends StatefulWidget {
  final String groupTile;
  final Map<String, dynamic> currUserMap;
  const UserDsiplayScreen({required this.groupTile, required this.currUserMap});

  @override
  State<UserDsiplayScreen> createState() => _UserDsiplayScreenState();
}

class _UserDsiplayScreenState extends State<UserDsiplayScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String chatId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Members'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('group').doc(widget.groupTile).collection('members').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: LoadingAnimationWidget.discreteCircle(
                color: Colors.blueAccent,
                secondRingColor: Colors.white,
                thirdRingColor: Colors.blueAccent,
                size: 30,
              ),
            );
          }
          var chats = snapshot.data?.docs;
          List<Widget> friends = [];

          for (var chat in chats!) {
            friends.add(
              ChatTile(receiverUserMap: chat.data(), senderUserMap: widget.currUserMap, chatId: chatId(chat['uid'],widget.currUserMap['uid']), controller: _controller, add: (){},));
              }
          return ListView(
            children: friends,
          );
        },
      ),
    );
  }
}
