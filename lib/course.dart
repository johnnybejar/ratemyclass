//////////////////////////////////////////
/// This class converts the documents in
/// firestore to a Course object (we call
/// it "Course" because dart doesn't like
/// classes being named "Class").
//////////////////////////////////////////

class Course {
  Course(
      {required this.firebaseID,
      required this.code,
      required this.number,
      required this.description,
      required this.difficulty,
      required this.favorited,
      required this.reviewed,
      required this.reviews});

  String
      firebaseID; // The firebase ID allows us to get a reference to the specific Firebase document for the course
  String code;
  String number;
  String description;
  int difficulty;
  List<dynamic> favorited;
  List<dynamic> reviewed;
  List<dynamic> reviews;

  // This is the opposite of toMap. It takes the snapshot values and puts them into the Course instance variables
  Course.fromSnapshot(snapshot)
      : firebaseID = snapshot.id,
        code = snapshot.data()['code'],
        number = snapshot.data()['number'],
        description = snapshot.data()['description'],
        difficulty = snapshot.data()['difficulty'],
        favorited = snapshot.data()['favorited'],
        reviewed = snapshot.data()['reviewed'],
        reviews = snapshot.data()['reviews'];
}
