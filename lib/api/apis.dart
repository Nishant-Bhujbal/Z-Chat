import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zchat/model/chat_user.dart';

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

  static Future<void> UpdateUserInfor() async {
    await firestore
        .collection("users")
        .doc(user!.uid)
        .update({'name': self.name, 'about': self.about});
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
}
