import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'add_project_controller.dart';

class StudentRequestProject extends StatelessWidget {
  final AddProjectController controller = Get.put(AddProjectController());
  final List<String> sessions = [
    '2030-2034',
    '2029-2033',
    '2028-2032',
    '2027-2031',
    '2026-2030',
    '2025-2029',
    '2024-2028',
    '2023-2027',
    '2022-2026',
    '2021-2025',
    '2020-2024',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Final Year Project"),
        backgroundColor: Colors.tealAccent[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: [
              Text(
                "Enter Project Details",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.projectNameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  labelStyle: TextStyle(color: Colors.tealAccent[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Session (Dropdown)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Session',
                  labelStyle: TextStyle(color: Colors.tealAccent[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: controller.sessionController.text.isEmpty
                    ? null
                    : controller.sessionController.text,
                items: sessions
                    .map((session) => DropdownMenuItem(
                  value: session,
                  child: Text(session),
                ))
                    .toList(),
                onChanged: (value) {
                  controller.sessionController.text = value!;
                },
              ),
              // File Upload Button
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.partnerController,
                decoration: InputDecoration(
                  labelText: 'Partner (Optional)',
                  labelStyle: TextStyle(color: Colors.tealAccent[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.supervisors.isEmpty) {
                  return const Center(child: CustomTextWidget(title: 'No supervisor Available right now.'));
                }
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Supervisor',
                    labelStyle: TextStyle(color: Colors.tealAccent[700]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: controller.selectedSupervisor.value.isEmpty
                      ? null
                      : controller.selectedSupervisor.value,
                  items: controller.supervisors
                      .map((supervisor) => DropdownMenuItem(
                    value: supervisor,
                    child: Text(supervisor),
                  ))
                      .toList(),
                  onChanged: (value) {
                    controller.selectedSupervisor.value = value!;
                  },
                );
              }),
              const SizedBox(height: 16),
              Obx(() {
                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Domain of Project',
                    labelStyle: TextStyle(color: Colors.tealAccent[700]),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: controller.selectedDomain.value.isEmpty
                      ? null
                      : controller.selectedDomain.value,
                  items: controller.domains
                      .map((domain) => DropdownMenuItem(
                    value: domain,
                    child: Text(domain),
                  ))
                      .toList(),
                  onChanged: (value) {
                    controller.selectedDomain.value = value!;
                  },
                );
              }),
              const SizedBox(height: 16),

              // Project Description
              TextFormField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: 'Project Description',
                  labelStyle: TextStyle(color: Colors.tealAccent[700]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Obx(() {
                return Column(
                  children: [
                    Obx(() {
                      return controller.isLoading.value ?
                          const Center(child: CircularProgressIndicator()) :
                          ElevatedButton.icon(
                        onPressed: controller.pickFile,
                        icon: const Icon(
                          Icons.upload_file,
                          size: 28,
                        ),
                        label: const Text(
                          'Upload Project File',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent[700],
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.2),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),
                    if (controller.isFilePicked.value)
                      const Text(
                        'File uploaded successfully!',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: 24),
              Obx((){
                return controller.supervisors.isEmpty?
                    const Center(child: CustomTextWidget(title: 'You can not add project at this time',)):
                   Obx(() {
                     return controller.isLoading.value?
                         const Center(child: CircularProgressIndicator()):
                         ElevatedButton(
                           onPressed: () {
                             controller.submitProject();
                           },
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.tealAccent[700],
                             padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                             textStyle: const TextStyle(
                               fontSize: 18,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                           child: const Text(
                             'Submit Project',
                             style: TextStyle(color: Colors.white),
                           ),
                         );
                   });
              })
            ],
          ),
        ),
      ),
    );
  }
}
