import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StudentFeedbacksScreen extends StatefulWidget {
  @override
  _StudentFeedbacksScreenState createState() => _StudentFeedbacksScreenState();
}

class _StudentFeedbacksScreenState extends State<StudentFeedbacksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Feedbacks'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'All Feedbacks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildFeedbackList()),
          ],
        ),
      ),
    );
  }

  // Build the feedback list from Firestore
  Widget _buildFeedbackList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('studentFeedbacks').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading feedbacks.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No feedbacks available.'));
        }

        var feedbacks = snapshot.data!.docs;

        return ListView.builder(
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            var feedbackData = feedbacks[index].data() as Map<String, dynamic>;
            return _buildFeedbackCard(feedbackData);
          },
        );
      },
    );
  }

  // Build a card widget to display each feedback
  Widget _buildFeedbackCard(Map<String, dynamic> feedbackData) {
    // Convert Timestamp to Date String
    Timestamp timestamp = feedbackData['timestamp'];
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.person, 'Student', feedbackData['studentName']),
            const Divider(thickness: 1, color: Colors.grey),
            _buildDetailRow(Icons.feedback, 'Feedback', feedbackData['feedback']),
            const Divider(thickness: 1, color: Colors.grey),
            _buildDetailRow(Icons.star, 'Rating', '${feedbackData['rating']} / 5'),
            const Divider(thickness: 1, color: Colors.grey),
            _buildDetailRow(Icons.date_range, 'Submitted On', formattedDate),
          ],
        ),
      ),
    );
  }

  // Reusable widget to show the details in the feedback card
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
