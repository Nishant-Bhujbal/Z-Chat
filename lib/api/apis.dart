import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  static User? get user => auth.currentUser;

  // for checking if user exists or not
  static Future<bool> userExists() async {
    return (await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get())
        .exists;
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
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllusers() {
    return Apis.firestore
        .collection('users')
        .where('id', isNotEqualTo: user!.uid)
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
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return Apis.firestore
        .collection('users')
        .where('id', isNotEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active stautus of users
  static Future<void> updateActiveStatus(bool isOnline) async {
    Apis.firestore.collection('users').doc(user!.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString()
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
    await ref.doc(time).set(message.toJson());
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
}
