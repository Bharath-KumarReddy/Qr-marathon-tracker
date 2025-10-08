import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/firestore_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _fs = FirestoreService();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final code = capture.barcodes.first.rawValue;
      if (code == null) throw Exception('Invalid QR');
      final data = jsonDecode(code);

      final jersey =
          data['jersey']?.toString() ?? data['jersey_number']?.toString();
      if (jersey == null) throw Exception('No jersey number found');

      final participant = await _fs.findByJersey(jersey);
      if (participant == null) {
        Fluttertoast.showToast(msg: "Participant not found");
      } else {
        await _fs.markFinished(participant.id);
        Fluttertoast.showToast(msg: "✅ ${participant.name} marked Finished!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner")),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          if (_isProcessing) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
