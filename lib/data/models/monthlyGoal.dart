class Monthlygoal {
  final String userId;
  final int year;
  final int month;


  Monthlygoal({
    required this.userId,
    required this.year,
    required this.month,
  });

  factory Monthlygoal.fromJson(Map<String, dynamic> json) {
    return Monthlygoal(
      userId: json['userId'],
      year: json['year'],
      month: json['month'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'year': year,
      'month': month,
    };
  }

}


