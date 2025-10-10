import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/participant.dart';

class DashboardPage extends StatelessWidget {
  final FirestoreService _fs = FirestoreService();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // ✅ TITLE TEXT STYLE CHANGED TO WHITE
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        // ✅ TITLE CENTERED
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 57, 67, 183),
      ),
      body: StreamBuilder<List<Participant>>(
        stream: _fs.getParticipants(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data!;
          final finished = list.where((p) => p.status == "finished").toList();
          final started = list.where((p) => p.status == "started").toList();
          final absent = list.where((p) => p.status == "absent").toList();

          return ListView(
            padding: const EdgeInsets.all(10),
            children: [
              _buildSection("🏁 Finished", finished, Colors.green),
              _buildSection("🏃 Started", started, Colors.orange),
              _buildSection("🚫 Absent", absent, Colors.red),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Participant> list, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          "$title (${list.length})",
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        children: list.isEmpty
            ? [const ListTile(title: Text("No data available"))]
            : list.map((p) {
                final duration = (p.finishedAt != null && p.startedAt != null)
                    ? p.finishedAt!.difference(p.startedAt!)
                    : null;
                final timeStr = duration != null
                    ? "${duration.inMinutes} min ${duration.inSeconds % 60} sec"
                    : "N/A";
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text("Jersey: ${p.jersey} | Time: $timeStr"),
                );
              }).toList(),
      ),
    );
  }
}
