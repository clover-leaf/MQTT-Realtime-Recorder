import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmClient {
  FcmClient({
    required http.Client httpClient,
    required this.oneSignKey,
  }) : _httpClient = httpClient;

  final http.Client _httpClient;
  final String oneSignKey;

  Future<void> sendPushNotification({required Map<String, dynamic> payload}) async {
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Basic $oneSignKey',
      'Content-Type': 'application/json'
    };
    final res = await _httpClient.post(
      Uri.https('onesignal.com', 'api/v1/notifications'),
      headers: headers,
      body: jsonEncode(payload),
    );
    print(res);
  }
}
