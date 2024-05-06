import 'dart:developer';
import './service.dart';
import 'package:flutter/material.dart';
import 'package:friendsync/main.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _UserNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  //create the service class obj
  Service service = Service();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Text(
                'Create Account',
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold,) // Adjust font size
              ),
              SizedBox(height: 50.0),
              TextField(
                controller: _UserNameController,
                decoration: InputDecoration(
                  labelText: 'USERNAME',
                ),
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                ),
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                ),
              ),
              SizedBox(height: 15.0),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CONFIRM PASSWORD',
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                  onPressed: () async {
                    bool registrationSuccess = await service.saveUser(
                      _UserNameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _confirmPasswordController.text,
                    );
                    if (registrationSuccess) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                    } else {
                    }
                  },
                  style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                ),
                child: Text('SIGNUP',
                style: TextStyle(
                  color: Colors.white),
                )
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
                    },
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
