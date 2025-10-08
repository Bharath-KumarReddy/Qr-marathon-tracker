import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/participant.dart';
import '../widgets/participant_card.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirestoreService _fs = FirestoreService();
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Management"),
        backgroundColor: const Color(0xFF90CAF9),
      ),
      body: Column(
        children: [
          // 🔍 Search bar
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

          // 🔹 Live participants list
          Expanded(
            child: StreamBuilder<List<Participant>>(
              stream: _fs.getParticipants(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No participants found"));
                }

                final all = snapshot.data!;
                final filtered = all.where((p) {
                  final query = _searchText.toLowerCase();
                  return p.name.toLowerCase().contains(query) ||
                      (p.jersey != null &&
                          p.jersey.toLowerCase().contains(query));
                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final p = filtered[i];
                    final isPresent = p.status == "started";

                    return ParticipantCard(
                      participant: p,
                      isPresent: isPresent,
                      onToggle: () {
                        if (isPresent) {
                          _fs.markAbsent(p.id);
                        } else {
                          _fs.markStarted(p.id);
                        }
                      },
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
