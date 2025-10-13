import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class TicketListForUserPage extends StatefulWidget {
  const TicketListForUserPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TicketListForUserPageState();
}

class _TicketListForUserPageState extends State<TicketListForUserPage> {
  List<User> users = [];
  List<Ticket> tickets = [];
  User? selectedUser;
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/user/filter?userType=PASSENGER'));
      if (response.statusCode == 202) {
        final List<dynamic> userList = jsonDecode(response.body);
        setState(() {
          users = userList.map((userJson) => User.fromJson(userJson)).toList();
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load users: ${response.statusCode}';
        });
        print('Failed to load users');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load users: $e';
      });
      print('Failed to load users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> fetchBusStopName(int busStopId) async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/busStop/$busStopId'));
      if (response.statusCode == 202) {
        final Map<String, dynamic> busStopJson = jsonDecode(response.body);
        return busStopJson['name'] as String;
      } else if (response.statusCode == 404) {
        print('Bus stop not found: $busStopId');
        return 'Unknown Stop';
      } else {
        print('Failed to load bus stop name: ${response.statusCode}');
        return 'Unknown Stop';
      }
    } catch (e) {
      print('Failed to load bus stop name: $e');
      return 'Unknown Stop';
    }
  }

  Future<void> fetchTickets(int userId) async {
    setState(() {
      tickets = [];
      isLoading = true;
      errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/ticket/passenger?userId=$userId'));
      if (response.statusCode == 202) {
        final List<dynamic> ticketList = jsonDecode(response.body);
        List<Ticket> fetchedTickets = [];
        for (var ticketJson in ticketList) {
          final int startPointId = ticketJson['busStopStartPoint'];
          final int endPointId = ticketJson['busStopEndPoin'];

          final String startPointName = await fetchBusStopName(startPointId);
          final String endPointName = await fetchBusStopName(endPointId);

          final ticket = Ticket.fromJson(ticketJson, startPointName, endPointName);
          fetchedTickets.add(ticket);
        }
        setState(() {
          tickets = fetchedTickets;
        });
      } else {
        setState(() {
          tickets = [];
          errorMessage = 'Failed to load tickets: ${response.statusCode}';
        });
        print('Failed to load tickets');
      }
    } catch (e) {
      setState(() {
        tickets = [];
        errorMessage = 'Failed to load tickets: $e';
      });
      print('Failed to load tickets: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        hintColor: Colors.indigoAccent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          labelStyle: const TextStyle(color: Colors.indigo),
        ),
        cardTheme: CardThemeData(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          titleTextStyle: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Users and Tickets'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Selection Dropdown
              if (isLoading) const LinearProgressIndicator(),
              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              DropdownButtonFormField<User>(
                decoration: const InputDecoration(
                  labelText: 'Select User',
                ),
                value: selectedUser,
                items: users.map((User user) {
                  return DropdownMenuItem<User>(
                    value: user,
                    child: Text('${user.firstName} ${user.lastName}'),
                  );
                }).toList(),
                onChanged: (User? newValue) {
                  setState(() {
                    selectedUser = newValue;
                    if (newValue != null) {
                      fetchTickets(newValue.id);
                    } else {
                      tickets = [];
                    }
                  });
                },
              ),
              const SizedBox(height: 20),

              // Ticket List
              Expanded(
                child: Builder(
                  builder: (BuildContext context) {
                    if (isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (errorMessage != null) {
                      return Center(
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (tickets.isEmpty) {
                      return const Center(child: Text('No tickets for selected user'));
                    } else {
                      return ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          return Card(
                            child: ListTile(
                              title: Text('Ticket ID: ${ticket.id}', style: Theme.of(context).textTheme.titleMedium),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Price: \$${ticket.price}', style: Theme.of(context).textTheme.bodyLarge),
                                  Text('Start: ${ticket.startPoint}', style: Theme.of(context).textTheme.bodyLarge),
                                  Text('End: ${ticket.endPoint}', style: Theme.of(context).textTheme.bodyLarge),
                                  Text('Created At: ${ticket.createdAt}', style: Theme.of(context).textTheme.bodyLarge),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Ticket QR Code'),
                                      content: SizedBox(
                                        width: 250,
                                        height: 250,
                                        child: SingleChildScrollView(
                                          child: Center(
                                            child: QrImageView(
                                              data: '${ticket.id}',
                                              version: QrVersions.auto,
                                              size: 200.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: const Text('Close'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class User {
  final int id;
  final String firstName;
  final String lastName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}

class Ticket {
  final int id;
  final int price;
  final int busId;
  final int userId;
  final int routeId;
  final String startPoint;
  final String endPoint;
  final int busStopStartPoint;
  final int busStopEndPoin;
  final String createdAt;

  Ticket({
    required this.id,
    required this.price,
    required this.busId,
    required this.userId,
    required this.routeId,
    required this.startPoint,
    required this.endPoint,
    required this.busStopStartPoint,
    required this.busStopEndPoin,
    required this.createdAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json, String startPointName, String endPointName) {
    return Ticket(
      id: json['id'],
      price: json['price'],
      busId: json['busId'],
      userId: json['userId'],
      routeId: json['routeId'],
      startPoint: startPointName,
      endPoint: endPointName,
      busStopStartPoint: json['busStopStartPoint'],
      busStopEndPoin: json['busStopEndPoin'],
      createdAt: json['createdAt'],
    );
  }
}