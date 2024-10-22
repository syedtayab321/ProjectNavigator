import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, String>> notifications = [
    {
      'title': 'Project Approved',
      'message': 'Your project proposal has been approved.',
      'date': '2024-10-19',
    },
    {
      'title': 'Project Rejected',
      'message': 'Your project proposal has been rejected.',
      'date': '2024-10-18',
    },
    {
      'title': 'New Supervisor Assigned',
      'message': 'You have been assigned a new supervisor: Dr. Smith.',
      'date': '2024-10-17',
    },
    {
      'title': 'Submission Reminder',
      'message': 'Don’t forget to submit your project report by next week.',
      'date': '2024-10-16',
    },
    {
      'title': 'Project Discussion Scheduled',
      'message': 'Your project discussion is scheduled for 2024-10-20.',
      'date': '2024-10-15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        foregroundColor: Colors.white,
        title: const Text("Notifications"),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            var notification = notifications[index];
            return Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(
                  notification['title']!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  notification['message']!,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  notification['date']!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  // Handle notification tap if needed
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Clicked on: ${notification['title']}'),
                  ));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
