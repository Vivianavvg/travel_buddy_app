import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService{
  final String apiKey = 'AIzaSyB4_nauSk3AKwtDoRDoIxTxa8LQjvIel-Y';

  //fetch attractions near a given latitude and longitude using nearby search API
  Future<List<Map<String, dynamic>>> fetchAttractions(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat, $lng'
      '&radius=3000'
      '&type=tourist_attraction'
      '&key=$apiKey'
    );
    final response = await http.get(url);
    print('APi raw response (nearby): {response.body}');

    if(response.statusCode == 200){
      final json = jsonDecode(response.body);
      List<Map<String,dynamic>> attractions = [];

      for (var result in json['results']){
        attractions.add({
          'name':result['name'],
          'rating': result['rating'],
          'address': result['vicinity'],
          'place_id': result['place_id'],
        });
      }
      return attractions;
    
    }else{
      throw Exception('Failed to load nearby attractions');
    }
  }
  //fetch attractions based on a user-input location string using text search api
  Future<List<Map<String, dynamic>>> fetchAttractionsByQuery(String locationQuery) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/textsearch/json'
      '?query=tourist+attractions+in+$locationQuery'
      '&key=$apiKey',
    );
    final response = await http.get(url);
    print('APi raw response (query): ${response.body}');

    if(response.statusCode == 200){
      final json = jsonDecode(response.body);
      List<Map<String, dynamic>> attractions = [];

      for(var result in json['results']){
        attractions.add({
          'name': result['name'],
          'rating':result['rating'],
          'address': result['formatted_address'],
          'place_id': result['place_id'],
        });
      }
      return attractions;
    } else{
      throw Exception('Failed to load attractions by query');
    }
  }
}
