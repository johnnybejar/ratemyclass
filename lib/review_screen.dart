import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:rate_my_clas/course.dart';

//////////////////////////////////////////////////////
/// The review screen allows the user to write their
/// own review for a class they clicked on in the home
/// screen. They decide the rating of the class and
/// write a text review.
//////////////////////////////////////////////////////

// I had to make the whole screen a stateful widget so I could use the slider
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key, required this.currentCourse});
  final Course currentCourse;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final classesRef = FirebaseFirestore.instance.collection("Classes");
  String? writtenReview;
  double difficultyLevel = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
            "Write a Review for ${widget.currentCourse.code} ${widget.currentCourse.number}"),
        // When you use a stateful widget, you can access the class variables using widget.
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            RichText(
                text: const TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                  TextSpan(text: "Rate the difficulty level "),
                  WidgetSpan(
                      child: Icon(
                    Icons.local_fire_department,
                    color: Colors.red,
                  ))
                ])),
            Slider(
                activeColor: Colors.red[700],
                inactiveColor: Colors.black,
                max: 5,
                min: 1,
                divisions: 4,
                label: "$difficultyLevel",
                value: difficultyLevel,
                onChanged: ((value) {
                  difficultyLevel = value;
                  setState(() {});
                })),
            const Text("Write your review"),
            Expanded(
                child: TextField(
              onChanged: (value) => writtenReview = value,
              textAlignVertical: TextAlignVertical.top,
              // This tells the textfield it should be placed at the top
              maxLength: 250,
              maxLines: null,
              minLines: null,
              // The max and min length for the box have to be set to null, so it can freely expand
              expands: true,
              // Expands allows the textfield to expand freely
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter your thoughts...",
              ),
            )),
            ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                              color: Colors.white, width: 2.0))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.red),
                ),
                onPressed: (() {
                  // This check makes sure the user has written something
                  if (writtenReview == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      "Error: You must write something!",
                      style: TextStyle(color: Colors.red[400]),
                    )));
                  } else {
                    int difficulty = difficultyLevel.round();
                    String userReview = writtenReview!;
                    List<dynamic> reviewAndRating = [
                      {"review": userReview, "reviewRating": difficulty}
                    ];
                    // This union adds the item to the list, rather than replaces it
                    // the firebaseID allows us to know which course we are adding items to
                    classesRef.doc(widget.currentCourse.firebaseID).update(
                        {"reviews": FieldValue.arrayUnion(reviewAndRating)});
                    // Increment the difficulty field in the firebaseID, so that the difficulty
                    // for the course will stay consistent
                    classesRef.doc(widget.currentCourse.firebaseID).update({
                      'difficulty': FieldValue.increment(
                          reviewAndRating[0]['reviewRating'])
                    });
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      "Review has been posted!",
                      style: TextStyle(color: Colors.green[400]),
                    )));
                    Navigator.of(context).pop();
                    // Returns user to review screen with snackbar message about review being posted
                  }
                }),
                child: const Text("Post Review"))
          ],
        ),
      ),
    );
  }
}

// MAKING THIS ^^ A STATEFUL WIDGET ALLOWS ME TO ACTUALLY USE THE SLIDER
