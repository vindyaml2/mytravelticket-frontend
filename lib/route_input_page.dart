import 'package:flutter/material.dart';
import 'api_service.dart';
import 'route_display_page.dart';

class RouteInputPage extends StatefulWidget {
  const RouteInputPage({Key? key}) : super(key: key);

  @override
  State<RouteInputPage> createState() => _RouteInputPageState();
}

class _RouteInputPageState extends State<RouteInputPage> {
  final TextEditingController _routeNameController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  void _getRouteData() async {
    final routeName = _routeNameController.text;

    if (routeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a route name.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final routeData = await _apiService.postRouteData({
        "routeName": routeName,
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDisplayPage(routeData: routeData),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Input'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _routeNameController,
              decoration: const InputDecoration(
                labelText: 'Enter Route Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _getRouteData,
                    child: const Text('Create Bus Route'),
                  ),
          ],
        ),
      ),
    );
  }
}