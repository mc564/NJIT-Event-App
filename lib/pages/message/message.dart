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
  List<Message> _messageList;
  String _numMessagesString() {
    if (_messageList == null || _messageList.length == 0) {
      return '0 Messages';
    }
    int numMessages = _messageList.length;
    if (numMessages == 1) {
      return "1 Message";
    } else {
      return numMessages.toString() + " Messages";
    }
  }

  Future<void> _refresh() async {
    widget._messageBloc.sink.add(ReloadMessages());
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
    return Container(height: 0, width: 0);
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

  Dismissible _buildMessageListTile(Message message) {
    bool read = message.messageRead;
    return Dismissible(
      key: Key(DateTime.now().toString()),
      onDismissed: (DismissDirection direction) {
        widget._messageBloc.sink.add(RemoveMessage(message: message));
        setState(() {
          _messageList.removeWhere(
              (Message msg) => message.timeCreated == msg.timeCreated);
        });
      },
      background: Container(
          color: Colors.red,
          padding: EdgeInsets.only(right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                'Remove Message ',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.delete, color: Colors.white),
            ],
          )),
      child: ListTile(
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
      ),
    );
  }

  Widget _buildBody() {
    Widget child;

    child = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            _numMessagesString(),
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        Container(
          height: 500,
          child: (_messageList == null || _messageList.length == 0)
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
                  itemCount: _messageList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Message message = _messageList[index];

                    return _buildMessageListTile(message);
                  },
                ),
        ),
      ],
    );

    return Center(
      child: Container(
        margin: EdgeInsets.all(10),
        child: RefreshIndicator(
          child: child,
          onRefresh: () => _refresh(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    MessageState initialState = widget._messageBloc.initialState;
    if (initialState is MessagesLoaded) {
      _messageList = initialState.messages;
    }
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
