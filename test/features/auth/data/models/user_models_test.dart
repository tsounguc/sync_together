import 'package:flutter_test/flutter_test.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/auth/domain/entities/user.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final testJson = fixture('user.json');
  final testUserModel = UserModel.fromJson(testJson);
  final testMap = testUserModel.toMap();

  test(
    'given [UserModel], '
    'when instantiated '
    'then instance should be subclass of [UserEntity]',
    () {
      // Arrange
      // Act
      // Assert
      expect(testUserModel, isA<UserEntity>());
    },
  );

  group('fromMap - ', () {
    test(
        'given [UserModel], '
        'when fromMap is called, '
        'then return [UserModel] with correct data ', () {
      // Arrange
      // Act
      final result = UserModel.fromMap(testMap);
      // Assert
      expect(result, isA<UserModel>());
      expect(result, equals(testUserModel));
    });
  });

  group('toMap - ', () {
    test(
        'given [UserModel], '
        'when toMap is called, '
        'then return [Map] with correct data ', () {
      // Arrange
      // Act
      final result = testUserModel.toMap();
      // Assert
      expect(result, equals(testMap));
    });
  });

  group('copyWith - ', () {
    const testEmail = 'tsounguc@mail.gvsu.edu';
    test(
      'given [UserModel], '
      'when copyWith is called, '
      'then return [UserModel] with updated data ',
      () {
        // Arrange
        // Act
        final result = testUserModel.copyWith(email: testEmail);
        // Assert
        expect(result.email, equals(testEmail));
      },
    );
  });
}
