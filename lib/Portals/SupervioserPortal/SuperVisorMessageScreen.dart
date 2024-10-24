import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
import 'package:uuid/uuid.dart';
import '../../CustomWidgets/Snakbar.dart';

class SupervisorMessageScreen extends StatefulWidget {
  String receiverId;
  String receiverName;
  SupervisorMessageScreen({required this.receiverId,required this.receiverName});
  @override
  _SupervisorMessageScreenState createState() => _SupervisorMessageScreenState();
}

class _SupervisorMessageScreenState extends State<SupervisorMessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  bool _isSending = false;

  void _sendMessage() async {
    setState(() {
      _isSending = true;
    });
    var uuid = const Uuid();
    DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user!.uid)
        .get();

    if (_messageController.text.trim().isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(user!.uid)
          .set({
        'SenderName': userData['name'],
        'SenderProfession': userData['role'],
      });

      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(user!.uid)
          .collection('Messages')
          .add({
        'message': _messageController.text.trim(),
        'Message By':user!.uid,
        'sender': user!.uid,
        'receiverId': widget.receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'MessageId': uuid.v4(),
      });

      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.receiverId)
          .set({
        'SenderName': widget.receiverName,
        'SenderProfession': 'student',
      });

      await FirebaseFirestore.instance
          .collection('Chats')
          .doc(widget.receiverId)
          .collection('Messages')
          .add({
        'message': _messageController.text.trim(),
        'Message By':user!.uid,
        'sender': widget.receiverId,
        'receiverId': user!.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'MessageId': uuid.v4(),
      });

      _messageController.clear();
    } else {
      showErrorSnackbar('Please type a message');
    }

    setState(() {
      _isSending = false;
    });
  }

  // Function to format the timestamp
  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomTextWidget(
            title: 'Message to ${widget.receiverName}', color: Colors.white),
        backgroundColor: Colors.teal.shade700,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(user!.uid)
                  .collection('Messages')
                  .where('sender', isEqualTo: user!.uid)
                  .where('receiverId', isEqualTo: widget.receiverId)
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
                        child: Row(
                          mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
                          children: [
                            // For spacing on receiver's side if needed
                            if (!isSender) const SizedBox(width: 10),
                            // Message container and delete icon will be in a row
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.all(10.0),  // Reduce padding to make it smaller
                                decoration: BoxDecoration(
                                  color: isSender ? Colors.teal.shade300 : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(isSender ? 12 : 0),
                                    topRight: Radius.circular(isSender ? 0 : 12),
                                    bottomLeft: const Radius.circular(12),
                                    bottomRight: const Radius.circular(12),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      messageData['message'],
                                      style: TextStyle(
                                        color: isSender ? Colors.white : Colors.black87,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      timestamp,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSender ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Small spacing between message and icon
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(messageData['MessageId']),
                              padding: EdgeInsets.zero, // Removes padding around the icon
                              constraints: const BoxConstraints(), // Keeps the icon size small
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
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
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
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
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showDeleteDialog(String messageId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Do you want to delete this message for yourself or for everyone?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete for Me'),
              onPressed: () {
                _deleteMessageForMe(messageId);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete for Everyone'),
              onPressed: () {
                _deleteMessageForEveryone(messageId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _deleteMessageForMe(String messageId) async {
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(user!.uid)
        .collection('Messages')
        .doc(messageId)
        .delete();
      showSuccessSnackbar('Message deleted for you');
  }
  void _deleteMessageForEveryone(String messageId) async {
    // Delete from the current user's messages
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(user!.uid)
        .collection('Messages')
        .doc(messageId)
        .delete();

    // Delete from the receiver's messages
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(widget.receiverId)
        .collection('Messages')
        .doc(messageId)
        .delete();

    showSuccessSnackbar('Message deleted for everyone');
  }
}



