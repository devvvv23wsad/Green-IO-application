import 'dart:convert';
import 'package:http/http.dart' as http;

class BlynkService {
  final String token;
  final String baseUrl;

  BlynkService({required this.token, this.baseUrl = 'https://blynk.cloud'});

  Future<Map<String, dynamic>> fetchAll() async {
    final url = Uri.parse('$baseUrl/external/api/getAll?token=$token');
    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Blynk API error: ${response.statusCode}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
