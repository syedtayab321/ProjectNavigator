import 'package:flutter/material.dart';

class MessageScreen extends StatelessWidget {
  final String studentName;

  MessageScreen({required this.studentName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message $studentName'),
      ),
      body: Center(
        child: Text("Messaging with $studentName"),
      ),
    );
  }
}