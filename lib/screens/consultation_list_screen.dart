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
      appBar: AppBar(
        title: Text('Antrian Klinik'),
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
        child: FutureBuilder<List<Consultation>>(
          future: consultations,
          builder: (builder, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      "Error: ${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Tidak ada data konsultasi",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final colors = [
                  Color(0xFF2196F3),
                  Color(0xFF4CAF50),
                  Color(0xFFFF9800),
                  Color(0xFF9C27B0),
                ];
                final cardColor = colors[index % colors.length];

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Material(
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConsultationFormScreen(
                                  id: item.id,
                                  complaint: item.complaint,
                                  date: DateFormat(
                                    "yyyy-MM-dd",
                                  ).format(item.date),
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
                              title: Text("Hapus Data Konsultasi?"),
                              content: Text(
                                "Data ${item.name} akan dihapus secara permanen.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () => deleteData(item.id),
                                  child: Text(
                                    "Hapus",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              // Left Colored Strip
                              Container(
                                width: 5,
                                height: 140,
                                color: cardColor,
                              ),
                              // Queue Number Circle
                              Container(
                                margin: EdgeInsets.only(left: 16),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: cardColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "No.",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: cardColor,
                                        ),
                                      ),
                                      Text(
                                        "${item.queueNumber}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: cardColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Content
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212121),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_hospital,
                                            size: 14,
                                            color: cardColor,
                                          ),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item.poli,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Color(0xFF757575),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 12,
                                            color: Color(0xFF2196F3),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            DateFormat(
                                              "dd MMM yyyy",
                                            ).format(item.date),
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF2196F3),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 6),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: cardColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          item.complaint.length > 25
                                              ? "${item.complaint.substring(0, 25)}..."
                                              : item.complaint,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF424242),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Edit Icon
                              Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFFBDBDBD),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2196F3),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConsultationFormScreen()),
          );

          if (result == true) {
            refreshData();
          }
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
