class Tag {
  final String id;
  final String name;
  final String description;
  final String color;

  Tag({
    required this.id,
    required this.name, 
    required this.description,
    required this.color,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
    };
  }
}

class Transaction {
  final String id;
  final String recipientName;
  final double amount;
  final String description;
  final DateTime transactionDate;
  final DateTime createAt;
  final DateTime lastUpdateAt;
  final String userId;
  final String? walletId;
  final String? activyId;
  final List<Tag> tags;

  Transaction({
    required this.id,
    required this.recipientName,
    required this.amount,
    required this.description,
    required this.transactionDate,
    required this.createAt,
    required this.lastUpdateAt,
    required this.userId,
    this.walletId,
    this.activyId,
    required this.tags,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) { 
    return Transaction(
      id: json['id'],
      recipientName: json['recipientName'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      transactionDate: DateTime.parse(json['transactionDate']),
      createAt: DateTime.parse(json['createAt']),
      lastUpdateAt: DateTime.parse(json['lastUpdateAt']),
      userId: json['userId'],
      walletId: json['walletId'],
      activyId: json['activyId'],
      tags: (json['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'amount': amount,
      'description': description,
      'transactionDate': transactionDate.toIso8601String(),
      'createAt': createAt.toIso8601String(),
      'lastUpdateAt': lastUpdateAt.toIso8601String(),
      'userId': userId,
      'walletId': walletId,
      'activyId': activyId,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) { 
    return Transaction(
      id: map['id'],
      recipientName: map['recipientName'],
      amount: map['amount'].toDouble(),
      description: map['description'],
      transactionDate: DateTime.parse(map['transactionDate']),
      createAt: DateTime.parse(map['createAt']),
      lastUpdateAt: DateTime.parse(map['lastUpdateAt']),
      userId: map['userId'],
      walletId: map['walletId'],
      activyId: map['activyId'],
      tags: (map['tags'] as List).map((tag) => Tag.fromJson(tag)).toList(),
    );
  }

  Transaction copyWith({
    String? id,
    String? recipientName,
    double? amount,
    String? description,
    DateTime? transactionDate,
    DateTime? lastUpdateAt,
    String? walletId,
    String? activyId,
  }) {
    return Transaction(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createAt: this.createAt,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt,
      userId: this.userId,
      walletId: walletId ?? this.walletId,
      activyId: activyId ?? this.activyId,
      tags: this.tags,
    );
  }
} 