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
        elevation: 0,
        backgroundColor: Color(0xFF2196F3),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F5F5), Color(0xFFE8F4F8)],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.local_hospital, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text(
                      widget.id == null
                          ? "Pendaftaran Konsultasi Baru"
                          : "Ubah Data Konsultasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              // Form Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Pasien
                      Text(
                        "Nama Pasien",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "Masukkan nama pasien",
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF2196F3),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Tanggal
                      Text(
                        "Tanggal Konsultasi",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFBDBDBD)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: pickDate,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF2196F3),
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      selectedDate == null
                                          ? "Pilih tanggal"
                                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: selectedDate == null
                                            ? Color(0xFF9E9E9E)
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Color(0xFF2196F3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Poli
                      Text(
                        "Pilih Poli",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField(
                        value: selectedPoli,
                        decoration: InputDecoration(
                          hintText: "Pilih poli",
                          prefixIcon: Icon(
                            Icons.local_hospital,
                            color: Color(0xFF2196F3),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2,
                            ),
                          ),
                        ),
                        items: poliList.map((poli) {
                          return DropdownMenuItem(
                            child: Text(poli),
                            value: poli,
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPoli = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Keluhan
                      Text(
                        "Keluhan",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF424242),
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _complaintController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Jelaskan keluhan anda",
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.description,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Color(0xFF2196F3),
                              width: 2,
                            ),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                      SizedBox(height: 28),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      "Simpan",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
