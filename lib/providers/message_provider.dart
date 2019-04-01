import '../api/database_event_api.dart';
import '../models/message.dart';

class MessageProvider {
  Future<bool> sendMessage(String senderUCID, List<String> recipientUCIDS,
      String title, String body, DateTime expirationDate) {
    return DatabaseEventAPI.sendMessage(
        senderUCID, recipientUCIDS, title, body, expirationDate);
  }

  Future<bool> sendMessageToAdmins(
      String senderUCID, String title, String body, DateTime expirationDate) {
    return DatabaseEventAPI.sendMessageToAdmins(
        senderUCID, title, body, expirationDate);
  }

  Future<List<Message>> fetchMessages(String ucid) async {
    List<Message> messages = await DatabaseEventAPI.fetchMessages(ucid);
    if (messages != null)
      messages.sort((Message m1, Message m2) {
        bool oneRead = m1.messageRead;
        bool twoRead = m2.messageRead;
        if (!oneRead && twoRead) {
          return -1;
        } else if (oneRead && !twoRead) {
          return 1;
        } else {
          return m2.timeCreated.compareTo(m1.timeCreated);
        }
      });
    return messages;
  }

  Future<bool> setMessageToRead(Message message) async {
    return DatabaseEventAPI.setMessageToRead(message);
  }

  Future<bool> removeMessage(Message message) async {
    return DatabaseEventAPI.removeMessage(message);
  }
}
