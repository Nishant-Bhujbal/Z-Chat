import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zchat/main.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/screens/chat_screen.dart';

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
        onTap: () {
          // for navigating to chat screen
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => ChatScreen(user: widget.user,)));
        },
        child: ListTile(
          //user name
          title: Text(widget.user.name),

          //last message
          subtitle: Text(widget.user.about),

          //user profile picture
          // leading: const CircleAvatar(child: Icon(Icons.person),),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .25),
            child: CachedNetworkImage(
                height: mq.height * .055,
                width: mq.height * .055,
                imageUrl: widget.user.image,
                // placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(Icons.person),
                    )),
          ),

          // last  message time
          // trailing: Text(
          //   "12:00 pm",
          //   style: TextStyle(color: Colors.black54),
          // ),

          trailing: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: Colors.green),
          ),
        ),
      ),
    );
  }
}
