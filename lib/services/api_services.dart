import 'package:flutter_consultation_app/models/consultation.dart';
import 'package:flutter_consultation_app/models/consultation_response.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:intl/intl.dart';

class ApiService {
  final String baseUrl = "https://user.ahay.my.id/consultations";

  Future<List<Consultation>> getConsultation() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final result = ConsultationResponse.fromJson(json);
      return result.data;
    } else {
      throw Exception("Failed to load data");
    }
  }

  Future<void> createConsultation(
    String name,
    DateTime date,
    String poli,
    String complaint,
  ) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "date": date.toIso8601String(),
        "poli": poli,
        "complaint": complaint,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to post data");
    }
  }

  Future<void> updateConsultation(
    int id,
    String name,
    DateTime date,
    String poli,
    String complaint,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "date": DateFormat("yyyy-MM-dd").format(date),
        "poli": poli,
        "complaint": complaint,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to post data");
    }
  }

  Future<void> deleteConsultation(int id) async {
    final response = await http.delete(Uri.parse("$baseUrl/$id"));

    if (response.statusCode != 200) {
      throw Exception("Failed to post data");
    }
  }
}