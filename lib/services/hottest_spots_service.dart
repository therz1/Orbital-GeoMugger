import 'dart:convert';
import 'package:http/http.dart' as http;

class HottestSpotsService {
  // note change apiUrl to ur own ip address if you are doing a local host!
  final String _apiUrl = 'http://192.168.18.13:8000/hottest-spots?n=5';
  Future<List<String>> fetchHottestSpotIds() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if(response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> ids = data["hottest_spot_ids"];
        print("debug: $ids");
        return List<String>.from(ids);
      }
      return [];
    } catch (e) {
      print("error fetching hottest spots from python $e");
      return [];
    }
    }
  }
