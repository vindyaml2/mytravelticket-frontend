import 'package:flutter/material.dart';
import 'package:mytravelticket_frontend/AssignBusDriverConductorRoutePage.dart';
import 'package:mytravelticket_frontend/GetBusDriverConductorRoutePage.dart';
import 'package:mytravelticket_frontend/DriverFormPage.dart';
import 'package:mytravelticket_frontend/DriverListPage.dart';
import 'package:mytravelticket_frontend/route_list_page.dart';
import 'UserFormPage.dart';
import 'route_input_page.dart';
import 'ConductorFormPage.dart'; // Import the ConductorFormPage
import 'ConductorListPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationPage(),
        '/userForm': (context) => const UserFormPage(),
        '/routeInput': (context) => const RouteInputPage(),
        '/route': (context) => const RouteListPage(),
        '/driverForm': (context) => const DriverFormPage(),
        '/driverList': (context) => const DriverListPage(),
        '/conductorForm': (context) => const ConductorFormPage(), 
        '/conductorList': (context) => const ConductorListPage(),
        '/getBusDriverConductorRoute': (context) => const GetBusDriverConductorRoutePage(),
        '/assignBusDriverConductorRoute': (context) => const AssignBusDriverConductorRoutePage(),
      },
    );
  }
}

class MainNavigationPage extends StatelessWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Navigation', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/userForm');
              },
              child: const Text('Register User'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/routeInput');
              },
              child: const Text('Create a new Bus Route'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/route');
              },
              child: const Text('All Bus Route'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/driverForm');
              },
              child: const Text('Register Driver'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/driverList');
              },
              child: const Text('All Drivers'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/conductorForm');
              },
              child: const Text('Register Conductor'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/conductorList');
              },
              child: const Text('All Conductors'),
            ),
             const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/getBusDriverConductorRoute');
              },
              child: const Text('All assigned BusDriverConductorRoute'),
            ),
             const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/assignBusDriverConductorRoute');
              },
              child: const Text('Assigne BusDriverConductorRoute'),
            ),
          ],
        ),
      ),
    );
  }
}
