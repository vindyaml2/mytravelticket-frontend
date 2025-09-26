import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConductorFormPage extends StatefulWidget {
  const ConductorFormPage({Key? key}) : super(key: key);

  @override
  ConductorFormPageState createState() => ConductorFormPageState();
}

class ConductorFormPageState extends State<ConductorFormPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController aadharNumberController = TextEditingController();
  TextEditingController panNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://localhost:8080/conductor');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'password': passwordController.text,
        'aadharNumber': aadharNumberController.text,
        'panNumber': panNumberController.text,
        'address': addressController.text,
      });

      try {
        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conductor registered successfully!')),
          );
          _formKey.currentState!.reset();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register conductor. Status code: ${response.statusCode}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductor Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: aadharNumberController,
                decoration: const InputDecoration(labelText: 'Aadhar Number', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhar number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: panNumberController,
                decoration: const InputDecoration(labelText: 'PAN Number', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter PAN number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('Register Conductor'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}