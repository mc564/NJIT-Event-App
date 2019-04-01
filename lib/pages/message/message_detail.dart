import 'package:flutter/material.dart';
import '../../models/message.dart';
import 'package:intl/intl.dart';

class MessageDetailPage extends StatelessWidget {
  final DateFormat dateFormatter;
  final Message message;

  MessageDetailPage({@required Message message})
      : this.message = message,
        dateFormatter = DateFormat("EEE, MMM d, ").add_jm();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  message.senderUCID,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  dateFormatter.format(message.timeCreated),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Text(
              'to me',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              message.body,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
