import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminProjectRequestsScreen extends StatefulWidget {
  @override
  _AdminProjectRequestsScreenState createState() =>
      _AdminProjectRequestsScreenState();
}

class _AdminProjectRequestsScreenState
    extends State<AdminProjectRequestsScreen> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilterButtons(),
            const SizedBox(height: 16),
            Expanded(child: _buildProjectRequestList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Makes buttons scrollable for responsiveness
      child: Row(
        children: [
          _buildFilterButton('All', null),
          _buildFilterButton('Approved', 'approved'),
          _buildFilterButton('Rejected', 'rejected'),
          _buildFilterButton('Pending', 'pending'),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _statusFilter = status;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _statusFilter == status ? Colors.teal : Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label),
      ),
    );
  }

  // Build the list of project requests
  Widget _buildProjectRequestList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('projectRequests').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading project requests.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No project requests found.'));
        }

        var projects = snapshot.data!.docs;

        // Apply status filter
        if (_statusFilter != null) {
          projects = projects.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return data['status'] == _statusFilter;
          }).toList();
        }

        return ListView.builder(
          itemCount: projects.length,
          itemBuilder: (context, index) {
            var projectData = projects[index].data() as Map<String, dynamic>;
            return _buildProjectCard(projectData, projects[index].id); // Pass project ID to update status later
          },
        );
      },
    );
  }

  // Build a card widget to display each project request
  Widget _buildProjectCard(Map<String, dynamic> projectData, String projectId) {
    // Convert Timestamp to Date String
    Timestamp timestamp = projectData['timestamp'];
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(timestamp.toDate());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.assignment, 'Project Name', projectData['projectName']),
            const Divider(thickness: 1, color: Colors.grey),
            _buildDetailRow(Icons.person, 'Requester', projectData['studentName']),
            const Divider(thickness: 1, color: Colors.grey),
            _buildDetailRow(Icons.date_range, 'Requested On', formattedDate),
            const Divider(thickness: 1, color: Colors.grey),
            _buildDetailRow(Icons.label, 'Status', projectData['status'].toUpperCase()),
            const Divider(thickness: 1, color: Colors.grey),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     if (projectData['status'] == 'pending' || projectData['status'] == 'rejected')
            //       ElevatedButton.icon(
            //         onPressed: () {},
            //         icon: const Icon(Icons.check, size: 24),
            //         label: const Text('Approve', style: TextStyle(fontSize: 16)),
            //         style: ElevatedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //           backgroundColor: Colors.green,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //       ),
            //     if (projectData['status'] == 'pending' || projectData['status'] == 'approved')
            //       ElevatedButton.icon(
            //         onPressed: () {},
            //         icon: const Icon(Icons.close, size: 24,color: Colors.white,),
            //         label: const Text('Reject', style: TextStyle(fontSize: 16,color: Colors.white)),
            //         style: ElevatedButton.styleFrom(
            //           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            //           backgroundColor: Colors.red,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(12),
            //           ),
            //         ),
            //       ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }

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
