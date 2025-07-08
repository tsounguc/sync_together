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

/// Message Editing state
class MessageEditing extends ChatState {
  const MessageEditing();
}

/// Messages fetching state
class FetchingMessages extends ChatState {
  const FetchingMessages();
}

/// Message Deleting state
class MessageDeleting extends ChatState {
  const MessageDeleting();
}

/// Messages Clearing state
class MessagesClearing extends ChatState {
  const MessagesClearing();
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

/// Success state when message edited
class MessageEdited extends ChatState {
  const MessageEdited();
}

/// Success state when message deleted
class MessageDeleted extends ChatState {
  const MessageDeleted();
}

/// Success state when message fetched
class MessagesFetched extends ChatState {
  const MessagesFetched(this.messages);

  final List<Message> messages;

  @override
  List<Object?> get props => [messages];
}

/// Success state when messages cleared
class MessagesCleared extends ChatState {
  const MessagesCleared();
}

/// Success state when typing users upated
class TypingUsersUpdated extends ChatState {
  const TypingUsersUpdated(this.userNames);

  final List<String> userNames;

  @override
  List<Object> get props => [userNames];
}
