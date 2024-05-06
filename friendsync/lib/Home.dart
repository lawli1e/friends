import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:friendsync/profile.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'crpost.dart';
import 'notification.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<dynamic> posts = [];

  void _navigateToPostScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen()));
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          posts = responseData;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  String formatDate(String dateTimeString, int offsetHours) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString).add(Duration(hours: offsetHours));
      String formattedDate = DateFormat.yMd().add_jm().format(dateTime);
      return formattedDate;
    } catch (e) {
      print('Error formatting date: $e');
      return '';
    }
  }

  Future<void> joinPost(int postId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/participants'),
        body: json.encode({'post_id': postId}),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> responseData = json.decode(response.body);
        // Access the postID data in responseData
        int? postID = responseData['postID'];
        print('Join successful. Post ID: $postID');
      } else {
        throw Exception('Failed to join post');
      }
    } catch (e) {
      print('Error joining post: $e');
    }
  }

  Widget _buildPostListItem(dynamic post) {
    return ListTile(
      title: Text(post['title'] ?? ''),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Category: ${post['category']}'),
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
            if (post['postId'] != null) {
              try {
                int postId = post['postId'];
                await joinPost(postId, token);
              } catch (e) {
                print('Failed to join post: $e');
              }
            } else {
              print('Post ID is null');
            }
          } else {
            print('Token not found in SharedPreferences');
          }
        },
        child: Text('Join'),
      ),
    );
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
            onPressed: () => _navigateToPostScreen(context),
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
              return post != null ? Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: _buildPostListItem(post),
              ) : Container();
            },
          ),
          NotificationWidget(),
          ProfileScreen(),
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
