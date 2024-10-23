import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/Portals/studentportal/PastProjects/past_project_detail.dart';
import 'package:navigatorapp/Portals/studentportal/PastProjects/projectsFilterController.dart';

import 'PastProjectDetailsScree.dart';

class AdminPastProjectListScreen extends StatelessWidget {
  final String session;
  final PastProjectController pastProjectController = Get.put(PastProjectController());

  AdminPastProjectListScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    pastProjectController.fetchProjects(session);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Projects $session',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Buttons
            SizedBox(
              height: 40, // Height of filter buttons
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterButton('All', pastProjectController, 'All'),
                  _buildFilterButton('Web Development', pastProjectController, 'Web'),
                  _buildFilterButton('App Development', pastProjectController, 'App'),
                  _buildFilterButton('AI', pastProjectController, 'AI-based'),
                  _buildFilterButton('Machine Learning', pastProjectController, 'Machine'),
                  _buildFilterButton('Others', pastProjectController, 'Others'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (pastProjectController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (pastProjectController.hasError.value) {
                  return const Center(child: Text('Error fetching projects.'));
                }
                if (pastProjectController.filteredProjects.isEmpty) {
                  return const Center(child: Text('No projects found.'));
                }
                return ListView.builder(
                  itemCount: pastProjectController.filteredProjects.length,
                  itemBuilder: (context, index) {
                    var project = pastProjectController.filteredProjects[index];
                    return GestureDetector(
                      onTap: () {
                        Get.to(() => AdminProjectDetailsScreen(projectId: project['docId']),
                            transition: Transition.fadeIn,
                            duration: const Duration(milliseconds: 300));
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.teal.shade100,
                            child: const Icon(
                              Icons.school,
                              color: Colors.teal,
                              size: 30,
                            ),
                          ),
                          title: Text(
                            project['projectName'] ?? 'Untitled',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Icon(Icons.person,
                                    size: 18, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Text(
                                  project['supervisor'] ?? 'No supervisor',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.teal.shade400,
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to create a simple flat filter button
  Widget _buildFilterButton(String filter, PastProjectController controller, String key) {
    return Obx(() => Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: TextButton(
        onPressed: () {
          controller.updateFilter(key);
        },
        style: TextButton.styleFrom(
          backgroundColor: controller.selectedFilter.value == key
              ? Colors.teal.shade100
              : Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: controller.selectedFilter.value == key
                ? Colors.teal.shade800
                : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ));
  }
}
