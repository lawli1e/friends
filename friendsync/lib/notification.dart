import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key? key}) : super(key: key);

  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  List<dynamic> events = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://localhost:8080/notification'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print(responseData);
      setState(() {
        events = responseData;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notification',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchData,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return Card( // ใช้ Card เพื่อให้ Widget ดูสวยงามและมีขอบ
            margin: EdgeInsets.all(8), // กำหนดระยะห่างรอบขอบของ Card
            elevation: 4, // เพิ่มเงาให้กับ Card
            child: ListTile(
              title: Text(event['title'] ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Event Start: ${event['eventStart'] ?? ''}'),
                  Text('Description: ${event['description'] ?? ''}'),
                  Text('Max Participants: ${event['maxParticipants'] ?? ''}'),
                  Text('Category: ${event['category'] ?? ''}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
