import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zchat/helper/my_date_util.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/model/message.dart';
import 'package:zchat/screens/view_profile_screen.dart';
import 'package:zchat/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> list = [];

  // for handling message text changes
  final textController = TextEditingController();

  // _showEmoji = for storing value of showing or hiding emoji
  // _isuploading = for checking if image is uploading or not
  bool _showEmoji = false, _isuploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emojis are shown and back button is pressed then hide emoji
          // or else simple close current screen back button click
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            // appbar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: appbar(),
            ),

            backgroundColor: Colors.blue[50],

            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: Apis.getAllmessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        // if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();

                        // if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;

                          list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: list.length,
                                padding: EdgeInsets.only(top: mq.height * .01),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: list[index],
                                  );
                                });
                          } else {
                            return const Center(
                              child: Text(
                                "Say Hi !! 👋",
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  ),
                ),

                // progress indicator for showing uploading of image in chat
                if (_isuploading)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),

                // chat input field
                chatinput(),

                // show emojis on keyboard emoji button click and vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: textController,
                      config: Config(
                        bgColor: Color.fromARGB(255, 214, 236, 250),
                        columns: 7,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appbar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: Apis.getAllusers(),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                // backbutton
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    )),

                // user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .25),
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                      height: mq.height * .05,
                      width: mq.height * .05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                            child: Icon(Icons.person),
                          )),
                ),

                SizedBox(
                  width: 10,
                ),

                // user name and last seen time
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // user name
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold),
                    ),

                    // for adding some space
                    const SizedBox(
                      height: 2,
                    ),

                    // last seen time of user
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActiveTime: list[0].lastActive)
                          : widget.user.lastActive,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ));
  }

  Widget chatinput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(children: [
        Expanded(
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Row(
              children: [
                // emoji button
                IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.blue,
                      size: 26,
                    )),

                Expanded(
                    child: TextField(
                  controller: textController,
                  onTap: () {
                    if (_showEmoji) {
                      setState(() {
                        _showEmoji = !_showEmoji;
                      });
                    }
                  },
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Type something",
                      hintStyle: TextStyle(
                        color: Colors.blueAccent,
                      )),
                )),

                // pick image from gallery
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // picking multiple images
                      final List<XFile> images = await picker.pickMultiImage();

                      //uploading and sending image one by one
                      for (var i in images) {
                        setState(() => _isuploading = true);
                        Apis.sendChatImage(widget.user, File(i.path));
                        setState(() => _isuploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.image,
                      color: Colors.blue,
                      size: 26,
                    )),

                // take image from camera button
                IconButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        setState(() => _isuploading = true);
                        Apis.sendChatImage(widget.user, File(image.path));
                        setState(() => _isuploading = false);
                      }
                    },
                    icon: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blue,
                      size: 26,
                    ))
              ],
            ),
          ),
        ),

        // send material button
        MaterialButton(
          onPressed: () {
            if (textController.text.isNotEmpty) {
              Apis.sendMessage(widget.user, textController.text, Type.text);
              textController.text = '';
            }
          },
          minWidth: 0,
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          shape: const CircleBorder(),
          color: Colors.green,
          child: const Icon(
            Icons.send,
            color: Colors.white,
            size: 28,
          ),
        ),
      ]),
    );
  }
}
