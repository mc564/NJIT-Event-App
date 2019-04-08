import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/message_provider.dart';
import '../models/message.dart';
import 'package:equatable/equatable.dart';

class MessageBloc {
  final MessageProvider _messageProvider;
  final StreamController<MessageEvent> _requestsController;
  final StreamController<MessageState> _messageController;
  final String _ucid;
  MessageState _prevState;

  MessageBloc({@required String ucid})
      : _ucid = ucid,
        _messageProvider = MessageProvider(),
        _messageController = StreamController<MessageState>.broadcast(),
        _requestsController = StreamController<MessageEvent>.broadcast() {
    _prevState = MessagesLoading();
    _messageController.stream.listen((MessageState state) {
      _prevState = state;
    });
    reloadMessages();
    _requestsController.stream.forEach((MessageEvent event) {
      event.execute(this);
    });
  }

  MessageProvider get messageProvider => _messageProvider;
  MessageState get initialState => _prevState;
  Stream get messages => _messageController.stream;
  StreamSink<MessageEvent> get sink => _requestsController.sink;

  void _alertError(String errorMsg) {
    _messageController.sink.add(MessageError(errorMsg: errorMsg));
  }

  void _alertMessagesLoading() {
    _messageController.sink.add(MessagesLoading());
  }

  void _fetchMessages() async {
    try {
      List<Message> messages = await _messageProvider.fetchMessages(_ucid);
      _messageController.sink.add(MessagesLoaded(messages: messages));
    } catch (error) {
      _alertError(
          'Error in messageBloc _fetchMessages method: ' + error.toString());
    }
  }

  void reloadMessages() async {
    try {
      _alertMessagesLoading();
      _fetchMessages();
    } catch (error) {
      _alertError(
          'Error in Message BLOC reloadMessages function: ' + error.toString());
    }
  }

  void setMessageToRead(Message message) async {
    try {
      bool success = await _messageProvider.setMessageToRead(message);
      if (!success) {
        _alertError('Error in Message BLOC setMessageToRead function');
      }
    } catch (error) {
      _alertError('Error in Message BLOC setMessageToRead function: ' +
          error.toString());
    }
  }

  void removeMessage(Message message) async {
    try {
      bool success = await _messageProvider.removeMessage(message);
      if (!success) {
        _alertError('Error in Message BLOC removeMessage function');
      } else {
        _fetchMessages();
      }
    } catch (error) {
      _alertError(
          'Error in Message BLOC removeMessage function: ' + error.toString());
    }
  }

  void dispose() {
    _messageController.close();
    _requestsController.close();
  }
}

/*MESSAGE BLOC input EVENTS */
abstract class MessageEvent extends Equatable {
  MessageEvent([List args = const []]) : super(args);
  void execute(MessageBloc messageBloc);
}

class ReloadMessages extends MessageEvent {
  void execute(MessageBloc messageBloc) {
    messageBloc.reloadMessages();
  }
}

class SetMessageToRead extends MessageEvent {
  final Message message;
  SetMessageToRead({@required Message message})
      : message = message,
        super([message]);
  void execute(MessageBloc messageBloc) {
    messageBloc.setMessageToRead(message);
  }
}

class RemoveMessage extends MessageEvent {
  final Message message;
  RemoveMessage({@required Message message})
      : message = message,
        super([message]);
  void execute(MessageBloc messageBloc) {
    messageBloc.removeMessage(message);
  }
}

/* MESSAGE BLOC output STATES */
abstract class MessageState extends Equatable {
  MessageState([List args = const []]) : super(args);
}

class MessagesLoaded extends MessageState {
  final List<Message> messages;
  MessagesLoaded({@required List<Message> messages})
      : this.messages = messages,
        super([messages]);
}

class MessagesLoading extends MessageState {}

class MessageError extends MessageState {
  final String errorMsg;
  MessageError({@required String errorMsg})
      : this.errorMsg = errorMsg,
        super([errorMsg]);
}
