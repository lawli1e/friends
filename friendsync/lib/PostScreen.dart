import 'package:flutter/material.dart';

class PostWidget extends StatelessWidget {
  final String title;
  final String location;
  final String eventStart;
  final int maxParticipants;
  final String creatorName;

  const PostWidget({
    required Key key,
    required this.title,
    required this.location,
    required this.eventStart,
    required this.maxParticipants,
    required this.creatorName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(location),
          Text(eventStart),
          Text('Max Participants: $maxParticipants'),
          Text('Created by: $creatorName'),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // Handle join action
        },
        child: Text('Join'),
      ),
    );
  }
}
