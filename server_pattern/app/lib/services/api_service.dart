import 'dart:convert';

import 'package:http/http.dart' as http;

class APIService {
  APIService(this.host);
  final String host;

  Future<String> postInferenceServer(String imageString) async {
    final uri = Uri(
      scheme: 'http',
      host: host,
      port: 8000,
      path: 'predict',
    );
    final requestBody = {'image': imageString};
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    return response.body;
  }
}
