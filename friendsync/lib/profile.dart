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
  List<String> activities = []; // รายการกิจกรรมที่เข้าร่วม
  List<String> posts = []; // รายการกิจกรรมที่โพสต์
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
  Future<List<String>> getActivities() async {
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
        final List<String> activities =
        data.map((e) => e.toString()).toList();
        return activities;
      } else {
        throw Exception('Failed to load activities');
      }
    } catch (error) {
      throw Exception('Failed to load activities: $error');
    }
  }

  // เมธอดสำหรับโหลดข้อมูลกิจกรรมที่โพสต์จากเซิร์ฟเวอร์
  Future<List<String>> getPosts() async {
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
        final List<String> posts = data.map((e) => e.toString()).toList();
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
                        return ListTile(
                          title: Text(activities[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20.0),
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
                        return ListTile(
                          title: Text(posts[index]),
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
