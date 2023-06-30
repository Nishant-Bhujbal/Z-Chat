

import 'package:flutter/material.dart';

class MyDateUtil {
  MyDateUtil(BuildContext context, String sent);

  // for getting formatted time from milliseondsinceepoch string
  static String getformaterdTime(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));

    return TimeOfDay.fromDateTime(date).format(context);
  }

  // for gettinf formatted time for sent and read
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent_time =
        DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent_time).format(context);

    if (now.day == sent_time.day &&
        now.month == sent_time.month &&
        now.year == sent_time.year) {
      return formattedTime;
    }

    return now.year == sent_time.year
        ? '$formattedTime - ${sent_time.day} ${getMonth(sent_time)}'
        : '$formattedTime - ${sent_time.day} ${getMonth(sent_time)} ${sent_time.year}';
  }

  // get last message time(used in chat user card)
  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {

    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return TimeOfDay.fromDateTime(sent).format(context);
    }

    return showYear
        ? '${sent.day} ${getMonth(sent)} ${sent.year}'
        : '${sent.day} ${getMonth(sent)}';
  }

  // get month name from mont no, or index
  static String getMonth(DateTime time) {
    switch (time.month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'N/A';
  }

  // get formatted last active time
  static String getLastActiveTime(
      {required BuildContext context, required String lastActiveTime}) {
    final int i = int.tryParse(lastActiveTime) ?? -1;

    // if time is not availble then return below statement
    if (i == -1) return 'Last seen not available';

    DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);

    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return 'Last seen today at $formattedTime';
    }

    if ((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }

    String Month = getMonth(time);
    return 'last seen on ${time.day} $Month on $formattedTime';
  }
}
