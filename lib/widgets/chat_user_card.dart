import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zchat/api/apis.dart';
import 'package:zchat/helper/my_date_util.dart';
import 'package:zchat/helper/profile_dialog.dart';
import 'package:zchat/main.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/model/message.dart';
import 'package:zchat/screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> no msg)
  Message? _message;

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
              context,
              MaterialPageRoute(
                  builder: (_) => ChatScreen(
                        user: widget.user,
                      )));
        },
        child: StreamBuilder(
            stream: Apis.getLastmessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                  //user name
                  title: Text(widget.user.name),

                  //last message
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? "Image"
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),

                  //user profile picture
                  // leading: const CircleAvatar(child: Icon(Icons.person),),
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context, builder: (_) => ProfileDialog(user: widget.user,));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .25),
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                          height: mq.height * .055,
                          width: mq.height * .055,
                          imageUrl: widget.user.image,
                          // placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                child: Icon(Icons.person),
                              )),
                    ),
                  ),

                  // last message time
                  trailing: _message == null
                      ? null // show nothing when no message is sent
                      : _message!.read.isEmpty &&
                              _message!.fromId != Apis.user!.uid
                          ?
                          // show for unread message
                          Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.green),
                            )
                          :
                          // message sent time
                          Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.black54),
                            ));
            }),
      ),
    );
  }
}
