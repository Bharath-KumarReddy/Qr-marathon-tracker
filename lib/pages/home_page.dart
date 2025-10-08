// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import '../services/firestore_service.dart';
// import '../models/participant.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final FirestoreService _fs = FirestoreService();
//   bool _isProcessing = false;
//   late Stream<List<Participant>> _participantsStream;
//   late MobileScannerController _scannerController;
//   List<Participant> _participants = [];

//   @override
//   void initState() {
//     super.initState();

//     _participantsStream = _fs.getParticipants();
//     _scannerController = MobileScannerController(
//       detectionSpeed: DetectionSpeed.noDuplicates,
//       formats: [BarcodeFormat.qrCode],
//     );

//     // ✅ Keep participants list updated live from Firestore
//     _participantsStream.listen(
//       (participants) {
//         if (mounted) {
//           setState(() {
//             _participants = participants;
//           });
//         }
//       },
//       onError: (e) {
//         Fluttertoast.showToast(msg: "❌ Error loading participants: $e");
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _scannerController.dispose();
//     super.dispose();
//   }

//   Future<void> _onDetect(BarcodeCapture capture) async {
//     if (_isProcessing) return;
//     setState(() => _isProcessing = true);

//     try {
//       if (capture.barcodes.isEmpty) {
//         throw Exception('No QR code detected');
//       }

//       final code = capture.barcodes.first.rawValue;
//       if (code == null || code.isEmpty) {
//         throw Exception('Invalid QR code');
//       }

//       Map<String, dynamic> data;
//       try {
//         data = jsonDecode(code) as Map<String, dynamic>;
//       } catch (e) {
//         throw Exception('Invalid QR code format');
//       }

//       final jersey =
//           data['jersey']?.toString() ?? data['jersey_number']?.toString();
//       if (jersey == null || jersey.isEmpty) {
//         throw Exception('No jersey number found in QR code');
//       }

//       // ✅ Ensure participants are up to date
//       if (_participants.isEmpty) {
//         throw Exception('Participant data not loaded yet. Please try again.');
//       }

//       final participant = _participants.firstWhere(
//         (p) => p.jersey == jersey,
//         orElse: () => throw Exception('Participant not found'),
//       );

//       // ✅ Status checks
//       if (participant.status == 'finished') {
//         Fluttertoast.showToast(
//           msg: "❗ ${participant.name} has already finished!",
//         );
//         return;
//       }

//       if (participant.status == 'present') {
//         Fluttertoast.showToast(
//           msg: "❌ ${participant.name} must be started first!",
//         );
//         return;
//       }

//       if (participant.status != 'started') {
//         Fluttertoast.showToast(
//           msg: "❌ ${participant.name} is not eligible to finish!",
//         );
//         return;
//       }

//       // Pause scanner for dialog
//       await _scannerController.stop();

//       final TextEditingController jerseyController = TextEditingController(
//         text: jersey,
//       );

//       final bool? confirmed = await showDialog<bool>(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => AlertDialog(
//           title: const Text('Confirm Finish'),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Participant: ${participant.name}'),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: jerseyController,
//                 decoration: const InputDecoration(
//                   labelText: 'Jersey Number',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel'),
//             ),
//             FilledButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Confirm'),
//             ),
//           ],
//         ),
//       );

//       if (confirmed == true) {
//         if (jerseyController.text != jersey) {
//           await _fs.updateJersey(participant.id, jerseyController.text);
//         }
//         await _fs.markFinished(participant.id);
//         Fluttertoast.showToast(msg: "✅ ${participant.name} marked Finished!");
//       }

//       // Resume scanner
//       if (!mounted) return;
//       await _scannerController.start();
//     } catch (e) {
//       Fluttertoast.showToast(msg: "❌ Error: $e");
//     } finally {
//       if (mounted) setState(() => _isProcessing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("QR Scanner")),
//       body: Stack(
//         children: [
//           MobileScanner(controller: _scannerController, onDetect: _onDetect),
//           if (_isProcessing) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/firestore_service.dart';
import '../models/participant.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _fs = FirestoreService();
  bool _isProcessing = false;
  late Stream<List<Participant>> _participantsStream;
  late MobileScannerController _scannerController;
  List<Participant> _participants = [];

  @override
  void initState() {
    super.initState();

    _participantsStream = _fs.getParticipants();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: [BarcodeFormat.qrCode],
    );

    // ✅ Keep participants list updated live from Firestore
    _participantsStream.listen(
      (participants) {
        if (mounted) {
          setState(() {
            _participants = participants;
          });
        }
      },
      onError: (e) {
        Fluttertoast.showToast(msg: "❌ Error loading participants: $e");
      },
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      if (capture.barcodes.isEmpty) {
        throw Exception('No QR code detected');
      }

      final code = capture.barcodes.first.rawValue;
      if (code == null || code.isEmpty) {
        throw Exception('Invalid QR code');
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(code) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Invalid QR code format');
      }

      final jersey =
          data['jersey']?.toString() ?? data['jersey_number']?.toString();
      if (jersey == null || jersey.isEmpty) {
        throw Exception('No jersey number found in QR code');
      }

      // ✅ Ensure participants are up to date
      if (_participants.isEmpty) {
        throw Exception('Participant data not loaded yet. Please try again.');
      }

      final participant = _participants.firstWhere(
        (p) => p.jersey == jersey,
        orElse: () => throw Exception('Participant not found'),
      );

      // ✅ Status checks
      if (participant.status == 'finished') {
        Fluttertoast.showToast(
          msg: "❗ ${participant.name} has already finished!",
        );
        return;
      }

      if (participant.status == 'present') {
        // ⚠️ Show popup if participant has not started yet
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Participant Not Started'),
            content: Text(
              "${participant.name} must be started first before finishing.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      if (participant.status != 'started') {
        // same handling for other invalid states
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Invalid Status'),
            content: Text(
              "${participant.name} is not eligible to finish (Status: ${participant.status}).",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // ✅ Automatically mark as finished
      await _scannerController.stop();
      await _fs.markFinished(participant.id);
      Fluttertoast.showToast(msg: "✅ ${participant.name} marked Finished!");

      await _scannerController.start();
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner")),
      body: Stack(
        children: [
          MobileScanner(controller: _scannerController, onDetect: _onDetect),
          if (_isProcessing) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
