import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zchat/api/apis.dart';
import 'package:zchat/auth/login_screen.dart';
import 'package:zchat/helper/dialogs.dart';
import 'package:zchat/helper/my_date_util.dart';
import 'package:zchat/main.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/widgets/chat_user_card.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // to hode the keyboard when touched anywhere
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: mq.height * .03,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      height: mq.height * .2,
                      width: mq.height * .2,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                            child: Icon(Icons.person),
                          )),
                ),
                SizedBox(
                  height: mq.height * .03,
                ),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: mq.height * .05,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('About : ' , style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),) ,

                    Text(
                      widget.user.about,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Joined on : ' , style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),) ,

                    Text(
                      MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
