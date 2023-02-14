import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rate_my_clas/course_screen.dart';
import 'package:rate_my_clas/favorite_reviews.dart';
import 'package:rate_my_clas/login_screen.dart';
import 'package:rate_my_clas/course.dart';

////////////////////////////////////////////////////
// Home Screen displays the list of classes that
// are stored in the firestore database. It also
// has buttons to let the user view their favotired
// classes and the reviews they have written
////////////////////////////////////////////////////
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userCreds});

  final UserCredential
      userCreds; // These credentials are added so the user can logout

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // This is a neat trick to get data from a
  // Future without using a futurebuilder
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    generateCourseList();
  }

  // Reference to the Firestore collection
  final classesRef = FirebaseFirestore.instance.collection("Classes");
  // The text editing controller allows us to perform an action everytime text is written
  final TextEditingController _controller = TextEditingController();
  // The classes list is used to display the classes in order
  List<Course> classesList = [];
  // The search results list is used to display the classes which match the search criteria
  List<Course> searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Welcome ${widget.userCreds.user!.email}"),
        actions: <Widget>[
          // The logout button is placed inside of AppBar
          ElevatedButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: ((context) => const LoginScreen())),
                  (route) => false);
            },
            style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll<Color>(Colors.black)),
            child: const Text("Logout"),
          )
        ],
        backgroundColor: Colors.black,
      ),
      body: Container(
          // Added a container with padding so that screen does not look cluttered
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              // When a user types, the search bar is automatically updating the searchResults list.
              TextField(
                controller:
                    _controller, // This controller is used so we can know the state of the text in the TextField
                decoration: const InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Search a course number..."),
                // When the user types something, this is what runs
                onChanged: (value) {
                  // This line will find every Course that matches the value typed in the TextField,
                  // and then place them into the searchResults list.
                  searchResults = classesList.where(
                    (currentCourse) {
                      if (value.length > currentCourse.number.length) {
                        return false;
                      }
                      for (int index = 0; index < value.length; index++) {
                        if (currentCourse.number[index] != value[index]) {
                          return false;
                        }
                      }
                      return true;
                    },
                  ).toList();
                  // If the TextField is empty, empty out the search results.
                  // This is necessary, otherwise two screens start showing.
                  if (_controller.text.isEmpty) {
                    searchResults = [];
                  }
                  setState(() {});
                },
              ),

              // This first part will only show if the TextField is empty.
              // It displays all the courses normally.
              if (_controller.text.isEmpty)
                Expanded(
                    child: Container(
                        // THIS EXPANDED WIDGET IS GOATED WITH THE SAUCE OMM
                        // It allows us to expand the ClassesList container to fully fit the screen.
                        margin: const EdgeInsetsDirectional.only(
                            top: 20, bottom: 20),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            60, 10, 60, 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black)),
                        // This creates the list view for the container
                        child: ListView.builder(
                          itemCount: classesList.length,
                          itemBuilder: (context, index) {
                            // print("Controller text is empty!");
                            return ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        side: const BorderSide(
                                            color: Colors.white, width: 2.0))),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        // When navigating to home screen, carry the csvData as well
                                        builder: (context) => CourseScreen(
                                            course: classesList[index])));
                              },
                              child: Text(
                                  "${classesList[index].code} ${classesList[index].number}"),
                            );
                          },
                        ))),

              // This second part will display only what is typed in the TextField.
              // It only goes off of course number.
              if (searchResults.isNotEmpty)
                Expanded(
                    child: Container(
                        // THIS EXPANDED WIDGET IS GOATED WITH THE SAUCE OMM
                        // It allows us to expand the ClassesList container to fully fit the screen.
                        margin: const EdgeInsetsDirectional.only(
                            top: 20, bottom: 20),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            60, 10, 60, 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black)),
                        // This creates the list view for the container
                        child: ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            // print("Search results have something!");
                            return ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                        side: const BorderSide(
                                            color: Colors.white, width: 2.0))),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        // When navigating to home screen, carry the csvData as well
                                        builder: (context) => CourseScreen(
                                            course: searchResults[index])));
                              },
                              child: Text(
                                  "${searchResults[index].code} ${searchResults[index].number}"),
                            );
                          },
                        ))),

              // This third part displays a message if nothing in the search results matches
              // and the TextField isn't empty.
              if (searchResults.isEmpty && _controller.text.isNotEmpty)
                Expanded(
                    child: Container(
                        // THIS EXPANDED WIDGET IS GOATED WITH THE SAUCE OMM
                        // It allows us to expand the ClassesList container to fully fit the screen.
                        margin: const EdgeInsetsDirectional.only(
                            top: 20, bottom: 20),
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            60, 10, 60, 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black)),
                        // This creates the list view for the container
                        child:
                            const Center(child: Text("No course was found!")))),

              // !! It's important to note that only one of the three parts should ever be displaying.
              // !! If you are seeing multiple screens, it means more than one if statement is true.

              // This is the button that takes you to your favorite courses.
              ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(
                              color: Colors.white, width: 2.0))),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                ),
                onPressed: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoriteReviews(),
                      ));
                }),
                child: const Text(
                  "My Favorite Classes",
                ),
              ),

              // Padding used to give space between Favorite Courses and Course Reviews
              const Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
              ), // Padding between each button
            ],
          )),
    );
  }

  // This converts the "Classes Collection" into a "Course List", that way we can easily sort these from smallest to largest.
  Future generateCourseList() async {
    QuerySnapshot<Map<String, dynamic>> data =
        await classesRef.orderBy('number', descending: false).get();

    setState(() {
      classesList = List.from(data.docs.map((doc) => Course.fromSnapshot(doc)));
    });
  }
}
