import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PastProjectController extends GetxController {
  var projects = [].obs;
  var filteredProjects = [].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var docId = ''.obs;
  var selectedFilter = 'All'.obs;

  Future<void> fetchProjects(String session) async {
    try {
      isLoading(true);
      hasError(false);

      var snapshot = await FirebaseFirestore.instance
          .collection('PastProjects')
          .where('session', isEqualTo: session)
          .get();

      if (snapshot.docs.isNotEmpty) {
        projects.value = snapshot.docs.map((doc) {
          var data = doc.data();
          data['docId'] = doc.id;
          return data;
        }).toList();

        applyFilter();
      } else {
        projects.value = [];
      }
    } catch (e) {
      hasError(true);
    } finally {
      isLoading(false);
    }
  }

  void applyFilter() {
    if (selectedFilter.value == 'All') {
      filteredProjects.value = projects;
    } else {
      filteredProjects.value = projects
          .where((project) => project['projectType'] == selectedFilter.value)
          .toList();
    }
  }

  void updateFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }
}
