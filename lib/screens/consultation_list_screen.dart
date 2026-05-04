import 'package:flutter_consultation_app/models/consultation.dart';
import 'package:flutter_consultation_app/services/api_services.dart';
import 'package:flutter_consultation_app/screens/consultation_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConsultationListScreen extends StatefulWidget {
  const ConsultationListScreen({super.key});

  @override
  State<ConsultationListScreen> createState() => _ConsultationListScreenState();
}

class _ConsultationListScreenState extends State<ConsultationListScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Consultation>> consultations;

  void refreshData() {
    setState(() {
      consultations = apiService.getConsultation();
    });
  }

  @override
  void initState() {
    super.initState();
    consultations = apiService.getConsultation();
  }

  void deleteData(int id) async {
    Navigator.pop(context);
    await apiService.deleteConsultation(id);
    refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Antrian Klinik')),
      body: FutureBuilder<List<Consultation>>(
        future: consultations,
        builder: (builder, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error ${snapshot.error}"));
          }

          final data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];

              return Card(
                child: ListTile(
                  isThreeLine: true,
                  contentPadding: EdgeInsets.all(10),
                  leading: Text(DateFormat("dd MMM").format(item.date)),
                  trailing: Text(
                    "${item.queueNumber}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  title: Text(item.name),
                  subtitle: Text("${item.poli} - ${item.complaint}"),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConsultationFormScreen(
                          id: item.id,
                          complaint: item.complaint,
                          date: DateFormat("yyyy-MM-dd").format(item.date),
                          name: item.name,
                          poli: item.poli,
                        ),
                      ),
                    );
                    if (result == true) refreshData();
                  },
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text("Apakah kamu mau menghapus data ini?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () => deleteData(item.id),
                          child: Text("Hapus"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConsultationFormScreen()),
          );

          if (result == true) {
            refreshData();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
