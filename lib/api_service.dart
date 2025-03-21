import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String sheetId = 'YOUR_SHEET_ID'; // Replace with your Sheet ID
  static const String apiKey = 'YOUR_API_KEY'; // Replace with your API Key
  static const String sheetName = 'Sheet1'; // Replace with your sheet name

  // Fetch data from Google Sheets
  static Future<List<Map<String, String>>> fetchData() async {
    final url =
        'https://sheets.googleapis.com/v4/spreadsheets/19hEg48VxYr7Nxrz0JyhZgELAECB5NnJ9xFg3OssX0CA/values/Sheet1?key=AIzaSyDNyUd4quB05nXKloxrlkB4ukqp-akQsQ8';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rows = data['values'];

        // Cache the data locally
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('cachedData', json.encode(rows));

        return _parseData(rows);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Parse the data into a list of maps
  static List<Map<String, String>> _parseData(List<dynamic> rows) {
    final List<Map<String, String>> items = [];
    for (var i = 1; i < rows.length; i++) {
      // Skip the header row (i = 0)
      items.add({
        'Item Name': rows[i][0],
        'Price': rows[i][1],
        'Category': rows[i][2],
        'Description': rows[i][3],
      });
    }
    return items;
  }

  // Get cached data
  static Future<List<Map<String, String>>> getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedData');
    if (cachedData != null) {
      final rows = json.decode(cachedData) as List<dynamic>;
      return _parseData(rows);
    }
    return [];
  }
}
