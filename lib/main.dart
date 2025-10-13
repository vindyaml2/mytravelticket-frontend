import 'package:flutter/material.dart';
import 'package:mytravelticket_frontend/AssignBusDriverConductorRoutePage.dart';
import 'package:mytravelticket_frontend/GetBusDriverConductorRoutePage.dart';
import 'package:mytravelticket_frontend/DriverFormPage.dart';
import 'package:mytravelticket_frontend/DriverListPage.dart';
import 'package:mytravelticket_frontend/TicketListForUserPage.dart';
import 'package:mytravelticket_frontend/TicketListPage.dart';
import 'package:mytravelticket_frontend/route_list_page.dart';
import 'UserFormPage.dart';
import 'route_input_page.dart';
import 'ConductorFormPage.dart'; // Import the ConductorFormPage
import 'ConductorListPage.dart';
import 'TicketPage.dart';
import 'BusPage.dart';
import 'BusListpage.dart';

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
        '/ticket':(context) => const TicketPage(),
        '/get-all-ticket':(context) => const TicketListPage(),
        '/ticket-userid':(context) => const TicketListForUserPage(),
        '/bus': (context) => const Buspage(),
        '/buslist': (context) => const Buslistpage(),

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/userForm', 'Register User'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/routeInput', 'Create a new Bus Route'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/route', 'All Bus Route'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/driverForm', 'Register Driver'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/driverList', 'All Drivers'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/conductorForm', 'Register Conductor'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/conductorList', 'All Conductors'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/getBusDriverConductorRoute', 'All assigned BusDriverConductorRoute'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/assignBusDriverConductorRoute', 'Assign BusDriverConductorRoute'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/ticket', 'Create Ticket'),
                ),
              ),
              const SizedBox(height: 16),
               Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/get-all-ticket', 'Get All Ticket'),
                ),
              ),
              const SizedBox(height: 16),
               Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/ticket-userid', 'Get All Ticket for User' ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/bus', 'Create Bus'),
                ),
              ),
               const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: _buildNavigationCard(context, '/buslist', 'Get all Bus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationCard(BuildContext context, String routeName, String buttonText) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, routeName);
          },
          child: Text(buttonText),
        ),
      ),
    );
  }
}
