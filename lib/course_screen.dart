import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_clas/course.dart';
import 'package:rate_my_clas/review_screen.dart';

///////////////////////////////////////////////////////
/// The class screen is responsible for showing the
/// information of a class the user selected on the
/// previous home screen. It displays the rating,
/// description, reviews, and gives the user the option
/// to favorite the class and write a review.
///////////////////////////////////////////////////////

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, required this.course});
  final Course course;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  @override
  Widget build(BuildContext context) {
    var classRef = FirebaseFirestore.instance
        .collection("Classes")
        .doc(widget.course.firebaseID);

    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.course.code} ${widget.course.number}"),
          backgroundColor: Colors.black,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                // This will update the difficulty whenever it is changed
                StreamBuilder<DocumentSnapshot>(
                  stream: classRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Text("No data to show!");
                    }
                    var docInfo = snapshot.data!;
                    int newDiff = 0;
                    if (docInfo['difficulty'] != 0) {
                      newDiff =
                          (docInfo['difficulty'] / docInfo['reviews'].length)
                              .floor();
                    }
                    // Text.rich allows us to create text with Icons inside it
                    return RichText(
                      // TextSpan is that actual text, which combines the text and Icons
                      text: TextSpan(
                          style: const TextStyle(
                              fontSize: 22, color: Colors.black),
                          children: [
                            TextSpan(text: "Difficulty Rating: $newDiff/5 "),
                            const WidgetSpan(
                                child: Icon(Icons.local_fire_department,
                                    size: 26, color: Colors.red)),
                          ]),
                    );
                  },
                ),
                // This will update the favorited reviews icon on the top right.
                // It works very similarly to the review ratings.
                StreamBuilder<DocumentSnapshot>(
                    stream: classRef.snapshots(),
                    builder: ((context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Text("No data to show!");
                      }
                      var docInfo = snapshot.data!;
                      int currentFavorites = docInfo["favorited"].length;

                      return RichText(
                        text: TextSpan(
                            style: const TextStyle(
                                fontSize: 22, color: Colors.black),
                            children: [
                              TextSpan(text: "$currentFavorites"),
                              const WidgetSpan(
                                  child: Icon(
                                Icons.favorite,
                                color: Colors.pink,
                              ))
                            ]),
                      );
                    }))
              ]),
              const Divider(
                thickness: 2,
                color: Colors.black,
              ),
              // This is the description of the class
              Text(widget.course.description),
              // Will be used for buttons to describe the class
              Expanded(
                  child: ReviewList(
                      course: widget
                          .course)), // Will be defined later. Using expanded widget, the screen now fully fills
              // Bottom row on the review screen
              // Includes favorite checkbox and button to write reviews
              Row(
                children: [
                  FavoriteCheckBox(
                    classRef: classRef,
                    userID: FirebaseAuth.instance.currentUser!.uid,
                  ),
                  const Text("Favorite",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  // Spacer forces the checkbox and "Favorite" text to be side-by-side
                  const Spacer(),
                  OutlinedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                    currentCourse: widget.course,
                                  )));
                    },
                    child: const Text(
                      "Write a Review",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}

// Scrollable Container with Reviews
// This is the Stream Builder we use for Reviews. It updates everytime a new review is added.
class ReviewList extends StatelessWidget {
  const ReviewList({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Column(children: [Expanded(
      child: Container(
          margin: const EdgeInsets.all(5),
          height: 300,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: Colors.black,
              )),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Classes")
                  .doc(course.firebaseID)
                  .snapshots(),
              builder: ((context, snapshot) {
                // This displays text if no reviews have been written yet
                if (!snapshot.hasData ||
                    snapshot.data!.get("reviews").length == 0) {
                  return const Center(
                      child:
                          Text("No reviews yet, be the first to write one!"));
                }
                var courseSnapshot = snapshot.data!;

                return ListView.builder(
                  itemCount: courseSnapshot.get("reviews").length,
                  itemBuilder: (context, index) {
                    return CourseReview(
                      review: courseSnapshot.get("reviews")[index]
                          ["review"], //course.reviews[index]['review'],
                      rating: courseSnapshot.get("reviews")[index][
                          "reviewRating"], //course.reviews[index]['reviewRating'],
                      index: index,
                    );
                  },
                );
              }))),
    )]);
  }
}

// Represents an individual review in the review list
class CourseReview extends StatelessWidget {
  const CourseReview(
      {super.key,
      required this.review,
      required this.rating,
      required this.index});

  final String review;
  final int rating;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              review,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // This is another RichText widget that places the Icon next to number
          RichText(
              text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                const WidgetSpan(
                    child: Icon(Icons.local_fire_department,
                        size: 14, color: Colors.red)),
                TextSpan(text: "$rating")
              ]))
        ],
      ),
    );
  }
}

class FavoriteCheckBox extends StatefulWidget {
  const FavoriteCheckBox(
      {super.key, required this.classRef, required this.userID});

  final DocumentReference<Map<String, dynamic>> classRef;
  final String userID;

  @override
  State<FavoriteCheckBox> createState() => _FavoriteCheckBoxState();
}

class _FavoriteCheckBoxState extends State<FavoriteCheckBox> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.classRef.snapshots(),
      builder: (context, snapshot) {
        bool isChecked = false;
        if (!snapshot.hasData) {
          return const Text("No data to show!");
        }
        var docInfo = snapshot.data!;
        if (docInfo['favorited'].contains(widget.userID)) {
          isChecked = true;
        }
        return Checkbox(
          activeColor: Colors.red,
          value: isChecked, // this is th eone ....
          onChanged: (bool? value) {
            isChecked = value!;
            _updateReviewed(isChecked);
            setState(() {});
          },
        );
      },
    );
  }

  // Updates the favorited list when user checks or unchecks
  // the favorited checkbox
  _updateReviewed(isChecked) async {
    var data = await widget.classRef.get().then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data;
    });
    if (isChecked && !data['favorited'].contains(widget.userID)) {
      widget.classRef.update({
        'favorited': FieldValue.arrayUnion([widget.userID])
      });
    } else {
      widget.classRef.update({
        'favorited': FieldValue.arrayRemove([widget.userID])
      });
    }
  }
}
