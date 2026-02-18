class ProfileModel {
  final String name;
  final String title;
  final String email;
  final String phone;
  final String twitter;
  final String behance;
  final String facebook;
  final int followers;
  final int following;
  final int projects;

  const ProfileModel({
    required this.name,
    required this.title,
    required this.email,
    required this.phone,
    required this.twitter,
    required this.behance,
    required this.facebook,
    required this.followers,
    required this.following,
    required this.projects,
  });

  ProfileModel copyWith({
    String? name,
    String? title,
    String? email,
    String? phone,
    String? twitter,
    String? behance,
    String? facebook,
    int? followers,
    int? following,
    int? projects,
  }) {
    return ProfileModel(
      name:      name      ?? this.name,
      title:     title     ?? this.title,
      email:     email     ?? this.email,
      phone:     phone     ?? this.phone,
      twitter:   twitter   ?? this.twitter,
      behance:   behance   ?? this.behance,
      facebook:  facebook  ?? this.facebook,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      projects:  projects  ?? this.projects,
    );
  }
}