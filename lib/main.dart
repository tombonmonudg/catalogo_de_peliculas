import 'package:flutter/material.dart';

void main() {
  runApp(const MiPrimeraApp());
}

class MiPrimeraApp extends StatelessWidget {
  const MiPrimeraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome App',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('Welcome to Flutter'),
        ),

        body: const Center(
          child: Text('Hello World', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
