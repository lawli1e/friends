import 'dart:developer';
import 'service.dart';
import 'package:flutter/material.dart';
import 'package:friendsync/Home.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {

  final Service service = Service();

  // Controllers to capture user input
  TextEditingController _eventNameController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _maxParticipantsController = TextEditingController();
  TextEditingController _noteController = TextEditingController();
  TextEditingController _DateController = TextEditingController();

  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create post', style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _eventNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.event_available_outlined),
                  labelText: "Event name",
                ),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.map_outlined),
                  labelText: "Location",
                ),
              ),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: [
                DropdownMenuItem<String>(
                  value: "Eat",
                  child: Row(
                      children: <Widget>[
                      Icon(Icons.food_bank),
                        SizedBox(width: 20),
                  Text("Eat"),
              ]
                   ),
                ),
                DropdownMenuItem<String>(
                  value: "Game",
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.games),
                        SizedBox(width: 20),
                        Text("Game"),
                      ]
                  ),
                ),
                DropdownMenuItem<String>(
                  value: "Sport",
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.sports),
                        SizedBox(width: 20),
                        Text("Sport"),
                      ]
                  ),
                ),
                DropdownMenuItem<String>(
                  value: "Book",
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.book),
                        SizedBox(width: 20),
                        Text("Book"),
                      ]
                  ),
                ),
                DropdownMenuItem<String>(
                  value: "Travel",
                    child: Row(
                        children: <Widget>[
                          Icon(Icons.card_travel),
                          SizedBox(width: 20),
                          Text("Travel"),
                        ]
                    ),
                ),
                DropdownMenuItem<String>(
                  value: "Study",
                  child: Row(
                      children: <Widget>[
                        Icon(Icons.person),
                        SizedBox(width: 20),
                        Text("Study"),
                      ]
                  ),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),

              TextButton(
                onPressed: () {
                },
                child: Text("Photos (optional)"),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _DateController,
                onTap: () async {
                  // Show date picker when the user taps on the text field
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    // Show time picker when a date is selected
                    final selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      // Combine the selected date and time into a single DateTime object
                      final combinedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );
                      // Update the text field with the selected date and time
                      setState(() {
                        _DateController.text = combinedDateTime.toString();
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today),
                  labelText: "Select Date and Time",
                ),
                readOnly: true, // Make the text field read-only
              )
              ,


              SizedBox(height: 10.0),
              TextField(

                controller: _maxParticipantsController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: "Max participants",
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _noteController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.note_add),
                  labelText: "Note",
                ),
                maxLines: 2,
              ),
           SizedBox(height: 30.0),
          Center(
            child: ElevatedButton(

                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));

                  _submitPost();
                },
                  style: ButtonStyle(

                    backgroundColor: MaterialStateProperty.all(Colors.orangeAccent),
                  ),
                child: Text("Post",
                style: TextStyle(
                  color: Colors.white,
                ),
                )

              ),
          )
            ],
          ),
        ),
      ),
    );
  }

  void _submitPost() async {
    String eventName = _eventNameController.text;
    String datetime = _DateController.text;
    String location = _locationController.text;
    int maxParticipants = int.tryParse(_maxParticipantsController.text) ?? 0;
    String note = _noteController.text;

    // Call the service method to create the post
    bool success = await service.createPost(
      eventName,
      datetime,
      location,
      maxParticipants,
      note,
      _selectedCategory ?? '', // Pass _selectedCategory, defaulting to empty string if null
    );

    if (success) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

}



