import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:zchat/api/apis.dart';
import 'package:zchat/auth/login_screen.dart';
import 'package:zchat/main.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/screens/profile_screen.dart';
import 'package:zchat/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> list = [];
  List<ChatUser> searchList = [];
  bool isSearching = false;

  @override
  void initState() {
    // TODO: implement setState
    super.initState();
    Apis.getSelfInfo();

    // for setting user active status to active
    Apis.updateActiveStatus(true);

    // for updating user active status according to lifecycle events
    // resume --- active or online
    // pause --- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {

      if(Apis.auth.currentUser != null){
        if (message.toString().contains('pause')) {
        Apis.updateActiveStatus(false);
      }
      if (message.toString().contains('resume')) {
        Apis.updateActiveStatus(true);
      }
      }
      
      return Future.value(message);
    });
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard when a tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        // if seach in on and back button is pressed then close search
        // or else somple close current screen on back button
        onWillPop: () {
          if (isSearching) {
            setState(() {
              isSearching = false;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: isSearching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Name, Email, ...",
                    ),
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                    // when search text changes then upload updated search list
                    onChanged: (value) {
                      //search logic
                      searchList.clear();
                      for (var i in list) {
                        if (i.name
                                .toLowerCase()
                                .contains(value.toLowerCase()) ||
                            i.email
                                .toLowerCase()
                                .contains(value.toLowerCase())) {
                          searchList.add(i);
                        }
                        setState(() {
                          searchList;
                        });
                      }
                    },
                  )
                : Text("Z-Chat"),
            leading: Icon(CupertinoIcons.home),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      isSearching = !isSearching;
                    });
                  },
                  icon: Icon(isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search)),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: Apis.self)));
                  },
                  icon: const Icon(Icons.more_vert)),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async {
                await Apis.auth.signOut();
                await GoogleSignIn().signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginScreen()));
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),
          body: StreamBuilder(
            stream: Apis.getAllusers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                // if data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(
                    child: CircularProgressIndicator(),
                  );

                // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;

                  list =
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount:
                            isSearching ? searchList.length : list.length,
                        padding: EdgeInsets.only(top: mq.height * .01),
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                            user: isSearching ? searchList[index] : list[index],
                          );
                        });
                  } else {
                    return const Center(
                      child: Text(
                        "No Connections Found",
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
