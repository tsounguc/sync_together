import 'package:equatable/equatable.dart';

class Message extends Equatable {
  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
  });

  /// Empty Constructor for [Message].
  ///
  /// This helps when writing unit tests.
  Message.empty()
      : this(
          id: '',
          senderId: '',
          senderName: '',
          text: '',
          timestamp: DateTime.now(),
        );

  /// Unique ID of the message.
  final String id;

  /// The user ID of the sender.
  final String senderId;

  /// The user name of the sender.
  final String senderName;

  /// The content of the message.
  final String text;

  /// Timestamp of the message.
  final DateTime timestamp;

  @override
  String toString() {
    return '''
    Message(
       id: $id,
       senderId: $senderId,
       senderName: $senderName,
       text: $text,
       timestamp: $timestamp,
    )
    ''';
  }

  @override
  List<Object?> get props => [
        id,
        senderId,
        senderName,
        text,
        timestamp,
      ];
}
