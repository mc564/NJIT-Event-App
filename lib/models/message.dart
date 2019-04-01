import 'package:flutter/material.dart';

class Message {
  int id;
  String title;
  String body;
  String senderUCID;
  String recipientUCID;
  bool messageRead;
  DateTime timeCreated;
  Message(
      {@required int id,
      @required String title,
      @required String body,
      @required String senderUCID,
      @required String recipientUCID,
      @required bool messageRead,
      @required DateTime timeCreated})
      : this.id = id,
        this.title = title,
        this.body = body,
        this.senderUCID = senderUCID,
        this.recipientUCID = recipientUCID,
        this.messageRead = messageRead,
        this.timeCreated = timeCreated;

  @override
  String toString() {
    return "[" + title + "]";
  }
}
