import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:navigatorapp/CustomWidgets/Snakbar.dart';
import 'package:navigatorapp/CustomWidgets/TextWidget.dart';
class StudentFeedbackPage extends StatefulWidget {
  @override
  _StudentFeedbackPageState createState() => _StudentFeedbackPageState();
}

class _StudentFeedbackPageState extends State<StudentFeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  double _rating = 3.0;
  User? user = FirebaseAuth.instance.currentUser;

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      DocumentSnapshot<Map<String,dynamic>> UserData = await FirebaseFirestore.instance.collection('Users').doc(user!.uid).get();
      try {
        await FirebaseFirestore.instance.collection('Feedback').add({
          'userId': user!.uid,
          'UserName':UserData['name'],
          'Profession':UserData['role'],
          'feedback': _feedbackController.text,
          'rating': _rating,
          'timestamp': FieldValue.serverTimestamp(),
        });

        showSuccessSnackbar('Feedback submitted successfully');
        _feedbackController.clear();
        setState(() {
          _rating = 3.0;
        });
      } catch (e) {
        showErrorSnackbar('Failed to submit feedback: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomTextWidget(title: 'Give Feedback', color: Colors.white),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 16),
                TextFormField(
                  controller: _feedbackController,
                  decoration: const InputDecoration(
                    labelText: 'Your Feedback',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please provide your feedback';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rate Us:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitFeedback,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Submit Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
