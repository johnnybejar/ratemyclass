import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_clas/course_screen.dart';
import 'course.dart';

//////////////////////////////////////////
/// The Favorite Reviews screen shows the
/// user the reviews they have favorited.
//////////////////////////////////////////

class FavoriteReviews extends StatefulWidget {
  const FavoriteReviews({super.key});

  @override
  State<FavoriteReviews> createState() => _FavoriteReviewsState();
}

class _FavoriteReviewsState extends State<FavoriteReviews> {
  final classesRef = FirebaseFirestore.instance.collection('Classes');
  final String userID = FirebaseAuth.instance.currentUser!.uid;

  List<Course> classesList = [];
  List<Course> favoritedList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generateCourseList();
  }

  @override
  Widget build(BuildContext context) {
    // Loops through the classes and determine
    // which one the user has favorited
    for (Course course in classesList) {
      if (course.favorited.contains(userID)) {
        favoritedList.add(course);
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Favorited Classes"),
          backgroundColor: Colors.black,
        ),
        body: showWidget());
  }

  // This function displays text if you don't have favorited classes or displays the classes if you do
  showWidget() {
    if (favoritedList.isEmpty) {
      return const Center(child: Text("You have no classes favorited!"));
    } else {
      return Center(
          child: ListView.builder(
        itemCount: favoritedList.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(
                  "${favoritedList[index].code} ${favoritedList[index].number}"),
              onTap: (() {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CourseScreen(course: favoritedList[index])));
                            // Unfavoriting a course won't remove it until you reload the page.
              }),
            ),
          );
        },
      ));
    }
  }

  // There is likely a way to only get classes that the user has favorited
  // to save performance, but this method still works well
  Future generateCourseList() async {
    QuerySnapshot<Map<String, dynamic>> data =
        await classesRef.orderBy('number', descending: false).get();

    setState(() {
      classesList = List.from(data.docs.map((doc) => Course.fromSnapshot(doc)));
    });
  }
}
