import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssignBusDriverConductorRoutePage extends StatefulWidget {
  const AssignBusDriverConductorRoutePage({Key? key}) : super(key: key);

  @override
  _AssignBusDriverConductorRoutePageState createState() => _AssignBusDriverConductorRoutePageState();
}

class _AssignBusDriverConductorRoutePageState extends State<AssignBusDriverConductorRoutePage> {
  List<dynamic> buses = [];
  List<dynamic> drivers = [];
  List<dynamic> conductors = [];
  List<dynamic> routes = [];

  int? selectedBusId;
  int? selectedDriverId;
  int? selectedConductorId;
  int? selectedRouteId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await fetchBuses();
    await fetchDrivers();
    await fetchConductors();
    await fetchRoutes();
  }

  Future<void> fetchBuses() async {
    final url = Uri.parse('http://localhost:8080/bus/filter?isOnDuty=false');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          buses = json.decode(response.body);
        });
      } else {
        print('Failed to load buses: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchDrivers() async {
    final url = Uri.parse('http://localhost:8080/user/filter?isOnDuty=false&userType=DRIVER');
    try {
      final response = await http.get(url);
      if (response.statusCode == 202) {
        setState(() {
          drivers = json.decode(response.body);
        });
      } else {
        print('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchConductors() async {
    final url = Uri.parse('http://localhost:8080/user/filter?isOnDuty=false&userType=CONDUCTOR');
    try {
      final response = await http.get(url);
      if (response.statusCode == 202) {
        setState(() {
          conductors = json.decode(response.body);
        });
      } else {
        print('Failed to load conductors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchRoutes() async {
    final url = Uri.parse('http://localhost:8080/route');
    try {
      final response = await http.get(url);
      if (response.statusCode == 202) {
        setState(() {
          routes = json.decode(response.body);
        });
      } else {
        print('Failed to load routes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> assignBusDriverConductorRoute() async {
    final url = Uri.parse('http://localhost:8080/bus-driver-conductor-mapper');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'driverId': selectedDriverId,
      'conductorId': selectedConductorId,
      'busId': selectedBusId,
      'routeId': selectedRouteId,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201) {
        // Mapping created successfully
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Mapping created successfully"),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
      } else {
        // Handle error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to create mapping"),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          },
        );
        print('Failed to create mapping: ${response.statusCode}');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Bus'),
              value: selectedBusId,
              items: buses.map((bus) {
                return DropdownMenuItem<int>(
                  value: bus['id'],
                  child: Text(bus['registrationNumber']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedBusId = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Driver'),
              value: selectedDriverId,
              items: drivers.map((driver) {
                return DropdownMenuItem<int>(
                  value: driver['id'],
                  child: Text('${driver['firstName']} ${driver['lastName']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDriverId = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Conductor'),
              value: selectedConductorId,
              items: conductors.map((conductor) {
                return DropdownMenuItem<int>(
                  value: conductor['id'],
                  child: Text('${conductor['firstName']} ${conductor['lastName']}'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedConductorId = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(labelText: 'Select Route'),
              value: selectedRouteId,
              items: routes.map((route) {
                return DropdownMenuItem<int>(
                  value: route['id'],
                  child: Text(route['routeName']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRouteId = value;
                });
              },
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                assignBusDriverConductorRoute();
              },
              child: Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }
}
