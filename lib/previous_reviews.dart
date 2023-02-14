import "package:flutter/material.dart";

class PreviousReviews extends StatefulWidget {
  const PreviousReviews({super.key});

  @override
  State<PreviousReviews> createState() => PreviousReviewsState();
}

class PreviousReviewsState extends State<PreviousReviews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My Reviews"),
          backgroundColor: Colors.black,
        ),
        body: const Placeholder());
  }
}