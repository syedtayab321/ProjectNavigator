import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Notifications').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error fetching notifications'));
            }
            if (!snapshot.hasData) {
              return const Center(
                  child: CustomTextWidget(
                    title: 'No data available',
                    color: Colors.black,
                  ));
            }
            final notifications = snapshot.data?.docs ?? [];
            return ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                var notificationData = notifications[index].data() as Map<String, dynamic>;
                return NotificationCard(notificationData);
              },
            );
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationCard(this.notification, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert Firestore Timestamp to a readable string format
    String formattedTimestamp = _formatTimestamp(notification['timestamp']);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          notification['From'] ?? 'No Title',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        subtitle: Text(
          notification['Message'] ?? 'No Message',
          style: const TextStyle(fontSize: 16),
        ),
        trailing: Text(
          formattedTimestamp,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Clicked on: ${notification['From']}'),
          ));
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());
  }
}
