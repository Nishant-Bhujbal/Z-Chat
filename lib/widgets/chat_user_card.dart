import 'package:flutter/material.dart';
import 'package:zchat/main.dart';
import 'package:zchat/model/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 4),
      child: InkWell(
        onTap: () {},
        child: ListTile(
          //user name
          title: Text(widget.user.name),

          //last message
          subtitle: Text(widget.user.about),

          //user profile picture
          leading: CircleAvatar(
            child: Icon(Icons.person),
          ),

          // last  message time
          trailing: Text(
            "12:00 pm",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
