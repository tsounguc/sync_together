import 'package:equatable/equatable.dart';

/// Represents a user entity in the authentication domain.
/// This abstraction allows us to work with user data **without**
/// depending  on Firebase or any specific backend implementation
class UserEntity extends Equatable {
  /// Constructor for the [UserEntity].
  ///
  /// All fields except [uid] are optional, as anonymous users
  /// may not have email, display name, or profile picture.
  const UserEntity({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.isAnonymous = false,
  });

  /// Empty Constructor for the [UserEntity].
  ///
  /// This sets the uid to an empty string,
  /// while nullable fields remain null.
  /// This helps when writing unit tests.
  const UserEntity.empty()
      : this(
          uid: '',
          email: null, // Keeping null to match Firebase default behavior
          displayName: null,
          photoUrl: null,
          isAnonymous: false,
        );

  /// The unique user ID (UID) from the authentication provider
  final String uid;

  /// The user's email address (optional, may be null for anonymous users).
  final String? email;

  /// The user's display name (optional, may be null for anonymous users).
  final String? displayName;

  /// The URL of the user's profile picture (optional).
  final String? photoUrl;

  /// Indicates whether the user is signed in anonymously.
  final bool isAnonymous;

  /// Converts the entity to a readable format for debugging.
  @override
  String toString() {
    return '''
    UserEntity(
       uid: $uid, 
       email: $email, 
       displayName: $displayName, 
       isAnonymous: $isAnonymous, 
       photoUrl: $photoUrl,
    ) ''';
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        isAnonymous,
      ];
}
