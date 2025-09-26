import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverListPage extends StatefulWidget {
  const DriverListPage({Key? key}) : super(key: key);

  @override
  State<DriverListPage> createState() => _DriverListPageState();
}

class _DriverListPageState extends State<DriverListPage> {
  late Future<List<dynamic>> _driversFuture;

  @override
  void initState() {
    super.initState();
    _driversFuture = fetchDrivers();
  }

  Future<List<dynamic>> fetchDrivers() async {
    const url = 'http://localhost:8080/driver';
    try {
      final response = await http.get(Uri.parse(url), headers: {'accept': '*/*'});

      if (response.statusCode == 202) {
        final List<dynamic> data = json.decode(response.body);
        return data;
      }
      else {
        throw Exception('Failed to load drivers: Status code ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load drivers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver List', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[200],
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _driversFuture = fetchDrivers();
          });
        },
        child: FutureBuilder<List<dynamic>>(
          future: _driversFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)));
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        '${snapshot.error}',
                        style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _driversFuture = fetchDrivers();
                          });
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                        child: const Text('Retry', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline, size: 60, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No drivers found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else {
              final drivers = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: drivers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return DriverCard(driver: driver);
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DriverCard extends StatelessWidget {
  final dynamic driver;

  const DriverCard({Key? key, required this.driver}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${driver['firstName'] ?? 'N/A'} ${driver['lastName'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            DriverInfoRow(label: 'Aadhar', value: driver['aadharNumber']),
            DriverInfoRow(label: 'PAN', value: driver['panNumber']),
            DriverInfoRow(label: 'Address', value: driver['address']),
          ],
        ),
      ),
    );
  }
}

class DriverInfoRow extends StatelessWidget {
  final String label;
  final dynamic value;

  const DriverInfoRow({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          Expanded(
            child: Text(value != null ? value.toString() : 'N/A', style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}