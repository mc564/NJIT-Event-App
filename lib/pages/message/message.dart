import 'package:flutter/material.dart';
import '../../blocs/message_bloc.dart';
import '.././../models/message.dart';
import './message_detail.dart';
import 'package:intl/intl.dart';

class MessagePage extends StatefulWidget {
  final MessageBloc _messageBloc;
  MessagePage({@required MessageBloc messageBloc}) : _messageBloc = messageBloc;
  @override
  State<StatefulWidget> createState() {
    return _MessagePageState();
  }
}

class _MessagePageState extends State<MessagePage> {
  String _numMessagesString(List<Message> messageList) {
    if (messageList == null || messageList.length == 0) {
      return '0 Messages';
    }
    int numMessages = messageList.length;
    if (numMessages == 1) {
      return "1 Message";
    } else {
      return numMessages.toString() + " Messages";
    }
  }

  Future<void> _refresh() async {
    widget._messageBloc.sink.add(ReloadMessages());
  }

  void _showAreYouSureDeleteDialog(Message message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete this message?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Return'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  widget._messageBloc.sink.add(RemoveMessage(message: message));
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  ListTile _buildNoMessagesListTile() {
    return ListTile(
      title: Text(
        'No messages currently!',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrailingListTileWidget(Message message) {
    bool read = message.messageRead;
    if (!read) {
      return Chip(
        label: Text(
          'NEW!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
      );
    }
    return IconButton(
      icon: Icon(Icons.remove_circle),
      color: Colors.red,
      onPressed: () {
        _showAreYouSureDeleteDialog(message);
      },
    );
  }

  String _timeCreatedText(Message message) {
    DateFormat timeFormatter = DateFormat.jm();
    DateFormat dateFormatter = DateFormat('MMM d');
    DateTime now = DateTime.now();
    DateTime timeCreated = message.timeCreated;
    if (timeCreated.day == now.day &&
        timeCreated.month == now.month &&
        timeCreated.year == now.year) {
      //same day
      return timeFormatter.format(timeCreated);
    }
    return dateFormatter.format(timeCreated);
  }

  ListTile _buildMessageListTile(Message message) {
    bool read = message.messageRead;
    return ListTile(
      title: Text(
        message.title,
        style:
            TextStyle(fontWeight: read ? FontWeight.normal : FontWeight.bold),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          _timeCreatedText(message),
        ),
      ),
      trailing: _buildTrailingListTileWidget(message),
      onTap: () {
        if (message.messageRead == false) {
          setState(() {
            message.messageRead = true;
            widget._messageBloc.sink.add(SetMessageToRead(message: message));
          });
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) =>
                MessageDetailPage(message: message),
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    return StreamBuilder<MessageState>(
      initialData: widget._messageBloc.initialState,
      stream: widget._messageBloc.messages,
      builder: (BuildContext context, AsyncSnapshot<MessageState> snapshot) {
        MessageState state = snapshot.data;
        Widget child;
        if (state is MessagesLoading) {
          child = CircularProgressIndicator();
        } else if (state is MessagesLoaded) {
          List<Message> messages = state.messages;

          child = Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  _numMessagesString(messages),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                height: 500,
                child: (messages == null || messages.length == 0)
                    ? ListView.builder(
                        itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          return _buildNoMessagesListTile();
                        },
                      )
                    : ListView.separated(
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            color: Colors.black,
                          );
                        },
                        itemCount: messages.length,
                        itemBuilder: (BuildContext context, int index) {
                          Message message = messages[index];

                          return _buildMessageListTile(message);
                        },
                      ),
              ),
            ],
          );
        } else {
          child = ListView.builder(
            itemCount: 1,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                  title: Text(
                      'Whoops, there was an error! 😿 Try dragging down to refresh, meow 🐱'));
            },
          );
        }
        return Center(
          child: Container(
            margin: EdgeInsets.all(10),
            child: RefreshIndicator(
              child: child,
              onRefresh: () => _refresh(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Inbox'),
      ),
      body: _buildBody(),
    );
  }
}
