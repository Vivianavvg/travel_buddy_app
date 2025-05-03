import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class AttractionDetailScreen extends StatefulWidget {
  final String placeId;

  const AttractionDetailScreen({super.key, required this.placeId});

  @override
  State<AttractionDetailScreen> createState() => _AttractionDetailScreenState();
}

class _AttractionDetailScreenState extends State<AttractionDetailScreen> {
  Map<String, dynamic>? placeDetails;
  bool isLoading = true;

  final String apiKey = 'AIzaSyB4_nauSk3AKwtDoRDoIxTxa8LQjvIel-Y'; // <-- replace with your real API key

  @override
  void initState() {
    super.initState();
    fetchPlaceDetails();
  }

  Future<void> fetchPlaceDetails() async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=${widget.placeId}'
      '&fields=name,rating,formatted_address,formatted_phone_number,website,opening_hours'
      '&key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      setState(() {
        placeDetails = jsonResult['result'];
        isLoading = false;
      });
    } else {
      print('Error fetching place details: ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((placeDetails?['name'] ?? 'Loading...').toString()),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  Text(
                    (placeDetails?['name'] ?? '').toString(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Address: ${(placeDetails?['formatted_address'] ?? 'N/A').toString()}'),
                  const SizedBox(height: 8),
                  Text('Phone: ${(placeDetails?['formatted_phone_number'] ?? 'N/A').toString()}'),
                  const SizedBox(height: 8),

                  // 👇 Clickable Website Text
                  GestureDetector(
                    onTap: () async {
                      final url = placeDetails?['website'];
                      if (url != null && await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open website')),
                        );
                      }
                    },
                    child: Text(
                      'Website: ${(placeDetails?['website'] ?? 'N/A').toString()}',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text('Rating: ${(placeDetails?['rating'] ?? 'N/A').toString()}'),
                  const SizedBox(height: 8),
                  if (placeDetails?['opening_hours'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Opening Hours:'),
                        for (var time in placeDetails?['opening_hours']['weekday_text'])
                          Text('- ${time.toString()}'),
                      ],
                    ),
                ],
              ),
            ),
    );
  }
}


