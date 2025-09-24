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
  
  Future<void> createBusStop(
    int routeId,
    String stopName,
    int busStopOrder, {
    bool? isBusStopSource,
    bool? isBusStopInMiddle,
    bool? isBusStopDestination,
  }) async {
    final url = "http://localhost:8080/bus-stop";
    final body = jsonEncode({
      "stopName": stopName,
      "isBusStopSource": isBusStopSource ?? false,
      "isBusStopInMiddle": isBusStopInMiddle ?? false,
      "isBusStopDestination": isBusStopDestination ?? false,
      "busStopOrder": busStopOrder,
      "routeStops": [{"id": routeId}]
    });
    final response = await http.post(Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create bus stop, status code: ${response.statusCode}');
    }
  }
  
  Future<void> deleteBusStop(int busStopId) async {
    final url = "http://localhost:8080/bus-stop?busStopId=$busStopId";
    final response = await http.delete(Uri.parse(url), headers: {'accept': '*/*'});
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete bus stop, status code: ${response.statusCode}');
    }
  }

  // New function for updating a bus stop using PUT API
  Future<void> updateBusStop({
    required int id,
    required String stopName,
    required bool isBusStopSource,
    required bool isBusStopInMiddle,
    required bool isBusStopDestination,
    required int busStopOrder,
    double latitude = 0,
    double longitude = 0,
  }) async {
    final url = "http://localhost:8080/bus-stop";
    final body = jsonEncode({
      "id": id,
      "stopName": stopName,
      "isBusStopSource": isBusStopSource,
      "isBusStopInMiddle": isBusStopInMiddle,
      "isBusStopDestination": isBusStopDestination,
      "latitude": latitude,
      "longitude": longitude,
      "busStopOrder": busStopOrder,
    });
    final response = await http.put(Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json'
        },
        body: body);
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update bus stop, status code: ${response.statusCode}');
    }
  }

  void showAddBusStopDialog(BuildContext context, int routeId, VoidCallback refreshStops) {
    final stopNameController = TextEditingController();
    final busStopOrderController = TextEditingController();
    bool isBusStopSource = false;
    bool isBusStopInMiddle = false;
    bool isBusStopDestination = false;
  
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Bus Stop'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: stopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Stop Name *',
                      ),
                    ),
                    TextField(
                      controller: busStopOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Bus Stop Order *',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Source'),
                      value: isBusStopSource,
                      onChanged: (val) => setState(() { isBusStopSource = val ?? false; }),
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop In Middle'),
                      value: isBusStopInMiddle,
                      onChanged: (val) => setState(() { isBusStopInMiddle = val ?? false; }),
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Destination'),
                      value: isBusStopDestination,
                      onChanged: (val) => setState(() { isBusStopDestination = val ?? false; }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () { Navigator.of(context).pop(); },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final stopName = stopNameController.text.trim();
                    final orderText = busStopOrderController.text.trim();
                    if (stopName.isEmpty || orderText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in required fields.'))
                      );
                      return;
                    }
                    final busStopOrder = int.tryParse(orderText);
                    if (busStopOrder == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bus Stop Order must be a number.'))
                      );
                      return;
                    }
                    try {
                      await createBusStop(
                        routeId,
                        stopName,
                        busStopOrder,
                        isBusStopSource: isBusStopSource,
                        isBusStopInMiddle: isBusStopInMiddle,
                        isBusStopDestination: isBusStopDestination,
                      );
                      Navigator.of(context).pop();
                      refreshStops();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()))
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  // New method to show update dialog with prefilled bus stop details
  void showUpdateBusStopDialog(BuildContext context, dynamic stop, VoidCallback refreshStops) {
    final stopNameController = TextEditingController(text: stop['stopName'].toString());
    final busStopOrderController = TextEditingController(text: stop['busStopOrder'].toString());
    bool isBusStopSource = stop['isBusStopSource'] ?? false;
    bool isBusStopInMiddle = stop['isBusStopInMiddle'] ?? false;
    bool isBusStopDestination = stop['isBusStopDestination'] ?? false;
  
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Bus Stop'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: stopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Stop Name *',
                      ),
                    ),
                    TextField(
                      controller: busStopOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Bus Stop Order *',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Source'),
                      value: isBusStopSource,
                      onChanged: (val) => setState(() { isBusStopSource = val ?? false; }),
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop In Middle'),
                      value: isBusStopInMiddle,
                      onChanged: (val) => setState(() { isBusStopInMiddle = val ?? false; }),
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Destination'),
                      value: isBusStopDestination,
                      onChanged: (val) => setState(() { isBusStopDestination = val ?? false; }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () { Navigator.of(context).pop(); },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final stopName = stopNameController.text.trim();
                    final orderText = busStopOrderController.text.trim();
                    if (stopName.isEmpty || orderText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in required fields.'))
                      );
                      return;
                    }
                    final busStopOrder = int.tryParse(orderText);
                    if (busStopOrder == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bus Stop Order must be a number.'))
                      );
                      return;
                    }
                    try {
                      await updateBusStop(
                        id: stop['id'],
                        stopName: stopName,
                        isBusStopSource: isBusStopSource,
                        isBusStopInMiddle: isBusStopInMiddle,
                        isBusStopDestination: isBusStopDestination,
                        busStopOrder: busStopOrder,
                      );
                      Navigator.of(context).pop();
                      refreshStops();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString()))
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      }
    );
  }
  
  void showRouteStops(BuildContext context, int routeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        Future<List<dynamic>> stopsFuture = fetchBusStops(routeId);
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with beautified add button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bus Stops',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          showAddBusStopDialog(context, routeId, () {
                            setState(() {
                              stopsFuture = fetchBusStops(routeId);
                            });
                          });
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Bus Stop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 10, 0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: stopsFuture,
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
                              leading: const Icon(Icons.directions_bus, color: Colors.teal),
                              title: Text(stop['stopName'].toString()),
                              subtitle: Text("Order: ${stop['busStopOrder']}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      showUpdateBusStopDialog(context, stop, () {
                                        setState(() {
                                          stopsFuture = fetchBusStops(routeId);
                                        });
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      try {
                                        await deleteBusStop(stop['id']);
                                        setState(() {
                                          stopsFuture = fetchBusStops(routeId);
                                        });
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString()))
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            // Logo (replace with your asset or widget)
            const Icon(Icons.directions_bus, size: 28),
            const SizedBox(width: 8),
            const Text('Route List'),
          ],
        ),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
