import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zchat/api/apis.dart';
import 'package:zchat/helper/my_date_util.dart';
import 'package:zchat/model/message.dart';

import '../main.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Apis.user?.uid == widget.message.fromId
        ? greenMessage()
        : blueMessage();
  }

  // sender or another user messsage
  Widget blueMessage() {
    // update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      Apis.updateMessageReadStatus(widget.message);
      print("message read updated ana bhava");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // message content
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue.shade100,
                // making borders curved
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlue)
                ),
                padding: EdgeInsets.all(widget.message.type == Type.text ? mq.width * .04 : mq.width * .03),
                margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            
            // to check if image or text
            child: widget.message.type == Type.text 
            ?
            // show text
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ) 
            : 
            // show image
            ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.image , size: 70,)),
          ),
          ),
        ),

        // message time
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getformaterdTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // our or user message
  Widget greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // message time
        Row(
          children: [
            // for adding some space
            SizedBox(
              width: mq.width * 0.04,
            ),

            // double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all_rounded,
                color: Colors.blue,
                size: 20,
              ),

            // for adding some space
            SizedBox(
              width: mq.width * 0.02,
            ),
            // read time
            Text(
              MyDateUtil.getformaterdTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        // message content
        Flexible(
          child: Container(
            decoration: BoxDecoration(
                color: Colors.green.shade100,
                // making borders curved
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightGreen)),
              padding: EdgeInsets.all(widget.message.type == Type.text ? mq.width * .04 : mq.width * .03),
              margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            child:  widget.message.type == Type.text 
            ?
            // show text
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ) 
            : 
            // show image
            ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: CachedNetworkImage(
                imageUrl: widget.message.msg,
                placeholder: (context, url) => const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2,),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.image , size: 70,)),
          ),
          ),
        ),
      ],
    );
    ;
  }
}
