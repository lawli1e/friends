import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

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
    final response = await http.get(Uri.parse('http://localhost:8080/posts'));
    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      setState(() {
        events = responseData;
      });
    } else {
      throw Exception('Failed to load events');
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final filteredEvents = events.where((event) {
      final eventStart = DateTime.parse(event['eventStart']);
      final difference = eventStart.difference(today).inDays;
      return difference == 1; // เหตุการณ์ที่จะถึงใน 1 วัน
    }).toList();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Notification',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredEvents.length,
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return ListTile(
            title: Text(event['title'] ?? ''),
            subtitle: Text('Event Start: ${formatDate(event['eventStart'] ?? '')}'),
            // สามารถเพิ่มข้อมูลเพิ่มเติมเพื่อแสดงใน ListTile ตามต้องการ
          );
        },
      ),
    );
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDate = DateFormat.yMd().add_jm().format(dateTime);
    return formattedDate;
  }
}
