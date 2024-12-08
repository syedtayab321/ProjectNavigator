// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:get/get.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:user_quick_pass/data/repository/user_repo.dart';
// import 'package:user_quick_pass/features/Booking/Model/booking_model.dart';
// import 'package:user_quick_pass/utills/Errors/Error%20handler/error_handler.dart';
//
// class BookingController extends GetxController {
//   static BookingController get instance => Get.find();
//
//   RxString applyingFrom = 'Select Country'.obs;
//   RxString applyingTo = 'Select Country'.obs;
//
//   RxList<File> selectedFiles = <File>[].obs;
//   RxBool isLoading = false.obs;
//
//   void initState() {
//     final userRepo = Get.put(UserRepository());
//     userRepo.fetchUserDetail();
//   }
//
//   final bookingsCollection = FirebaseFirestore.instance.collection('Bookings');
//
//   Future<void> selectMultipleFiles() async {
//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
//         allowMultiple: true,
//       );
//
//       if (result != null) {
//         List<File> newFiles = result.paths.map((path) => File(path!)).toList();
//
//         selectedFiles
//             .addAll(newFiles.where((file) => !selectedFiles.contains(file)));
//       }
//     } catch (e) {
//       ErrorHandler.showErrorSnackbar("Failed to select files: $e");
//     }
//   }
//
//   Future<void> submitBooking() async {
//     try {
//       if (applyingFrom.value == 'Select Country' ||
//           applyingTo.value == 'Select Country') {
//         ErrorHandler.showErrorSnackbar("Please select both countries.");
//         return;
//       }
//
//       if (selectedFiles.isEmpty) {
//         ErrorHandler.showErrorSnackbar("Please upload at least one document.");
//         return;
//       }
//
//       isLoading.value = true;
//
//       List<String> uploadedFileUrls = [];
//
//       for (File file in selectedFiles) {
//         String? url = await uploadFile(file, "documents");
//         if (url != null) {
//           uploadedFileUrls.add(url);
//         }
//       }
//
//       final userRepo = Get.put(UserRepository());
//       final userData = userRepo.userData;
//       userRepo.fetchUserDetail();
//
//       if (userData['id'] == '' ||
//           userData['email'] == '' ||
//           userData['name'] == '') {
//         ErrorHandler.showErrorSnackbar(
//             "User data is incomplete. Please try again.");
//         return;
//       }
//
//       if (uploadedFileUrls.isNotEmpty) {
//         BookingModel booking = BookingModel(
//           userID: userData['id'],
//           userEmail: userData['email'],
//           userName: userData['name'],
//           applyingFrom: applyingFrom.value,
//           applyingTo: applyingTo.value,
//           documentUrls: uploadedFileUrls,
//           createdAt: DateTime.now(),
//           status: 'pending',
//         );
//
//         DocumentReference docRef =
//         await bookingsCollection.add(booking.toJson());
//         String docID = docRef.id;
//
//         await docRef.update({"docID": docID});
//
//         ErrorHandler.showSuccessSnackkbar(
//             "Success", "Booking submitted successfully!");
//
//         applyingFrom.value = 'Select Country';
//         applyingTo.value = 'Select Country';
//         selectedFiles.clear();
//       }
//     } catch (e) {
//       ErrorHandler.showErrorSnackbar("Failed to submit booking: $e");
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<String?> uploadFile(File file, String folderName) async {
//     try {
//       String fileName = file.path.split('/').last;
//       UploadTask uploadTask =
//       FirebaseStorage.instance.ref('$folderName/$fileName').putFile(file);
//
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       ErrorHandler.showErrorSnackbar("Failed to upload file: $e");
//       return null;
//     }
//   }
//
//   RxList<BookingModel> bookingHistory = RxList<BookingModel>();
//
//   Future<void> fetchBookingHistory() async {
//     try {
//       isLoading.value = true;
//
//       final userRepo = Get.put(UserRepository());
//       final userData = userRepo.userData;
//       userRepo.fetchUserDetail();
//
//       if (userData['id'] == null || userData['id'].isEmpty) {
//         throw Exception("User ID is null or empty. Please log in again.");
//       }
//
//       QuerySnapshot snapshot = await bookingsCollection
//           .where('userID', isEqualTo: userData['id'])
//           .orderBy('createdAt', descending: true)
//           .get();
//
//       if (kDebugMode) {
//         print("Fetched ${snapshot.docs.length} bookings from Firestore.");
//       }
//       for (var doc in snapshot.docs) {
//         if (kDebugMode) {
//           print("Document Data: ${doc.data()}");
//         }
//       }
//
//       bookingHistory.value = snapshot.docs
//           .map((doc) =>
//           BookingModel.fromJson(doc.data() as Map<String, dynamic>))
//           .toList();
//
//       if (kDebugMode) {
//         print(
//             "Booking history updated successfully. Total: ${bookingHistory.length}");
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error fetching booking history: $e");
//       }
//       Get.snackbar("Error", "Failed to fetch booking history: $e",
//           snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }
// }