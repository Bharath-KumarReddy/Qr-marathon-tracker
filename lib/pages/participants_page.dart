import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/participant.dart';

// No changes needed for the main page
class ParticipantsPage extends StatefulWidget {
  const ParticipantsPage({super.key});

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  final FirestoreService fs = FirestoreService();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Participants",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 57, 67, 183),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search by name or jersey number",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() => _searchText = value.trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Participant>>(
              stream: fs.getParticipants(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allParticipants = snapshot.data!;

                final filteredParticipants = allParticipants.where((p) {
                  final query = _searchText.toLowerCase();
                  return p.name.toLowerCase().contains(query) ||
                      p.jersey.toLowerCase().contains(query);
                }).toList();

                if (filteredParticipants.isEmpty) {
                  return const Center(child: Text("No participants found."));
                }

                return ListView.builder(
                  itemCount: filteredParticipants.length,
                  itemBuilder: (context, i) {
                    final p = filteredParticipants[i];
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text("Jersey: ${p.jersey}"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ParticipantDetailPage(participant: p),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Logic updated in the detail page
class ParticipantDetailPage extends StatelessWidget {
  final Participant participant;

  const ParticipantDetailPage({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    // This calculation remains the same. It correctly results in `null`
    // if `finishedAt` or `startedAt` is null.
    final duration =
        participant.finishedAt != null && participant.startedAt != null
        ? participant.finishedAt!.difference(participant.startedAt!)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(participant.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "Name: ${participant.name}",
              style: const TextStyle(fontSize: 18),
            ),
            Text("Email: ${participant.email}"),
            Text("Jersey: ${participant.jersey}"),
            Text("Status: ${participant.status}"),
            if (participant.startedAt != null)
              Text("Started: ${participant.startedAt}"),
            if (participant.finishedAt != null)
              Text("Finished: ${participant.finishedAt}"),
            // ✅ UPDATED LOGIC HERE:
            // This now displays the completion time or a placeholder '--'
            // instead of hiding the row completely.
            Text(
              "Completion Time: ${duration != null ? '${duration.inMinutes} min ${duration.inSeconds % 60} sec' : '--'}",
            ),
          ],
        ),
      ),
    );
  }
}
