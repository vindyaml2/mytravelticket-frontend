import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:mytravelticket_frontend/select_location_page.dart';

class RouteListPage extends StatefulWidget {
  const RouteListPage({Key? key}) : super(key: key);

  @override
  RouteListPageState createState() => RouteListPageState();
}

class RouteListPageState extends State<RouteListPage> {
  Future<List<dynamic>> fetchRoutes() async {
    try {
      final baseUrl = "http://localhost:8080/route";
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'accept': '*/*'},
      );
      if (response.statusCode == 202) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        throw Exception('Failed to load routes, status code: ${response.statusCode}');
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
        return data is List ? data : [];
      } else {
        throw Exception('Failed to load bus stops, status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception("Failed to load bus stops: $error");
    }
  }

  Future<dynamic> fetchBusStopDetails(int busStopId) async {
    try {
      final url = "http://localhost:8080/bus-stop/id?busStopId=$busStopId";
      final response = await http.get(
        Uri.parse(url),
        headers: {'accept': '*/*'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load bus stop details, status code: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception("Failed to load bus stop details: $error");
    }
  }

  Future<void> openMap(double latitude, double longitude, String stopName) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude&query_place_id=$stopName';
    final Uri url = Uri.parse(googleUrl);
    if (await url_launcher.canLaunchUrl(url)) {
      await url_launcher.launchUrl(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> createBusStop(
    int routeId,
    String stopName,
    int busStopOrder, {
    bool? isBusStopSource,
    bool? isBusStopInMiddle,
    bool? isBusStopDestination,
    double? latitude,
    double? longitude,
  }) async {
    final url = "http://localhost:8080/bus-stop";
    final body = jsonEncode({
      "stopName": stopName,
      "isBusStopSource": isBusStopSource ?? false,
      "isBusStopInMiddle": isBusStopInMiddle ?? false,
      "isBusStopDestination": isBusStopDestination ?? false,
      "busStopOrder": busStopOrder,
      "latitude": latitude ?? 0,
      "longitude": longitude ?? 0,
      "routeStops": [{"id": routeId}]
    });
    final response = await http.post(
      Uri.parse(url),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create bus stop, status code: ${response.statusCode}');
    }
  }

  Future<void> deleteBusStop(int busStopId) async {
    final url = "http://localhost:8080/bus-stop?busStopId=$busStopId";
    final response = await http.delete(
      Uri.parse(url),
      headers: {'accept': '*/*'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete bus stop, status code: ${response.statusCode}');
    }
  }

  Future<void> updateBusStop({
    required int id,
    required String stopName,
    required bool isBusStopSource,
    required bool isBusStopInMiddle,
    required bool isBusStopDestination,
    required int busStopOrder,
    double? latitude,
    double? longitude,
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
    final response = await http.put(
      Uri.parse(url),
      headers: {'accept': '*/*', 'Content-Type': 'application/json'},
      body: body,
    );
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
    double? selectedLatitude;
    double? selectedLongitude;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Bus Stop', style: TextStyle(color: Colors.teal)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: stopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Stop Name *',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      ),
                    ),
                    TextField(
                      controller: busStopOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Bus Stop Order *',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () async {
                        final location = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SelectLocationPage()),
                        );
                        if (location != null && location is Map) {
                          setState(() {
                            selectedLatitude = location['latitude'];
                            selectedLongitude = location['longitude'];
                          });
                        }
                      },
                      child: const Text('Select Location', style: TextStyle(color: Colors.white)),
                    ),
                    if (selectedLatitude != null && selectedLongitude != null)
                      Text('Selected: ($selectedLatitude, $selectedLongitude)', style: const TextStyle(color: Colors.teal)),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Source', style: TextStyle(color: Colors.grey)),
                      value: isBusStopSource,
                      onChanged: (val) => setState(() => isBusStopSource = val ?? false),
                      activeColor: Colors.teal,
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop In Middle', style: TextStyle(color: Colors.grey)),
                      value: isBusStopInMiddle,
                      onChanged: (val) => setState(() => isBusStopInMiddle = val ?? false),
                      activeColor: Colors.teal,
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Destination', style: TextStyle(color: Colors.grey)),
                      value: isBusStopDestination,
                      onChanged: (val) => setState(() => isBusStopDestination = val ?? false),
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () async {
                    final stopName = stopNameController.text.trim();
                    final orderText = busStopOrderController.text.trim();
                    if (stopName.isEmpty || orderText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in required fields.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final busStopOrder = int.tryParse(orderText);
                    if (busStopOrder == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bus Stop Order must be a number.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
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
                        latitude: selectedLatitude,
                        longitude: selectedLongitude,
                      );
                      Navigator.of(context).pop();
                      refreshStops();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Create', style: TextStyle(color: Colors.white)),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            );
          },
        );
      },
    );
  }

  void showUpdateBusStopDialog(BuildContext context, dynamic stop, VoidCallback refreshStops) {
    final stopNameController = TextEditingController(text: stop['stopName'].toString());
    final busStopOrderController = TextEditingController(text: stop['busStopOrder'].toString());
    bool isBusStopSource = stop['isBusStopSource'] ?? false;
    bool isBusStopInMiddle = stop['isBusStopInMiddle'] ?? false;
    bool isBusStopDestination = stop['isBusStopDestination'] ?? false;
    double? selectedLatitude = stop['latitude'] != null ? double.tryParse(stop['latitude'].toString()) : null;
    double? selectedLongitude = stop['longitude'] != null ? double.tryParse(stop['longitude'].toString()) : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Bus Stop', style: TextStyle(color: Colors.teal)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: stopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Stop Name *',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      ),
                    ),
                    TextField(
                      controller: busStopOrderController,
                      decoration: const InputDecoration(
                        labelText: 'Bus Stop Order *',
                        labelStyle: TextStyle(color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () async {
                        final location = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SelectLocationPage()),
                        );
                        if (location != null && location is Map) {
                          setState(() {
                            selectedLatitude = location['latitude'];
                            selectedLongitude = location['longitude'];
                          });
                        }
                      },
                      child: const Text('Select Location', style: TextStyle(color: Colors.white)),
                    ),
                    if (selectedLatitude != null && selectedLongitude != null)
                      Text('Selected: ($selectedLatitude, $selectedLongitude)', style: const TextStyle(color: Colors.teal)),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Source', style: TextStyle(color: Colors.grey)),
                      value: isBusStopSource,
                      onChanged: (val) => setState(() => isBusStopSource = val ?? false),
                      activeColor: Colors.teal,
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop In Middle', style: TextStyle(color: Colors.grey)),
                      value: isBusStopInMiddle,
                      onChanged: (val) => setState(() => isBusStopInMiddle = val ?? false),
                      activeColor: Colors.teal,
                    ),
                    CheckboxListTile(
                      title: const Text('Is Bus Stop Destination', style: TextStyle(color: Colors.grey)),
                      value: isBusStopDestination,
                      onChanged: (val) => setState(() => isBusStopDestination = val ?? false),
                      activeColor: Colors.teal,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () async {
                    final stopName = stopNameController.text.trim();
                    final orderText = busStopOrderController.text.trim();
                    if (stopName.isEmpty || orderText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in required fields.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    final busStopOrder = int.tryParse(orderText);
                    if (busStopOrder == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bus Stop Order must be a number.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
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
                        latitude: selectedLatitude,
                        longitude: selectedLongitude,
                      );
                      Navigator.of(context).pop();
                      refreshStops();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: const Text('Update', style: TextStyle(color: Colors.white)),
                ),
              ],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
            const Icon(Icons.directions_bus, size: 28, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Route List', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes found.', style: TextStyle(color: Colors.grey)));
          }
          final routes = snapshot.data!;
          return ListView.builder(
            itemCount: routes.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final route = routes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: InkWell(
                  onTap: () => showRouteStops(context, route['id']),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          route['routeName'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.teal),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new route logic
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void showRouteStops(BuildContext context, int routeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<List<dynamic>> stopsFuture = fetchBusStops(routeId);
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bus Stops', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add Stop', style: TextStyle(fontSize: 16)),
                        onPressed: () {
                          showAddBusStopDialog(context, routeId, () {
                            setState(() {
                              stopsFuture = fetchBusStops(routeId);
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: stopsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)));
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No bus stops found.', style: TextStyle(color: Colors.grey)));
                        }
                        final stops = snapshot.data!;
                        return ListView.separated(
                          itemCount: stops.length,
                          separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 1),
                          itemBuilder: (context, index) {
                            final stop = stops[index];
                            return ListTile(
                              leading: const Icon(Icons.directions_bus, color: Colors.teal, size: 30),
                              title: Text(stop['stopName'].toString(), style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal)),
                              subtitle: Text("Order: ${stop['busStopOrder']}", style: const TextStyle(color: Colors.grey)),
                              onTap: () async {
                                try {
                                  final busStopDetails = await fetchBusStopDetails(stop['id']);
                                  if (busStopDetails != null) {
                                    double latitude = busStopDetails['latitude'];
                                    double longitude = busStopDetails['longitude'];
                                    String stopName = busStopDetails['stopName'];
                                    await openMap(latitude, longitude, stopName);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Failed to load bus stop details', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                                  );
                                }
                              },
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
                                      bool? confirmDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm Delete', style: TextStyle(color: Colors.teal)),
                                            content: const Text('Are you sure you want to delete this bus stop?', style: TextStyle(color: Colors.grey)),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (confirmDelete == true) {
                                        try {
                                          await deleteBusStop(stop['id']);
                                          setState(() {
                                            stopsFuture = fetchBusStops(routeId);
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                                          );
                                        }
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
}
