import 'package:equatable/equatable.dart';

/// Represents a confirmed friendship between two users.
class Friend extends Equatable {
  /// Constructor for the [Friend].
  const Friend({
    required this.id,
    required this.user1Id,
    required this.user1Name,
    required this.user2Id,
    required this.user2Name,
    required this.friendship,
    required this.createdAt,
  });

  /// Empty Constructor for [Friend].
  ///
  /// This helps when writing unit tests.
  Friend.empty()
      : this(
          id: '',
          user1Id: '',
          user1Name: '',
          user2Id: '',
          user2Name: '',
          friendship: [],
          createdAt: DateTime.now(),
        );

  /// The unique ID of the friendship document.
  final String id;

  final List<String> friendship;

  /// The user ID of the first friend.
  final String user1Id;

  /// The user name of the first friend.
  final String user1Name;

  /// The user ID of the second friend.
  final String user2Id;

  /// The user name of the second friend.
  final String user2Name;

  /// The date when the friendship was established.
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        user1Id,
        user1Name,
        user2Id,
        user2Name,
        friendship,
        createdAt,
      ];
}
