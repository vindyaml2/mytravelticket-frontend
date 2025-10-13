import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TicketListPage extends StatefulWidget {
  const TicketListPage({Key? key}) : super(key: key);

  @override
  State<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends State<TicketListPage> {
  Future<List<dynamic>>? _ticketData;

  @override
  void initState() {
    super.initState();
    _ticketData = fetchTicketData();
  }

  Future<List<dynamic>> fetchTicketData() async {
    final response = await http.get(Uri.parse('http://localhost:8080/ticket'));
    if (response.statusCode == 202) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      throw Exception('Failed to load ticket data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket List'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _ticketData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Ticket ID: ${snapshot.data![index]['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ${snapshot.data![index]['price']}'),
                        Text('Bus ID: ${snapshot.data![index]['busId']}'),
                        Text('User ID: ${snapshot.data![index]['userId']}'),
                        Text('Route ID: ${snapshot.data![index]['routeId']}'),
                        Text('Start Point: ${snapshot.data![index]['busStopStartPoint']}'),
                        Text('End Point: ${snapshot.data![index]['busStopEndPoin']}'),
                        Text('Created At: ${snapshot.data![index]['createdAt']}'),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}