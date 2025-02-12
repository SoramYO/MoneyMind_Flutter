// ignore_for_file: public_member_api_docs, sort_constructors_first

class SignupReqParams {
  final String email;
  final String password;
  final String fullName;
  final List<String> roles;

  SignupReqParams(
      {required this.email,
      required this.password,
      required this.fullName,
      required this.roles});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'roles': roles
          .map((role) => role)
          .toList(), // Ensure roles is serialized properly
    };
  }
}
