class Participant {
  final String id;
  final String name;
  final String email;
  final String jersey;
  final String status;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  // Optional extra details
  final int? age;
  final double? distance;
  final String? tshirtSize;
  final bool? certificateSent;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.jersey,
    required this.status,
    this.startedAt,
    this.finishedAt,
    this.age,
    this.distance,
    this.tshirtSize,
    this.certificateSent,
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
      age: data['age'],
      distance: (data['distance'] != null)
          ? double.tryParse(data['distance'].toString())
          : null,
      tshirtSize: data['tshirtSize'],
      certificateSent: data['certificateSent'] ?? false,
    );
  }
}
