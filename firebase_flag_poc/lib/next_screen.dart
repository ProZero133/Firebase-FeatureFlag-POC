import 'package:flutter/material.dart';

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beta feature')),
      body: const Center(
        child: Text(
          'This is a beta feature available through Firebase Remote Config.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}