class ActivityDb {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  ActivityDb({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory ActivityDb.fromJson(Map<String, dynamic> json) {
    return ActivityDb(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ActivityDb.fromMap(Map<String, dynamic> map) {
    return ActivityDb(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
