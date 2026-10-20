import 'package:flutter/material.dart';

import 'client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const QuizNightApp());
}

class QuizNightApp extends StatelessWidget {
  const QuizNightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Night',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Placeholder until Milestone 3 (join + lobby screens).
      home: const Scaffold(body: Center(child: Text('Quiz Night'))),
    );
  }
}
