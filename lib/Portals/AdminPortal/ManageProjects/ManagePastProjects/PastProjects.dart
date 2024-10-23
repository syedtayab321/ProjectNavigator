import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'PastProjectsAccordingtosession.dart';

class AdminPastProjectsPage extends StatefulWidget {
  AdminPastProjectsPage({super.key});

  @override
  _AdminPastProjectsPageState createState() => _AdminPastProjectsPageState();
}

class _AdminPastProjectsPageState extends State<AdminPastProjectsPage> {
  final List<String> sessions = [
    '2024-2028', '2023-2027', '2022-2026', '2021-2025', '2020-2024', '2019-2023', '2018-2022',
    '2017-2021', '2016-2020', '2015-2019', '2014-2018', '2013-2017', '2012-2016', '2011-2015',
    '2010-2014',
  ];

  List<String> filteredSessions = [];

  @override
  void initState() {
    super.initState();
    filteredSessions = sessions;
  }

  void _filterSessions(String query) {
    setState(() {
      filteredSessions = sessions
          .where((session) => session.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const CustomTextWidget(title: 'Past Projects'),
        backgroundColor: Colors.tealAccent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: _filterSessions,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Search session...',
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSessions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => AdminPastProjectListScreen(session: filteredSessions[index]));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [Colors.tealAccent.shade400, Colors.teal],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.2),
                            spreadRadius: 3,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.teal.shade700,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          filteredSessions[index],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          'Tap to explore projects',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
