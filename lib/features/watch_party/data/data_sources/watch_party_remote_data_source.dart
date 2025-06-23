import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/auth/data/models/user_model.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';
import 'package:sync_together/features/watch_party/domain/entities/watch_party.dart';

/// **Remote Data Source for Watch Parties**
///
/// Handles all Firestore operations related to creating, joining, and syncing watch parties.
abstract class WatchPartyRemoteDataSource {
  /// Creates a new watch party session.
  ///
  /// - **Success:** Returns a [WatchPartyModel].
  /// - **Failure:** Throws a [WatchPartyException].
  Future<WatchPartyModel> createWatchParty({required WatchParty party});

  /// Joins an existing watch party session.
  ///
  /// - **Success:** Returns a [WatchPartyModel].
  /// - **Failure:** Throws a [WatchPartyException].
  Future<WatchPartyModel> joinWatchParty({
    required String partyId,
    required String userId,
  });

  /// Get a list of public watch parties.
  ///
  /// - **Success:** Returns a list of [WatchPartyModel].
  /// - **Failure:** Throws a [WatchPartyException].
  Future<List<WatchPartyModel>> getPublicWatchParties();

  /// Retrieves a watch party by ID.
  ///
  /// - **Success:** Returns a list of [WatchPartyModel].
  /// - **Failure:** Throws a [WatchPartyException].
  Future<WatchPartyModel> getWatchParty(String partyId);

  /// Leaves watch party.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws a [WatchPartyException].
  Future<void> leaveWatchParty({
    required String userId,
    required String partyId,
  });

  /// Ends watch party.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws a [WatchPartyException].
  Future<void> endWatchParty({
    required String partyId,
  });

  /// Listens to list of participants
  ///
  /// - **Success:** Returns a list of participant ids
  /// - **Failure:** Throws a [WatchPartyException].
  Stream<List<String>> listenToParticipants({required String partyId});

  /// Start watch party.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws a [WatchPartyException].
  Future<void> startParty({required String partyId});

  /// Listen to start status of a WatchParty
  ///
  /// - **Success:** Returns s bool.
  /// - **Failure:** Throws a [WatchPartyException].
  Stream<bool> listenToPartyStart({required String partyId});

  /// Listen to party existence
  ///
  /// - **Success:** Returns s bool.
  /// - **Failure:** Throws a [WatchPartyException].
  Stream<bool> listenToPartyExistence({required String partyId});

  /// Update watch party video url.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws a [WatchPartyException].
  Future<void> updateVideoUrl({
    required String partyId,
    required String newUrl,
  });

  /// Sends playback time to database.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws a [WatchPartyException].
  Future<void> sendSyncData({
    required String partyId,
    required double playbackPosition,
    required bool isPlaying,
  });

  /// Get updated playback time.
  ///
  /// - **Success:** Returns Map.
  /// - **Failure:** Throws a [WatchPartyException].
  Stream<DataMap> getSyncedData({required String partyId});

  /// Retrieves a user by ID.
  ///
  /// - **Success:** Returns UserModel.
  /// - **Failure:** Throws a [WatchPartyException].
  Future<UserModel> getUserById(String uid);
}

class WatchPartyRemoteDataSourceImpl implements WatchPartyRemoteDataSource {
  WatchPartyRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<WatchPartyModel> createWatchParty({required WatchParty party}) async {
    try {
      final docRef = _watchParties.doc();

      final watchParty = (party as WatchPartyModel).copyWith(
        id: docRef.id,
      );

      await docRef.set(watchParty.toMap());
      return watchParty;
    } on FirebaseAuthException catch (e) {
      throw CreateWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw CreateWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<WatchPartyModel> joinWatchParty({
    required String partyId,
    required String userId,
  }) async {
    try {
      final docRef = _watchParties.doc(partyId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw const JoinWatchPartyException(
          message: 'Watch party not found.',
          statusCode: '',
        );
      }

      final data = doc.data()!;
      final updatedParticipants = List<String>.from(
        data['participantIds'] as List,
      );

      if (!updatedParticipants.contains(userId)) {
        updatedParticipants.add(userId);
        await docRef.update({'participantIds': updatedParticipants});
      }

      return WatchPartyModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw JoinWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw JoinWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<List<WatchPartyModel>> getPublicWatchParties() async {
    try {
      final watchParties = await _watchParties
          .where('isPrivate', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .get()
          .then(
            (value) => value.docs
                .map(
                  (doc) => WatchPartyModel.fromMap(doc.data()),
                )
                .toList(),
          );
      return watchParties;
    } on FirebaseAuthException catch (e) {
      throw SyncWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw SyncWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<WatchPartyModel> getWatchParty(
    String partyId,
  ) async {
    try {
      final doc = await _watchParties.doc(partyId).get();

      if (!doc.exists) {
        throw const GetWatchPartyException(
          message: 'Watch party not found.',
          statusCode: '',
        );
      }

      return WatchPartyModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      throw GetWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw GetWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> leaveWatchParty({
    required String userId,
    required String partyId,
  }) async {
    try {
      final docRef = _watchParties.doc(partyId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw const LeaveWatchPartyException(
          message: 'Watch party not found.',
          statusCode: '',
        );
      }
      final data = doc.data();
      final participantIds = List<String>.from(
        data?['participantIds'] as List? ?? [],
      )..remove(userId);

      await docRef.update({'participantIds': participantIds});
    } on FirebaseAuthException catch (e) {
      throw LeaveWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw LeaveWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> endWatchParty({required String partyId}) async {
    try {
      await _watchParties.doc(partyId).delete();
    } on FirebaseAuthException catch (e) {
      throw EndWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw EndWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Stream<List<String>> listenToParticipants({required String partyId}) {
    try {
      final participantsStream = _watchParties.doc(partyId).snapshots().map(
        (snapshot) {
          final data = snapshot.data();
          return List<String>.from(data?['participantIds'] as List? ?? []);
        },
      );

      return participantsStream.handleError(
        (dynamic error) {
          if (error is FirebaseException) {
            throw ListenToParticipantsException(
              message: error.message ?? 'Unknown error occurred',
              statusCode: error.code,
            );
          }
          throw ListenToParticipantsException(
            message: error.toString(),
            statusCode: '505',
          );
        },
      );
    } on FirebaseException catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ListenToParticipantsException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: '501',
      );
    } on ListenToParticipantsException {
      rethrow;
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw ListenToParticipantsException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> startParty({required String partyId}) async {
    try {
      await _watchParties.doc(partyId).update({
        'hasStarted': true,
      });
    } on FirebaseAuthException catch (e) {
      throw StartWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } on ListenToParticipantsException {
      rethrow;
    } catch (e, s) {
      debugPrint('StartPartyException: $e\n$s ');
      throw StartWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Stream<bool> listenToPartyStart({required String partyId}) async* {
    try {
      final docRef = _watchParties.doc(partyId);

      final snapshot = await docRef.get();
      final initialHasStarted = snapshot.data()?['hasStarted'] == true;
      yield initialHasStarted;
      final statusStream = docRef.snapshots().map(
        (snapshot) {
          final data = snapshot.data();
          if (data == null) return false;
          return data['hasStarted'] == true;
        },
      );
      yield* statusStream.handleError((dynamic error) {
        if (error is FirebaseException) {
          throw ListenToPartyStartException(
            message: error.message ?? 'Unknown error occurred',
            statusCode: error.code,
          );
        }
        throw ListenToPartyStartException(
          message: error.toString(),
          statusCode: '505',
        );
      });
    } on FirebaseException catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      yield* Stream<bool>.error(
        ListenToPartyStartException(
          message: e.message ?? 'Unknown error occurred',
          statusCode: e.code,
        ),
      );
    } on ListenToPartyStartException catch (e) {
      yield* Stream<bool>.error(e);
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      yield* Stream<bool>.error(
        const ListenToPartyStartException(
          message: 'Unknown error occurred',
          statusCode: '500',
        ),
      );
    }
  }

  @override
  Future<void> updateVideoUrl({
    required String partyId,
    required String newUrl,
  }) async {
    try {
      await _watchParties.doc(partyId).update({'videoUrl': newUrl});
    } on FirebaseAuthException catch (e) {
      throw SyncWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw SyncWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Future<void> sendSyncData({
    required String partyId,
    required double playbackPosition,
    required bool isPlaying,
  }) async {
    try {
      final docRef = _watchParties.doc(partyId);
      final snapshot = await docRef.get();

      if (!snapshot.exists) return;

      await _watchParties.doc(partyId).set(
        {
          'playbackPosition': playbackPosition,
          'lastSyncedTime': Timestamp.now(),
          'isPlaying': isPlaying,
        },
        SetOptions(merge: true),
      );
    } on FirebaseAuthException catch (e) {
      throw SyncWatchPartyException(
        message: e.message ?? 'Error Occurred',
        statusCode: e.code,
      );
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      throw SyncWatchPartyException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Stream<DataMap> getSyncedData({required String partyId}) {
    final dataStream = _watchParties
        .doc(partyId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? {});
    return dataStream.handleError(
      (dynamic error) {
        if (error is FirebaseException) {
          throw SyncWatchPartyException(
            message: error.message ?? 'Unknown error occurred',
            statusCode: error.code,
          );
        }
        throw SyncWatchPartyException(
          message: error.toString(),
          statusCode: '505',
        );
      },
    );
  }

  @override
  Future<UserModel> getUserById(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      final data = doc.data();

      if (data == null) {
        throw GetUserByIdException(
          message: 'User $uid not found in Firestore.',
          statusCode: '404',
        );
      }
      return UserModel.fromMap(data);
    } on FirebaseAuthException catch (e) {
      throw GetUserByIdException(
        message: e.message ?? 'Error retrieving user $uid',
        statusCode: e.code,
      );
    } on GetUserByIdException {
      rethrow;
    } catch (e, s) {
      debugPrint('StartPartyException: $e\n$s ');
      throw GetUserByIdException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  @override
  Stream<bool> listenToPartyExistence({required String partyId}) {
    try {
      final existenceStream =
          _watchParties.doc(partyId).snapshots().map((snapshot) {
        return snapshot.exists;
      });

      return existenceStream.handleError((dynamic error) {
        if (error is FirebaseException) {
          throw ListenToPartyExistenceException(
              message: error.message ?? 'Unknown error occurred',
              statusCode: '500');
        }
      });
    } on FirebaseException catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);

      throw ListenToPartyExistenceException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.code,
      );
    } on ListenToPartyExistenceException {
      rethrow;
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
      throw ListenToPartyExistenceException(
        message: e.toString(),
        statusCode: '505',
      );
    }
  }

  CollectionReference<DataMap> get _watchParties => firestore.collection(
        FirebaseConstants.watchPartiesCollection,
      );

  CollectionReference<DataMap> get _users => firestore.collection(
        FirebaseConstants.usersCollection,
      );
}
