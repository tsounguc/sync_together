import 'dart:convert';

import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
    super.isAnonymous,
  });

  const UserModel.empty()
      : this(
          uid: '_empty.uid',
          email: null,
          displayName: null,
          photoUrl: null,
          isAnonymous: false,
        );

  factory UserModel.fromJson(String source) => UserModel.fromMap(
        jsonDecode(source) as DataMap,
      );

  UserModel.fromMap(DataMap dataMap)
      : this(
            uid: dataMap['uid'] as String,
            email: dataMap['email'] as String?,
            displayName: dataMap['displayName'] as String?,
            photoUrl: dataMap['photoUrl'] as String?,
            isAnonymous: dataMap['isAnonymous'] as bool? ?? false);

  String toJson() => jsonEncode(toMap());

  DataMap toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'isAnonymous': isAnonymous,
      };
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
