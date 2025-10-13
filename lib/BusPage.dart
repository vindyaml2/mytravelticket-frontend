import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Buspage extends StatefulWidget {
  const Buspage({Key? key}) : super(key: key);

  @override
  State<Buspage> createState() => _BuspageState();
}

class _BuspageState extends State<Buspage> {
  final _formKey = GlobalKey<FormState>();
  String registrationNumber = '';

  Future<void> createBus() async {
    final url = Uri.parse('http://localhost:8080/bus');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'registrationNumber': registrationNumber});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
        _showAlertDialog('Success', 'Bus created successfully!');
        _formKey.currentState!.reset(); // Clear the form
      } else {
        _showAlertDialog('Error', 'Failed to create bus. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showAlertDialog('Error', 'Error occurred: $error');
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Bus'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Registration Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
                onSaved: (value) {
                  registrationNumber = value!;
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      createBus();
                    }
                  },
                  child: const Text('Create Bus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}