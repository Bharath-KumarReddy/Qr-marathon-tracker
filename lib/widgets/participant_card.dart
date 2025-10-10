import 'package:flutter/material.dart';
import '../models/participant.dart';

class ParticipantCard extends StatelessWidget {
  final Participant participant;
  final bool isPresent;
  final VoidCallback? onToggle;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.isPresent,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPresent ? Colors.green : Colors.red,
          child: Icon(
            isPresent ? Icons.check : Icons.close,
            color: Colors.white,
          ),
        ),
        title: Text(
          participant.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Jersey: ${participant.jersey}\n${participant.email}"),
        trailing: Switch(
          value: isPresent,
          onChanged: onToggle == null ? null : (_) => onToggle!(),
        ),
      ),
    );
  }
}
