import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

class WebRTCSignaling {
  WebRTCSignaling({
    String? sessionId,
  }) : sessionId = sessionId ?? const Uuid().v4();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final String sessionId;
  RTCPeerConnection? _peerConnection;

  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  Future<void> createConnection() async {
    _peerConnection = await createPeerConnection(_config);

    // Listen for ICE candidate
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      _database.ref('watch_party/$sessionId/ice_candidates').push().set(candidate.toMap());
    };

    // Listen for remote stream
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      debugPrint('Remote track added: ${event.track.kind}');
    };
  }

  // Handle incoming ICE candidates
  void listenForIceCandidates() {
    _database.ref('watch_party/$sessionId/ice_candidates').onChildAdded.listen(
      (event) {
        final candidate = RTCIceCandidate(
          event.snapshot.child('candidate').value.toString(),
          event.snapshot.child('sdpMid').value.toString(),
          int.parse(event.snapshot.child('sdpMLineIndex').value.toString()),
        );
        _peerConnection?.addCandidate(candidate);
      },
    );
  }
}
