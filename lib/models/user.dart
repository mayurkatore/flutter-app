class User {
  final String id;
  final String name;
  final String email;
  final DateTime joinDate;
  final List<String> interests;
  final List<String> friendIds;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.joinDate,
    required this.interests,
    required this.friendIds,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? joinDate,
    List<String>? interests,
    List<String>? friendIds,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      joinDate: joinDate ?? this.joinDate,
      interests: interests ?? this.interests,
      friendIds: friendIds ?? this.friendIds,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, joinDate: $joinDate, interests: $interests, friendIds: $friendIds)';
  }
}