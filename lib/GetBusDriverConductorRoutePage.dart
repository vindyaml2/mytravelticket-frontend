import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GetBusDriverConductorRoutePage extends StatefulWidget {
  const GetBusDriverConductorRoutePage({Key? key}) : super(key: key);
  @override
  AssignBusDriverConductorRoutePageState createState() => AssignBusDriverConductorRoutePageState();
}

class AssignBusDriverConductorRoutePageState extends State<GetBusDriverConductorRoutePage> {
  // This function would typically fetch data from an API or database
  List<dynamic> busDriverConductorRoute = [];

 @override
  void initState() {
    super.initState();
    fetchBusDriverConductorRouteData();
  }

  Future<void> fetchBusDriverConductorRouteData() async {
    final url = Uri.parse('http://localhost:8080/bus-driver-conductor-mapper');
    try {
      final response = await http.get(url);
      if (response.statusCode == 202) {
        final List<dynamic> decodedData = json.decode(response.body);
        setState(() {
          busDriverConductorRoute = decodedData;
        });
      } else {
        // Handle error
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network error
      print('Error: $e');
    }
  }


 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Bus Driver & Conductor'),
      ),
      body: busDriverConductorRoute.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : ListView.builder(
              itemCount: busDriverConductorRoute.length,
              itemBuilder: (context, index) {
                final item = busDriverConductorRoute[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Driver: ${item['driverDto']['firstName']} ${item['driverDto']['lastName']}', style: TextStyle(fontSize: 16)),
                        Text('Conductor: ${item['conductorDto']['firstName']} ${item['conductorDto']['lastName']}', style: TextStyle(fontSize: 16)),
                        Text('Bus: ${item['busDto']['registrationNumber']}', style: TextStyle(fontSize: 16)),
                        Text('Route: ${item['routeDto']['routeName']}', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}