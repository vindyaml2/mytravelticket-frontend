import 'package:flutter/material.dart';

class RoutePage extends StatelessWidget {
  final Map<String, dynamic> routeData;

  const RoutePage({Key? key, required this.routeData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Route Information:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Route Name: ${routeData['routeName']}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              // You can add more fields from your JSON response here
              Text(
                'Raw Data: ${routeData.toString()}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}