import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterchat/screens/chat_screen.dart';

class ChatTile extends StatefulWidget {
  final Map<String, dynamic>? receiverUserMap;
  final Map<String, dynamic>? senderUserMap;
  final String chatId;
  final TextEditingController controller;
  bool isSearch;
  final VoidCallback add;
  final bool check;

  ChatTile({super.key, required this.receiverUserMap, required this.senderUserMap, required this.chatId, required this.controller, this.isSearch=false, required this.add, this.check=false});

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  void onLongPress()async{
    FirebaseFirestore.instance.collection('messages').doc(widget.chatId).collection('message');
    await deleteMessages();
  }

  Future<void> deleteMessages() async{
    await FirebaseFirestore.instance.collection('userUI').doc(widget.senderUserMap!['uid']).collection("chats").doc(widget.receiverUserMap!['uid']).delete();
    await FirebaseFirestore.instance.collection('userUI').doc(widget.receiverUserMap!['uid']).collection("chats").doc(widget.senderUserMap!['uid']).delete();

    var collection = FirebaseFirestore.instance.collection('messages').doc(widget.chatId).collection('message');
    var snapshots = await collection.get();

    for(var doc in snapshots.docs){
      await doc.reference.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
      child: MaterialButton(
        onPressed: widget.check?(){

        }:
            (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(widget.controller, widget.receiverUserMap!['Name'], widget.receiverUserMap!['uid'], widget.senderUserMap!['Name'], widget.senderUserMap!['uid'], widget.chatId)));
        },
        onLongPress: onLongPress,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 30,
                child: ClipOval(
                  child: Image.asset(
                    'images/single_user.png',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20,),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiverUserMap!['Name'], style: const TextStyle(fontSize: 20),),
                  Text(widget.receiverUserMap!['Email'], style: const TextStyle(fontSize: 10, color: Colors.grey),)
                ],
              ),
            ),
            const SizedBox(width: 20,),
            widget.isSearch? GestureDetector(onTap: (){
              widget.add();
              setState(() {
                widget.isSearch = false;
              });
            },child: const Icon(Icons.add),):
                    Container(),
          ],
        ),
      ),
    );
  }
}
