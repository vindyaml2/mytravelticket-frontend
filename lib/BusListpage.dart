import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Buslistpage extends StatefulWidget {
  const Buslistpage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BuslistpageState();
}

class _BuslistpageState extends State<Buslistpage> {
  Future<List<dynamic>>? _busData;

  @override
  void initState() {
    super.initState();
    _busData = fetchBusData();
  }

  Future<List<dynamic>> fetchBusData() async {
    final response = await http.get(Uri.parse('http://localhost:8080/bus'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load bus data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus List'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _busData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(
                        'Bus ${snapshot.data![index]['registrationNumber']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'ID: ${snapshot.data![index]['id'].toString()}'),
                        Text('Is Running: ${snapshot.data![index]
                            ['isBusOnCoditionAndRunning'] == true ? 'Yes' : 'No'}'),
                        Text('On Duty: ${snapshot.data![index]['isOnDuty'] == true ? 'Yes' : 'No'}'),
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

          // By default, show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}