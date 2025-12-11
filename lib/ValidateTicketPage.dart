import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ValidateTicketPage extends StatefulWidget {
  const ValidateTicketPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ValidateTicketPage();
}

class _ValidateTicketPage extends State<ValidateTicketPage> {
  String scanText = "Enter ticket ID";
  String statusText = "";
  bool isValidating = false;
  final TextEditingController ticketIdController = TextEditingController();

  final String apiBase = "http://localhost:8080/ticket/validate?ticketId=";

  @override
  void dispose() {
    ticketIdController.dispose();
    super.dispose();
  }

  Future<void> validateTicket(String id) async {
    if (id.isEmpty) {
      setState(() => statusText = "❌ Please enter a ticket ID");
      return;
    }

    if (!mounted) return;

    setState(() {
      isValidating = true;
      statusText = "Validating ticket $id ...";
    });

    try {
      final res = await http.get(Uri.parse("$apiBase$id"));

      if (!mounted) return;

      if (res.statusCode == 200 || res.statusCode == 202) {
        try {
          final responseBody = jsonDecode(res.body);
          setState(() => statusText = "✅ Success: Ticket $id is valid!\n\nResponse: ${jsonEncode(responseBody)}");
        } catch (e) {
          setState(() => statusText = "✅ Success: Ticket $id is valid!");
        }
      } else {
        setState(() => statusText = "❌ Failed (${res.statusCode}): ${res.body}");
      }
    } catch (e) {
      setState(() => statusText = "⚠️ Network error: $e");
    }

    if (mounted) {
      setState(() => isValidating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Validate Ticket"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            const Text(
              "Ticket ID",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ticketIdController,
              decoration: InputDecoration(
                hintText: "Enter or paste ticket ID",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                prefixIcon: const Icon(Icons.confirmation_number),
              ),
              keyboardType: TextInputType.number,
              onSubmitted: (value) {
                if (!isValidating) {
                  setState(() => scanText = value);
                  validateTicket(value);
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isValidating
                    ? null
                    : () {
                        final id = ticketIdController.text.trim();
                        if (id.isNotEmpty) {
                          setState(() => scanText = id);
                          validateTicket(id);
                        }
                      },
                icon: const Icon(Icons.check_circle),
                label: const Text("Validate Ticket"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Results Section
            const Text(
              "Validation Result:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    statusText.isEmpty ? "Validation result will appear here" : statusText,
                    style: TextStyle(
                      fontSize: 14,
                      color: statusText.contains("✅") ? Colors.green : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isValidating
                    ? null
                    : () {
                        setState(() {
                          scanText = "Enter ticket ID";
                          statusText = "";
                          ticketIdController.clear();
                        });
                      },
                icon: const Icon(Icons.clear),
                label: const Text("Clear"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
