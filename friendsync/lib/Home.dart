import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<dynamic> posts = [];

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
        posts = responseData;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  String formatDate(String dateTimeString, int offsetHours) {
    DateTime dateTime = DateTime.parse(dateTimeString).add(Duration(hours: offsetHours));
    String formattedDate = DateFormat.yMd().add_jm().format(dateTime);
    return formattedDate;
  }

  Future<void> joinPost(int postId, String token) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/participants'),
      body: json.encode({'post_id': postId}),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('Join successful');
    } else {
      throw Exception('Failed to join post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentIndex == 0
          ? AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: null,
          ),
        ),
        title: Text('Today - ${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}'),
        actions: [
          IconButton(
            icon: Image.asset(
              'asset/images/addorange.png',
              width: 40,
            ),
            onPressed: () {}, // แก้ไขเพื่อให้เป็นเรียก method _navigateToPostScreen(context)
          ),
        ],
      )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: [
          ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return post != null
                  ? ListTile(
                title: Text(post['title'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post['location'] ?? ''),
                    Text(formatDate(post['eventStart'] ?? '', 7)),
                    Text('Max Participants: ${post['maxParticipants']}'),
                    Text('Note: ${post['description']}'),
                    Text('Created by: ${post['userId']}'),
                  ],
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();
                    final String? token = prefs.getString('token');
                    if (token != null) {
                      joinPost(post['id'], token);
                    } else {
                      print('Token not found in SharedPreferences');
                    }
                  },
                  child: Text('Join'),
                ),
              )
                  : Container();
            },
          ),
          // NotificationWidget(),
          // ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
