import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // added to detect platform

class RouteListPage extends StatelessWidget {
  const RouteListPage({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchRoutes() async {
    try {
      final baseUrl = "http://localhost:8080/route"; 
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'accept': '*/*'},
      );
      if (response.statusCode == 202) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        throw Exception(
            'Failed to load routes, status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception("Failed to load routes: $error");
    }
  }
  
  Future<List<dynamic>> fetchBusStops(int routeId) async {
    try {
      final stopsUrl = "http://localhost:8080/route/stops?routeId=$routeId";
      final response = await http.get(
        Uri.parse(stopsUrl),
        headers: {'accept': '*/*'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          return data;
        } else {
          return [];
        }
      } else {
        throw Exception(
            'Failed to load bus stops, status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception("Failed to load bus stops: $error");
    }
  }
  
  void showRouteStops(BuildContext context, int routeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Bus Stops',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: fetchBusStops(routeId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No bus stops found.'));
                    }
                    final stops = snapshot.data!;
                    return ListView.builder(
                      itemCount: stops.length,
                      itemBuilder: (context, index) {
                        final stop = stops[index];
                        return ListTile(
                          leading: const Icon(Icons.directions_bus),
                          title: Text(stop['stopName'].toString()),
                          subtitle: Text("Order: ${stop['busStopOrder']}"),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route List'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes found.'));
          }
          final routes = snapshot.data!;
          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    route['routeName'].toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => showRouteStops(context, route['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
