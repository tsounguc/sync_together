import 'dart:convert';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';

/// **UserModel** represents the Firebase user data model.
///
/// This extends [UserEntity] and includes JSON serialization methods.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.isAnonymous,
  });

  /// Represents an empty [UserModel] instance.
  ///
  /// Used for default values or initializing empty states.
  const UserModel.empty()
      : this(
          uid: '_empty.uid',
          email: null,
          displayName: null,
          photoUrl: null,
          isAnonymous: false,
        );

  /// Creates a [UserModel] from a JSON string.
  factory UserModel.fromJson(String source) => UserModel.fromMap(
        jsonDecode(source) as DataMap,
      );

  /// Creates a [UserModel] from a key-value map.
  UserModel.fromMap(DataMap dataMap)
      : this(
            uid: dataMap['uid'] as String,
            email: dataMap['email'] as String?,
            displayName: dataMap['displayName'] as String?,
            photoUrl: dataMap['photoUrl'] as String?,
            isAnonymous: dataMap['isAnonymous'] as bool? ?? false);

  /// Converts a [UserModel] instance to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Converts a [UserModel] instance to a key-value map.
  DataMap toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isAnonymous': isAnonymous,
      };

  /// Creates a copy of the current [UserModel] with optional updates.
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isAnonymous,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
