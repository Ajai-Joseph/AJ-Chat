import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<void> sendPushNotification(
    String receiverUserId, String title, String body) async {
  final url = Uri.parse("http://localhost:3000/sendNotification");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": receiverUserId,
        "title": title,
        "body": body,
      }),
    );

    if (response.statusCode == 200) {
      log("Notification sent successfully!");
    } else {
      log("Failed to send notification: ${response.body}");
    }
  } catch (e) {
    log("Error: $e");
  }
}
