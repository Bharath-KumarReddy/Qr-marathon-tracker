import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/participant.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance.collection('participants');

  // 🔹 Get all participants in real-time
  Stream<List<Participant>> getParticipants() {
    return _db.snapshots().map(
      (snap) =>
          snap.docs.map((d) => Participant.fromMap(d.data(), d.id)).toList(),
    );
  }

  // 🔹 Mark started
  Future<void> markStarted(String id) async {
    await _db.doc(id).update({
      'status': 'started',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Mark finished
  Future<void> markFinished(String id) async {
    await _db.doc(id).update({
      'status': 'finished',
      'finishedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Mark absent
  Future<void> markAbsent(String id) async {
    await _db.doc(id).update({'status': 'absent'});
  }

  // 🔹 Find by jersey number (for QR scan)
  Future<Participant?> findByJersey(String jersey) async {
    final q = await _db.where('jersey', isEqualTo: jersey).get();
    if (q.docs.isEmpty) return null;
    final d = q.docs.first;
    return Participant.fromMap(d.data(), d.id);
  }

  // 🔹 Update jersey number
  Future<void> updateJersey(String id, String jersey) async {
    await _db.doc(id).update({'jersey': jersey});
  }
}
