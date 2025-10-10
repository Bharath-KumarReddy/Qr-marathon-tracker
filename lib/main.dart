import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:og/splash_screen.dart';
import 'firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/attendance_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/participants_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const JerseyDigitApp());
}

class JerseyDigitApp extends StatelessWidget {
  const JerseyDigitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jersey Digit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 57, 67, 183),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;
  final pages = [
    const AttendancePage(),
    const HomePage(),
    DashboardPage(),
    const ParticipantsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Participants",
          ),
        ],
      ),
    );
  }
}
