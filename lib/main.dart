import 'package:flutter/material.dart';

void main() {
  runApp(const MagicBeatsApp());
}

class MagicBeatsApp extends StatelessWidget {
  const MagicBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Beats',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Magic Beats'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 80, color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            const Text(
              'Добро пожаловать в Magic Beats!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Студия независимых битов',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('Включить бит'),
            ),
          ],
        ),
      ),
    );
  }
}
