import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/message_provider.dart';
import '../models/message.dart';
import 'package:equatable/equatable.dart';

class MessageBloc {
  final MessageProvider _messageProvider;
  final StreamController<MessageState> _messageController;
  final String _ucid;
  MessageState _prevState;
  MessageBloc({@required String ucid})
      : _ucid = ucid,
        _messageProvider = MessageProvider(),
        _messageController = StreamController<MessageState>.broadcast() {
    _prevState = MessagesLoading();
    _messageController.stream.listen((MessageState state) {
      _prevState = state;
    });

    reloadMessages();
  }

  MessageProvider get messageProvider => _messageProvider;
  MessageState get initialState => _prevState;
  Stream get messages => _messageController.stream;

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
  }
}

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
