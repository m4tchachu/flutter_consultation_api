import 'package:flutter/material.dart';
import 'package:flutter_consultation_app/models/consultation.dart';
import 'package:flutter_consultation_app/services/api_services.dart';

class ConsultationProvider with ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Consultation> _data = [];
  List<Consultation> get data => _data;

  bool isLoading = false;

  Future<void> fetchConsultation() async {
    isLoading = true;
    notifyListeners();

    try {
      _data = await apiService.getConsultation();
    } catch (e) {
      debugPrint("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> create(
    String name,
    DateTime date,
    String poli,
    String complaint,
  ) async {
    await apiService.createConsultation(name, date, poli, complaint);

    await fetchConsultation();
  }

  Future<void> update(
    int id,
    String name,
    DateTime date,
    String poli,
    String complaint,
  ) async {
    await apiService.updateConsultation(id, name, date, poli, complaint);

    await fetchConsultation();
  }

  Future<void> delete(int id) async {
    await apiService.deleteConsultation(id);

    await fetchConsultation();
  }
}
