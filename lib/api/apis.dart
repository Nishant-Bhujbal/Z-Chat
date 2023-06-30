import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:zchat/model/chat_user.dart';
import 'package:zchat/model/message.dart';

class Apis {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud firestore database
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for saving self information
  static late ChatUser self;

  // to return current user
  static User? get user => auth.currentUser;

  // for accesing firebase messaging (Push Notification)
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fmessaging.requestPermission();

    fmessaging.getToken().then((value) {
      if (value != null) {
        self.pushToken = value;
        print(" this is push token babay ${value}");
      }
    });

    // for handling foreground notification
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notifications
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": self.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {
          "some_data": "User ID : ${self.id}",
        },
      };
      var response =
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAAHl-cXB4:APA91bFgc5fU_0OCemA_PNsdgyS3NNCanV81nxpeyXPrBJiPJ-eBqj2zvw4wWuzYcWNs3kwYnepZLRx6u5YvK8A37cQRwQbR7hYF6eqYzr9CLMYbeSOaXsZknRXOvef-0a5d5ApW0QaK'
              },
              body: jsonEncode(body));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
    } catch (e) {
      print("\n bro this is error : $e");
    }
  }

  // for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection("users")
        .where('email', isEqualTo: email)
        .get();

    if (data.docs.isNotEmpty && data.docs.first.id != user!.uid) {
      // user exists
      print('Users exists : ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user!.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      // user dont exists
      return false;
    }
  }

  // for getting current user information
  // for getting all users from firestore database
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((value) async {
      if (value.exists) {
        self = ChatUser.fromJson(value.data()!);
        await getFirebaseMessagingToken();

        // for setting user active status to active
        Apis.updateActiveStatus(true);
      } else {
        log("current user is null");
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatuser = ChatUser(
        image: user!.photoURL.toString(),
        name: user!.displayName.toString(),
        createdAt: 'time',
        lastActive: 'time',
        isOnline: false,
        id: user!.uid,
        email: user!.email.toString(),
        pushToken: '',
        about: "Hey Im using Z-chat");

    return await firestore
        .collection("users")
        .doc(user!.uid)
        .set(chatuser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllusers(List<String> userIds) {
    return Apis.firestore
        .collection('users')
        .where('id', whereIn: userIds )
        .snapshots();
  }


    // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user!.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }


  // for getting ids known to users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return Apis.firestore
        .collection('users')
        .doc(user!.uid)
        .collection('my_users')
        .snapshots();
  }

  // for updating user info of name and about from profiel_picture
  static Future<void> UpdateUserInfor() async {
    await firestore
        .collection("users")
        .doc(user!.uid)
        .update({'name': self.name, 'about': self.about});
  }

  // for getting specific user info
  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active stautus of users
  static Future<void> updateActiveStatus(bool isOnline) async {
    Apis.firestore.collection('users').doc(user!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': self.pushToken
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    // getting file extension
    final ext = file.path.split('.').last;
    print("Extension $ext");

    // storage file with path
    final ref = storage.ref().child('profile_Pictures/${user?.uid}');

    // uploading image in firebase storage
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('data tranferred : ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in firestore database
    self.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user?.uid)
        .update({'image': self.image});
  }

  /// ************************* Chat Screen Related APIs **********************

  // chats (collection) --> conversation_id(doc) --> messages(collection) --> message(doc)

  //useful for getting conversation id
  static String getConversation(String id) => user!.uid.hashCode <= id.hashCode
      ? '${user!.uid}_$id'
      : '${id}_${user!.uid}';

  // for gettinf all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllmessages(
      ChatUser user) {
    return Apis.firestore
        .collection('chats/${getConversation(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    // message to send
    final Message message = Message(
        msg: msg,
        read: '',
        told: chatUser.id,
        type: type,
        fromId: user!.uid,
        sent: time);

    final ref =
        firestore.collection('chats/${getConversation(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  // update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversation(message.fromId)}/messages/')
        .doc(message.sent)
        .update({
      'read': DateTime.now().millisecondsSinceEpoch.toString(),
    });
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastmessages(
      ChatUser user) {
    return Apis.firestore
        .collection('chats/${getConversation(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    // getting file extension
    final ext = file.path.split('.').last;

    // storage file with path
    final ref = storage.ref().child(
        'Images/${getConversation(chatUser.id)}/${DateTime.now().microsecondsSinceEpoch}.$ext');

    // uploading image in firebase storage
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('data tranferred : ${p0.bytesTransferred / 1000} kb');
    });

    // updating image in firestore database
    final imageurl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageurl, Type.image);
  }

  // delete chat messages
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversation(message.told)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversation(message.told)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }
}
