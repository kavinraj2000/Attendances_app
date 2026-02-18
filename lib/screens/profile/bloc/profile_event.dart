part of'profile_bloc.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileEditRequested extends ProfileEvent {
  const ProfileEditRequested();
}

/// Triggered when the user submits edits
class ProfileUpdateSubmitted extends ProfileEvent {
  final String? name;
  final String? title;
  final String? email;
  final String? phone;

  const ProfileUpdateSubmitted({
    this.name,
    this.title,
    this.email,
    this.phone,
  });
}