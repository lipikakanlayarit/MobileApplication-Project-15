import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _apiKey = '04a81872d351494ebf3f255963e24087';
  static const String _baseUrl = 'https://newsapi.org/v2/everything?q=mental%20health&apiKey=$_apiKey';

  Future<List> fetchArticles() async {
    final response = await http.get(Uri.parse(_baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['articles'];
    } else {
      throw Exception('Failed to load articles');
    }
  }
}
