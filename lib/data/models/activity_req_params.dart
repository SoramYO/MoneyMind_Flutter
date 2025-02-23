class ActivityReqParams {
  final String name;
  final String description;
  final String walletCategoryId;

  ActivityReqParams(
      {required this.name,
      required this.description,
      required this.walletCategoryId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'walletCategoryId': walletCategoryId,
    };
  }
}
