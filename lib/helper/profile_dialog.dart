import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zchat/main.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(children: [
          // user profile picture
          Align(
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .25),
              child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: mq.width * .5,
                  height: mq.height * .25,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(Icons.person),
                      )),
            ),
          ),

          // user name
          Positioned(
            left: mq.width * .04,
            top: mq.height * .02,
            width: mq.width * .55,
            child: Text(
              user.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),

          // user info button
          Positioned(
              right: 8,
              top: 4,
              child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(user: user)));
                  },
                  shape: CircleBorder(),
                  minWidth: 0,
                  padding: EdgeInsets.all(0),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 30,
                  )))
        ]),
      ),
    );
  }
}
