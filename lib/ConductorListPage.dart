import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConductorListPage extends StatefulWidget {
  const ConductorListPage({Key? key}) : super(key: key);

  @override
  ConductorListPageState createState() => ConductorListPageState();
}

class ConductorListPageState extends State<ConductorListPage> {
  List<dynamic> conductors = [];

  @override
  void initState() {
    super.initState();
    fetchConductors();
  }

  Future<void> fetchConductors() async {
    final url = Uri.parse('http://localhost:8080/conductor');
    try {
      final response = await http.get(url);
      if (response.statusCode == 202) {
        setState(() {
          conductors = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load conductors. Status code: ${response.statusCode}. Please try again later.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to the server. Please check your internet connection and try again.')),
      );
      print(error); // Log the error for debugging purposes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Conductors', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: conductors.isEmpty
          ? const Center(child: Text('No conductors found.'))
          : ListView.builder(
              itemCount: conductors.length,
              itemBuilder: (context, index) {
                final conductor = conductors[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('First Name: ${conductor['firstName']}', style: const TextStyle(fontSize: 16)),
                        Text('Last Name: ${conductor['lastName']}', style: const TextStyle(fontSize: 16)),
                        Text('Aadhar Number: ${conductor['aadharNumber']}', style: const TextStyle(fontSize: 16)),
                        Text('PAN Number: ${conductor['panNumber']}', style: const TextStyle(fontSize: 16)),
                        Text('Address: ${conductor['address']}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
