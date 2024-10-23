import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/Portals/studentportal/PastProjects/past_project_detail.dart';
import 'package:navigatorapp/Portals/studentportal/PastProjects/projectsFilterController.dart';

class PastProjectListScreen extends StatelessWidget {
  final String session;

  final PastProjectController pastProjectController = Get.put(PastProjectController());

  PastProjectListScreen({super.key, required this.session});

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
        foregroundColor: Colors.white,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Filter Buttons
            Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterButton('All', pastProjectController,'All'),
                  _buildFilterButton('Web Development', pastProjectController,'Web'),
                  _buildFilterButton('App Development', pastProjectController,'App'),
                  _buildFilterButton('AI', pastProjectController,'AI-based'),
                  _buildFilterButton('Machine Learning', pastProjectController,'Machine'),
                  _buildFilterButton('Others', pastProjectController,'Others'),
                ],
              ),
              const SizedBox(height: 10),
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
                          Get.to(() => ProjectDetailsScreen(projectId: project['docId']),
                              transition: Transition.fadeIn,
                              duration: const Duration(milliseconds: 300));
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white),
                            child: ListTile(
                              contentPadding:
                              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              leading: Icon(Icons.school,
                                  color: Colors.teal.shade800, size: 30),
                              title: Text(
                                project['projectName'] ?? 'Untitled',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.teal,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Icon(Icons.person,
                                        size: 18, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      project['supervisor'] ?? 'No supervisor',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.teal.shade800,
                                size: 20,
                              ),
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
      ),
    );
  }

  // Helper method to create a filter button
  Widget _buildFilterButton(String filter, PastProjectController controller,String key) {
    return Obx(() => ElevatedButton(
      onPressed: () {
        controller.updateFilter(key);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.selectedFilter.value == filter
            ? Colors.teal
            : Colors.grey.shade300,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        filter,
        style: TextStyle(
          color: controller.selectedFilter.value == key
              ? Colors.white
              : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));
  }
}
