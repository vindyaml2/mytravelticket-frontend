import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TicketPage extends StatefulWidget {
  const TicketPage({Key? key}) : super(key: key);

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  // Define variables to store the selected values
  Bus? selectedBus;
  User? selectedUser;
  RouteModel? selectedRoute;
  BusStop? selectedStartPoint;
  BusStop? selectedEndPoint;

  // Define lists to store the data fetched from the APIs
  List<Bus> buses = [];
  List<User> users = [];
  List<RouteModel> routes = [];
  List<BusStop> startPoints = [];
  List<BusStop> endPoints = [];

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    fetchData();
  }

  // Function to fetch data from all APIs
  Future<void> fetchData() async {
    await fetchBuses();
    await fetchUsers();
    await fetchRoutes();
  }

  // Function to fetch buses from the API
  Future<void> fetchBuses() async {
    final response = await http.get(Uri.parse('http://localhost:8080/bus/filter?isOnDuty=true'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        buses = data.map((json) => Bus.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load buses');
    }
  }

  // Function to fetch users from the API
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8080/user/filter?userType=PASSENGER'));
    if (response.statusCode == 202) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        users = data.map((json) => User.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Function to fetch routes from the API
  Future<void> fetchRoutes() async {
    final response = await http.get(Uri.parse('http://localhost:8080/route'));
    if (response.statusCode == 202) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        routes = data.map((json) => RouteModel.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load routes');
    }
  }

  // Function to fetch bus stops from the API
  Future<void> fetchBusStops(int routeId, bool isStartPoint) async {
    final response = await http.get(Uri.parse('http://localhost:8080/route/stops?routeId=$routeId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<BusStop> busStops = data.map((json) => BusStop.fromJson(json)).toList();
      setState(() {
        if (isStartPoint) {
          startPoints = busStops;
          selectedStartPoint = null; // Reset selected start point when route changes
        } else {
          endPoints = busStops;
          selectedEndPoint = null; // Reset selected end point when route changes
        }
      });
    } else {
      throw Exception('Failed to load bus stops');
    }
  }

  // Function to create a ticket
  Future<void> createTicket() async {
    if (selectedBus == null || selectedUser == null || selectedRoute == null || selectedStartPoint == null || selectedEndPoint == null) {
      // Show an error message if any of the values are not selected
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select all the values.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    final Map<String, dynamic> requestBody = {
      "price": 15,
      "busId": selectedBus!.id,
      "userId": selectedUser!.id,
      "routeId": selectedRoute!.id,
      "busStopStartPoint": selectedStartPoint!.id,
      "busStopEndPoin": selectedEndPoint!.id,
    };

    final response = await http.get(
      Uri.parse('http://localhost:8080/ticket/price?busStopStartPoint=${requestBody["busStopStartPoint"]}&busStopEndPoin=${requestBody["busStopEndPoin"]}'),
      headers: {'Content-Type': 'application/json', 'accept': '*/*'}
    );

    if (response.statusCode == 202) {
      // Show a success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Ticket created successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    final double totalCost = double.parse(response.body);

    // Show a dialog to confirm ticket creation
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
      title: const Text('Total Cost'),
      content: Text('The total cost is ₹${totalCost.toStringAsFixed(2)}. Do you want to confirm the ticket?'),
      actions: [
        TextButton(
          onPressed: () {
        Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
        Navigator.of(context).pop(); // Close the dialog
        final ticketResponse = await http.post(
          Uri.parse('http://localhost:8080/ticket'),
          headers: {'Content-Type': 'application/json', 'accept': '*/*'},
          body: jsonEncode(requestBody),
        );

        if (ticketResponse.statusCode == 202) {
          // Show success message
          showDialog(
            context: context,
            builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Ticket created successfully.'),
            actions: [
              TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
              ),
            ],
          );
            },
          );
        } else {
          // Show error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create ticket. Status code: ${ticketResponse.statusCode}'),
            actions: [
              TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
              ),
            ],
          );
            },
          );
        }
          },
          child: const Text('Confirm'),
        ),
      ],
        );
      },
    );
    } else {
      // Show an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to create ticket. Status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bus dropdown
            DropdownButtonFormField<Bus>(
              decoration: const InputDecoration(labelText: 'Select Bus'),
              value: selectedBus,
              onChanged: (Bus? newValue) {
                setState(() {
                  selectedBus = newValue;
                });
              },
              items: buses.map<DropdownMenuItem<Bus>>((Bus bus) {
                return DropdownMenuItem<Bus>(
                  value: bus,
                  child: Text(bus.registrationNumber),
                );
              }).toList(),
            ),
            // User dropdown
            DropdownButtonFormField<User>(
              decoration: const InputDecoration(labelText: 'Select User'),
              value: selectedUser,
              onChanged: (User? newValue) {
                setState(() {
                  selectedUser = newValue;
                });
              },
              items: users.map<DropdownMenuItem<User>>((User user) {
                return DropdownMenuItem<User>(
                  value: user,
                  child: Text(user.firstName),
                );
              }).toList(),
            ),
            // Route dropdown
            DropdownButtonFormField<RouteModel>(
              decoration: const InputDecoration(labelText: 'Select Route'),
              value: selectedRoute,
              onChanged: (RouteModel? newValue) {
                setState(() {
                  selectedRoute = newValue;
                  // Fetch bus stops when the route is selected
                  if (newValue != null) {
                    fetchBusStops(newValue.id, true);
                    fetchBusStops(newValue.id, false);
                  } else {
                    startPoints = [];
                    endPoints = [];
                    selectedStartPoint = null;
                    selectedEndPoint = null;
                  }
                });
              },
              items: routes.map<DropdownMenuItem<RouteModel>>((RouteModel route) {
                return DropdownMenuItem<RouteModel>(
                  value: route,
                  child: Text(route.routeName),
                );
              }).toList(),
            ),
            // Start point dropdown
            DropdownButtonFormField<BusStop>(
              decoration: const InputDecoration(labelText: 'Select Start Point'),
              value: selectedStartPoint,
              onChanged: (BusStop? newValue) {
                setState(() {
                  selectedStartPoint = newValue;
                });
              },
              items: startPoints.map<DropdownMenuItem<BusStop>>((BusStop stop) {
                return DropdownMenuItem<BusStop>(
                  value: stop,
                  child: Text(stop.stopName),
                );
              }).toList(),
            ),
            // End point dropdown
            DropdownButtonFormField<BusStop>(
              decoration: const InputDecoration(labelText: 'Select End Point'),
              value: selectedEndPoint,
              onChanged: (BusStop? newValue) {
                setState(() {
                  selectedEndPoint = newValue;
                });
              },
              items: endPoints.map<DropdownMenuItem<BusStop>>((BusStop stop) {
                return DropdownMenuItem<BusStop>(
                  value: stop,
                  child: Text(stop.stopName),
                );
              }).toList(),
            ),
            // Create ticket button
            ElevatedButton(
              onPressed: createTicket,
              child: const Text('Get Price'),
            ),
          ],
        ),
      ),
    );
  }
}

// Data models
class Bus {
  final int id;
  final String registrationNumber;

  Bus({required this.id, required this.registrationNumber});

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      registrationNumber: json['registrationNumber'],
    );
  }
}

class User {
  final int id;
  final String firstName;

  User({required this.id, required this.firstName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
    );
  }
}

class RouteModel {
  final int id;
  final String routeName;

  RouteModel({required this.id, required this.routeName});

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      routeName: json['routeName'],
    );
  }
}

class BusStop {
  final int id;
  final String stopName;

  BusStop({required this.id, required this.stopName});

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      stopName: json['stopName'],
    );
  }
}