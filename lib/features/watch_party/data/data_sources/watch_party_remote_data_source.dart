import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_together/core/errors/exceptions.dart';
import 'package:sync_together/core/utils/firebase_constants.dart';
import 'package:sync_together/core/utils/type_defs.dart';
import 'package:sync_together/features/watch_party/data/models/watch_party_model.dart';

/// **Remote Data Source for Watch Parties**
///
/// Handles all Firestore operations related to creating, joining, and syncing watch parties.
abstract class WatchPartyRemoteDataSource {
  /// Creates a new watch party session.
  ///
  /// - **Success:** Returns a [WatchPartyModel].
  /// - **Failure:** Throws an [WatchPartyException].
  Future<WatchPartyModel> createWatchParty({
    required String hostId,
    required String videoUrl,
    required String title,
  });

  /// Joins an existing watch party session.
  ///
  /// - **Success:** Returns a list of [WatchPartyModel].
  /// - **Failure:** Throws an [WatchPartyException].
  Future<WatchPartyModel> joinWatchParty({
    required String partyId,
    required String userId,
  });

  /// Retrieves a watch party by ID.
  ///
  /// - **Success:** Returns a list of [WatchPartyModel].
  /// - **Failure:** Throws an [WatchPartyException].
  Future<WatchPartyModel> getWatchParty(String partyId);

  /// Synchronizes playback time across users.
  ///
  /// - **Success:** Completes without returning a value.
  /// - **Failure:** Throws an [WatchPartyException].
  Future<void> syncPlayback({
    required String partyId,
    required double playbackPosition,
  });
}

class WatchPartyRemoteDataSourceImpl implements WatchPartyRemoteDataSource {
  WatchPartyRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;
  @override
  Future<WatchPartyModel> createWatchParty({
    required String hostId,
    required String videoUrl,
    required String title,
  }) async {
    try {
      final docRef = _watchParties.doc();

      final watchParty = WatchPartyModel(
        id: docRef.id,
        hostId: hostId,
        videoUrl: videoUrl,
        title: title,
        participantIds: [hostId],
        createdAt: DateTime.now(),
        lastSyncedTime: DateTime.now(),
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
  Future<WatchPartyModel> getWatchParty(
    String partyId,
  ) async {
    try {
      final docRef = firestore.collection(FirebaseConstants.watchPartiesCollection).doc(partyId);
      final doc = await docRef.get();

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
  Future<WatchPartyModel> joinWatchParty({
    required String partyId,
    required String userId,
  }) async {
    try {
      final docRef = firestore.collection(FirebaseConstants.watchPartiesCollection).doc(partyId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw const JoinWatchPartyException(message: 'Watch party not found.', statusCode: '');
      }

      final data = doc.data()!;
      final updatedParticipants = List<String>.from(
        data['participantIds'] as List,
      );

      if (!updatedParticipants.contains(userId)) {
        updatedParticipants.add(userId);
        await docRef.update({'participants': updatedParticipants});
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
  Future<void> syncPlayback({
    required String partyId,
    required double playbackPosition,
  }) async {
    try {
      await _watchParties.doc(partyId).update({
        'playbackPosition': playbackPosition,
        'lastSyncedTime': Timestamp.now(),
      });
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

  CollectionReference<DataMap> get _watchParties => firestore.collection(
        FirebaseConstants.watchPartiesCollection,
      );
}
