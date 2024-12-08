import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../../CustomWidgets/Snakbar.dart';

class StudentMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  StudentMessageScreen({required this.receiverId, required this.receiverName});

  @override
  _StudentMessageScreenState createState() => _StudentMessageScreenState();
}

class _StudentMessageScreenState extends State<StudentMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  final Dio _dio = Dio();
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  void _sendMessage({String? documentUrl, String? documentName}) async {
    setState(() {
      _isSending = true;
    });
    var uuid = const Uuid();

    // Validate that either message or document data exists
    if ((documentUrl != null && documentName != null) ||
        _messageController.text.trim().isNotEmpty) {
      Map<String, dynamic> messageData = {
        'Message By': user!.uid,
        'sender': user!.uid,
        'receiverId': widget.receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'MessageId': uuid.v4(),
        'message': _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
        'document': documentUrl,
        'documentName': documentName,
      };

      // Remove null values from the map
      messageData.removeWhere((key, value) => value == null);

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(user!.uid)
          .collection('Messages')
          .add(messageData);

      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.receiverId)
          .collection('Messages')
          .add(messageData);

      _messageController.clear();
    } else {
      showErrorSnackbar('Please type a message or select a document');
    }

    setState(() {
      _isSending = false;
    });
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Upload"),
          content: Text("Do you want to upload \"$fileName\"?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Upload"),
            ),
          ],
        ),
      );

      if (confirm == true) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          String documentUrl = await _uploadDocumentWithDio(file, fileName);
          Navigator.pop(context); // Dismiss loading dialog
          _sendMessage(documentUrl: documentUrl, documentName: fileName);
        } catch (e) {
          Navigator.pop(context); // Dismiss loading dialog
          showErrorSnackbar('Failed to upload document: $e');
        }
      }
    } else {
      showErrorSnackbar('Document selection cancelled');
    }
  }


  Future<String> _uploadDocumentWithDio(File file, String fileName) async {
    String path = 'documents/${user!.uid}/${Uuid().v4()}_$fileName';
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);

    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Message to ${widget.receiverName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child:
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(user!.uid)
                  .collection('Messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var messageData = messages[index].data() as Map<String, dynamic>;
                    var isSender = messageData['Message By'] == user!.uid;
                    var timestamp = messageData['timestamp'] != null
                        ? _formatTimestamp(messageData['timestamp'] as Timestamp)
                        : "Sending...";

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Align(
                        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: isSender
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (messageData['message'] != null)
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.teal.shade300 : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  messageData['message'],
                                  style: TextStyle(
                                    color: isSender ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            if (messageData['document'] != null)
                              GestureDetector(
                                onTap: () {
                                  launchUrl(Uri.parse(messageData['document']));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  decoration: BoxDecoration(
                                    color: isSender ? Colors.teal.shade300 : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file,
                                        color: isSender ? Colors.white : Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          messageData['documentName'] ?? "Document",
                                          style: TextStyle(
                                            color: isSender ? Colors.white : Colors.blue,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            Text(
                              timestamp,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            )

          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.teal),
                  onPressed: _pickDocument,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const CircularProgressIndicator()
                    : CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 24,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
