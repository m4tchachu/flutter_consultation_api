import 'package:flutter/material.dart';
import 'package:flutter_consultation_app/services/api_services.dart';

class ConsultationFormScreen extends StatefulWidget {
  final int? id;
  final String? name;
  final String? date;
  final String? poli;
  final String? complaint;
  final int? queueNumber;
  const ConsultationFormScreen({
    super.key,
    this.id,
    this.name,
    this.date,
    this.poli,
    this.complaint,
    this.queueNumber,
  });

  @override
  State<ConsultationFormScreen> createState() => _ConsultationFormScreenState();
}

class _ConsultationFormScreenState extends State<ConsultationFormScreen> {
  final _nameController = TextEditingController();
  final _complaintController = TextEditingController();
  final ApiService apiService = ApiService();

  String? selectedPoli;
  DateTime? selectedDate;

  late List<String> poliList;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _nameController.text = widget.name ?? "";
    _complaintController.text = widget.complaint ?? "";
    selectedPoli = widget.poli;

    // Initialize poli list with hardcoded values
    poliList = ["Penyakit Dalam", "Poli Umum", "Poli Gigi", "Poli Anak"];
    
    // Add selected poli from API if not already in list
    if (widget.poli != null && !poliList.contains(widget.poli)) {
      poliList.add(widget.poli!);
    }

    if (widget.date != null) {
      selectedDate = DateTime.parse(widget.date!);
    }
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2027),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void submit() async {
    setState(() => isLoading = true);

    try {
      if (widget.id == null) {
        await apiService.createConsultation(
          _nameController.text,
          selectedDate!,
          selectedPoli!,
          _complaintController.text,
        );
      } else {
        await apiService.updateConsultation(
          widget.id!,
          _nameController.text,
          selectedDate!,
          selectedPoli!,
          _complaintController.text,
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? "Daftar antrian" : "Edit antrian"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nama Pasien"),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "Pilih tanggal"
                        : selectedDate.toString().split(" ")[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: pickDate,
                  child: Text("Pilih tanggal"),
                ),
              ],
            ),
            DropdownButtonFormField(
              value: selectedPoli,
              decoration: InputDecoration(
                labelText: "Pilih poli",
                border: OutlineInputBorder(),
              ),
              items: poliList.map((poli) {
                return DropdownMenuItem(child: Text(poli), value: poli);
              }).toList(),
              onChanged: (value) {
                selectedPoli = value!;
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _complaintController,
              decoration: InputDecoration(labelText: "Keluhan"),
            ),

            ElevatedButton(
              onPressed: isLoading ? null : submit,
              child: isLoading ? CircularProgressIndicator() : Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }
}
