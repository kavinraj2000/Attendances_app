part of'profile_bloc.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final bool isEditing;

  const ProfileLoaded({
    required this.profile,
    this.isEditing = false,
  });

  ProfileLoaded copyWith({
    ProfileModel? profile,
    bool? isEditing,
  }) {
    return ProfileLoaded(
      profile:   profile   ?? this.profile,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}

class ProfileUpdating extends ProfileState {
  final ProfileModel profile;
  const ProfileUpdating(this.profile);
}