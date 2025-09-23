// TODO Implement this library.// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://localhost:8080';

  Future<Map<String, dynamic>> postRouteData(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/route');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode(data);

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to post data with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred during the API call: $e');
    }
  }
}