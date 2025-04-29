part of 'chat_cubit.dart';

/// Base state for watch party.
sealed class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Error state
class ChatError extends ChatState {
  const ChatError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Chat loading state
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Message Sending state
class MessageSending extends ChatState {
  const MessageSending();
}

/// Success state when messages received
class MessagesReceived extends ChatState {
  const MessagesReceived(this.messages);
  final List<Message> messages;

  @override
  List<Object?> get props => [messages];
}

/// Success state when message sent
class MessageSent extends ChatState {
  const MessageSent();
}
