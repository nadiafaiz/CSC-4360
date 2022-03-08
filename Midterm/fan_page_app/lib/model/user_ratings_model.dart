class UserRating {
  String? uid;
  double? rating;
  String? comment;

  UserRating({
    this.uid,
    this.rating,
    this.comment,
  });

  factory UserRating.fromMap(map) {
    return UserRating(
      uid: map['uid'],
      rating: map['rating'],
      comment: map['comment'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'rating': rating,
      'comment': comment,
    };
  }
}
