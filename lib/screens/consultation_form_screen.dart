import 'package:flutter/material.dart';
import 'package:flutter_consultation_app/providers/consultation_provider.dart';
import 'package:provider/provider.dart';


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

  String? selectedPoli;
  DateTime? selectedDate;

  late List<String> poliList;

  bool isLoading = false;
  String? nameError;
  String? dateError;
  String? poliError;
  String? complaintError;

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
        dateError = null;
      });
    }
  }

  bool validateForm() {
    bool isValid = true;
    setState(() {
      nameError = _nameController.text.isEmpty
          ? "Nama tidak boleh kosong"
          : null;
      dateError = selectedDate == null ? "Pilih tanggal terlebih dahulu" : null;
      poliError = selectedPoli == null ? "Pilih poli terlebih dahulu" : null;
      complaintError = _complaintController.text.isEmpty
          ? "Keluhan tidak boleh kosong"
          : null;
    });

    if (nameError != null ||
        dateError != null ||
        poliError != null ||
        complaintError != null) {
      isValid = false;
    }
    return isValid;
  }

  void submit() async {
    final provider = context.read<ConsultationProvider>();
    if (!validateForm()) {
      return;
    }

    setState(() => isLoading = true);

    try {
      if (widget.id == null) {
        await provider.create(
          _nameController.text,
          selectedDate!,
          selectedPoli!,
          _complaintController.text,
        );
      } else {
        await provider.update(
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
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? "Daftar Antrian" : "Edit antrian"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nama Pasien
              TextField(
                controller: _nameController,
                onChanged: (value) {
                  if (value.isNotEmpty && nameError != null) {
                    setState(() => nameError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: "Nama Pasien",
                  labelStyle: TextStyle(
                    color: nameError != null ? Colors.red : Colors.black87,
                    fontWeight: nameError != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  errorText: nameError,
                  errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: nameError != null ? Colors.red : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              SizedBox(height: 24),

              // Tanggal
              Text(
                "Pilih tanggal",
                style: TextStyle(
                  fontSize: 14,
                  color: dateError != null ? Colors.red : Colors.black87,
                  fontWeight: dateError != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
              GestureDetector(
                onTap: pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: dateError != null
                            ? Colors.red
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedDate == null
                            ? "Pilih tanggal"
                            : "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}",
                        style: TextStyle(fontSize: 14, color: Colors.blue),
                      ),
                      Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                    ],
                  ),
                ),
              ),
              if (dateError != null)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    dateError!,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              SizedBox(height: 24),

              // Poli
              Text(
                "Pilih poli",
                style: TextStyle(
                  fontSize: 14,
                  color: poliError != null ? Colors.red : Colors.black87,
                  fontWeight: poliError != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
              DropdownButtonFormField(
                value: selectedPoli,
                decoration: InputDecoration(
                  errorText: poliError,
                  errorStyle: TextStyle(fontSize: 12),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: poliError != null ? Colors.red : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                isExpanded: true,
                items: poliList.map((poli) {
                  return DropdownMenuItem(child: Text(poli), value: poli);
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPoli = value;
                    if (value != null && poliError != null) {
                      poliError = null;
                    }
                  });
                },
              ),
              SizedBox(height: 24),

              // Keluhan
              TextField(
                controller: _complaintController,
                onChanged: (value) {
                  if (value.isNotEmpty && complaintError != null) {
                    setState(() => complaintError = null);
                  }
                },
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Keluhan",
                  labelStyle: TextStyle(
                    color: complaintError != null ? Colors.red : Colors.black87,
                    fontWeight: complaintError != null
                        ? FontWeight.w500
                        : FontWeight.normal,
                  ),
                  errorText: complaintError,
                  errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: complaintError != null
                          ? Colors.red
                          : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 32),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Simpan",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
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
