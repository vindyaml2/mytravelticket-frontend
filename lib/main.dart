import 'package:flutter/material.dart';
import 'package:mytravelticket_frontend/route_list_page.dart';
import 'UserFormPage.dart';
import 'route_input_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationPage(),
        '/userForm': (context) => const UserFormPage(),
        '/routeInput': (context) => const RouteInputPage(),
        '/route': (context) => const RouteListPage(),
      },
    );
  }
}

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Main Navigation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Navigate to User Form Page
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/userForm');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Register User'),
            ),
            const SizedBox(height: 30),
            // Navigate to Route Input Page
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/routeInput');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Create a new Bus Route'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/route');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('All Bus Route'),
            ),
          ],
        ),
      ),
    );
  }
}
