class Participant {
  final String id;
  final String name;
  final String email;
  final String jersey;
  final String status;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.jersey,
    required this.status,
    this.startedAt,
    this.finishedAt,
  });

  factory Participant.fromMap(Map<String, dynamic> data, String docId) {
    return Participant(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      jersey: data['jersey']?.toString() ?? '',
      status: (data['status'] ?? 'absent').toString().toLowerCase(),
      startedAt: data['startedAt']?.toDate(),
      finishedAt: data['finishedAt']?.toDate(),
    );
  }
}
