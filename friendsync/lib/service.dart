import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Home.dart';

class Service {
  Future<bool> saveUser(String username, String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      print('Password and Confirm Password do not match.');
      return false;
    }

    final uri = Uri.parse('http://localhost:8080/register');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final userData = {
      'username': username,
      'email': email,
      'password': password,
    };
    final encodedData = jsonEncode(userData);

    try {
      final response = await http.post(uri, headers: headers, body: encodedData);

      if (response.statusCode == 201) {
        print('User registration successful!');
        return true;
      } else {
        print('Registration failed with status code: ${response.statusCode}');
        return false;
      }
    } on http.ClientException catch (e) {
      print('Error: Client exception occurred: $e');
      return false;
    } on SocketException catch (e) {
      print('Error: Could not reach the server: $e');
      return false;
    } catch (e) {
      print('Error during registration: $e');
      rethrow;
    }
  }



  Future<bool> loginUser(BuildContext context, String username, String password) async {
    final uri = Uri.parse('http://localhost:8080/login');
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    final userData = {
      'username': username,
      'password': password,
    };
    final encodedData = jsonEncode(userData);

    try {
      final response = await http.post(uri, headers: headers, body: encodedData);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String token = responseData['token'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);


        Navigator.push(context as BuildContext, MaterialPageRoute(builder: (context) => HomeScreen()));
        print('Login successful!');
        return true; // Return true to indicate successful login
      } else if (response.statusCode == 401) {
        print('Invalid username or password');
        return false; // Return false for invalid credentials
      } else {
        print('Login failed with status code: ${response.statusCode}');
        return false; // Return false for any other error
      }
    } on http.ClientException catch (e) {
      print('Error: Client exception occurred: $e');
      return false; // Return false for client exceptions
    } on SocketException catch (e) {
      print('Error: Could not reach the server: $e');
      return false; // Return false for socket exceptions
    } catch (e) {
      print('Error during login: $e');
      rethrow; // Rethrow other exceptions for further handling
    }
  }

  Future<bool> createPost(
      String eventName,
      String datetime,
      String location,
      int maxParticipants,
      String note,
      String category,
      ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    final uri = Uri.parse('http://localhost:8080/create_post');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final postData = {
      'title': eventName,
      'eventStart': datetime,
      'location': location,
      'max_participants': maxParticipants,
      'description': note,
      'category': category,
    };
    print('Request data: $postData'); // Print the data before sending the request
    final encodedData = jsonEncode(postData);
    try {
      final response = await http.post(uri, headers: headers, body: encodedData);
      print(response.toString());
      if (response.statusCode == 201) {
        print('Post created successfully!');
        return true;
      } else {
        print('Failed to create post with status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error creating post: $e');
      return false;
    }
  }





}
