import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RoadCondition {
  final String segment;
  final String status;
  final String? note;

  RoadCondition({required this.segment, required this.status, this.note});
}

class RoadService {
  Future<List<RoadCondition>> fetchLiveStatus() async {
    final url = dotenv.env['VEGAGERDIN_FEED_URL'];
    if (url == null || url.isEmpty) {
      return const [];
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      return const [];
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map(
          (entry) => RoadCondition(
            segment: entry['segment'] as String? ?? 'Unknown',
            status: entry['status'] as String? ?? 'open',
            note: entry['note'] as String?,
          ),
        )
        .toList();
  }
}
