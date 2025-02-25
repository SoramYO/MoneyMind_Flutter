class WalletType {
  final String id;
  final String name;
  final String description;

  WalletType({
    required this.id,
    required this.name,
    required this.description,
  });

  factory WalletType.fromJson(Map<String, dynamic> json) {
    return WalletType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  factory WalletType.fromMap(Map<String, dynamic> map) {
    return WalletType(
      id: map['id'],
      name: map['name'],
      description: map['description'],
    );
  }
}
