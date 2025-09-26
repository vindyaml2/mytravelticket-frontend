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
        title: const Text('Route Input', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _routeNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Route Name',
                  hintText: 'e.g., 1A, Airport Express',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
                  : ElevatedButton(
                      onPressed: _getRouteData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text(
                        'Create Bus Route',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}