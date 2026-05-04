import 'package:flutter_consultation_app/screens/consultation_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/consultation_provider.dart';

class ConsultationListScreen extends StatefulWidget {
  const ConsultationListScreen({super.key});

  @override
  State<ConsultationListScreen> createState() => _ConsultationListScreenState();
}

class _ConsultationListScreenState extends State<ConsultationListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ConsultationProvider>().fetchConsultation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConsultationProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Antrian Klinik')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.data.length,
              itemBuilder: (context, index) {
                final item = provider.data[index];
                return Card(
                  child: ListTile(
                    isThreeLine: true,
                    contentPadding: EdgeInsets.all(10),
                    leading: Text(DateFormat("dd MMM").format(item.date)),
                    trailing: Text(
                      "${item.queueNumber}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                      if (result == true) provider.fetchConsultation();
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
                            onPressed: () => provider.delete(item.id),
                            child: Text("Hapus"),
                          ),
                        ],
                      ),
                    ),
                  ),
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
            provider.fetchConsultation();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
