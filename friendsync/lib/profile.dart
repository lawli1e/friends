import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> activities = []; // รายการกิจกรรมที่เข้าร่วม
  List<Map<String, dynamic>> posts = []; // รายการกิจกรรมที่โพสต์
  late String token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  // เมธอดสำหรับโหลด token จาก SharedPreferences
  void loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null && storedToken.isNotEmpty) {
      setState(() {
        token = storedToken;
        fetchActivitiesAndPosts();
      });
    }
  }

  Future<void> fetchActivitiesAndPosts() async {
    try {
      // เรียกเซิร์ฟเวอร์เพื่อโหลดข้อมูลกิจกรรมที่เข้าร่วมและกิจกรรมที่โพสต์
      activities = await getActivities();
      posts = await getPosts();

      // อัปเดตสถานะของ State ด้วย setState เพื่อให้ Flutter ทราบว่าข้อมูลถูกเปลี่ยนแปลงแล้ว
      setState(() {});
    } catch (error) {
      print('Error fetching activities and posts: $error');
    }
  }

  // เมธอดสำหรับโหลดข้อมูลกิจกรรมที่เข้าร่วมจากเซิร์ฟเวอร์
  Future<List<Map<String, dynamic>>> getActivities() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/user_activities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> activities = data.map((activity) {
          return {
            'userId': activity['userId'],
            'title': activity['title'],
            'description': activity['description'],
            'joinedAt': activity['joinedAt'],
          };
        }).toList();
        return activities;
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (error) {
      throw Exception('Failed to load activities: $error');
    }
  }

  // เมธอดสำหรับโหลดข้อมูลกิจกรรมที่โพสต์จากเซิร์ฟเวอร์
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/user_posts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> posts = List<Map<String, dynamic>>.from(data);
        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (error) {
      throw Exception('Failed to load posts: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('asset/images/login.png'),
              radius: 60.0,
            ),
            const SizedBox(height: 20.0),
            if (activities.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Activities:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 2.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Title: ${activities[index]['title']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'UserID: ${activities[index]['userId']}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Description: ${activities[index]['description']}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'JoinedAt: ${activities[index]['joinedAt']}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20.0),
            // แก้ไขส่วนที่ใช้ในการแสดงรายการกิจกรรมที่โพสต์
            if (posts.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Posts:',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 200.0,
                    child: ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 2.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  posts[index]['title'], // เข้าถึงชื่อ title ของกิจกรรม
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'UserID: ${posts[index]['userId']}', // แสดงข้อมูล userID
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Description: ${posts[index]['description']}', // แสดงข้อมูล description
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Max Participants: ${posts[index]['maxParticipants']}', // แสดงข้อมูล maxParticipants
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Category: ${posts[index]['category']}', // แสดงข้อมูล category
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Event Start: ${posts[index]['eventStart']}', // แสดงข้อมูล eventStart
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
