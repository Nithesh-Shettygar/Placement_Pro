import 'package:flutter/material.dart';
import 'package:placementpro/landing/landing_view.dart';
import 'package:placementpro/screens/student/student_view.dart';
import 'package:placementpro/screens/admin/job_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Career Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const LandingPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/admin/jobs': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return JobPortalsPage(
            userData: args?['userData'] ?? {},
            initialTab: args?['initialTab'] as int?,
          );
        },
      },
    );
  }
}