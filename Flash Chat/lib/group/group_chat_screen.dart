import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/screens/users_display_screen.dart';
import 'package:flutterchat/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../utils/chat_bubble.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupName;
  final String senderName;
  final String senderUid;
  final String groupTitle;
  final Map<String, dynamic> currUserMap;
  final TextEditingController controller;

  GroupChatScreen({required this.groupName, required this.senderName, required this.senderUid, required this.groupTitle, required this.currUserMap, required this.controller});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController controller = TextEditingController();
  late String message;

  late bool isMe = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onPress () {
    controller.clear();
    FirebaseFirestore.instance.collection('messages').doc(widget.groupName).collection('message').add({
      'text': message,
      'email' : FirebaseAuth.instance.currentUser?.email,
      'senderName': widget.senderName,
      'sender': widget.senderUid,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: Text(widget.groupName,style: GoogleFonts.alexandria(),),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>UserDsiplayScreen(groupTile: widget.groupTitle, currUserMap: widget.currUserMap)));
                },
                child: Icon(
                    Icons.person
                ),
              )
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 25,178,238),
                Color.fromARGB(255, 21,236,229)
              ],),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection('messages').doc(widget.groupName).collection('message').orderBy('timestamp').snapshots(),
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
                List<Widget> messageWidget = [];
                var messages = snapshot.data?.docs.reversed;
                for (var message in messages!) {
                  isMe = (message['email'] == FirebaseAuth.instance.currentUser?.email);
                  messageWidget.add(
                    ChatBubble(
                      text: message['text'],
                      sender: isMe?"You":message['senderName'],
                      checkSender: isMe,
                    ),
                  );
                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    children: messageWidget,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: onPress,
                    child: Text(
                      'Send',
                      style: GoogleFonts.alexandria(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

