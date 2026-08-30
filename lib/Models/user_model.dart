class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
