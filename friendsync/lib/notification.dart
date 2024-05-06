import 'package:flutter/material.dart';
import 'package:friendsync/crpost.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({super.key});

  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notification',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [

        ],
      ),
    );
  }
}
