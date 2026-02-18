import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrm/core/model/profile_model.dart';

part 'profile_event.dart';
part 'profile_state.dart';


class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {

  ProfileBloc():
        super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileEditRequested>(_onEditRequested);
    on<ProfileUpdateSubmitted>(_onUpdateSubmitted);
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // final profile = await _repository.fetchProfile();
      // emit(ProfileLoaded(profile: profile));
    } catch (e) {
      emit(ProfileError('Failed to load profile: $e'));
    }
  }

  void _onEditRequested(
    ProfileEditRequested event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileLoaded) {
      emit((state as ProfileLoaded).copyWith(isEditing: true));
    }
  }

  Future<void> _onUpdateSubmitted(
    ProfileUpdateSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;
    final current = (state as ProfileLoaded).profile;
    final updated = current.copyWith(
      name:  event.name,
      title: event.title,
      email: event.email,
      phone: event.phone,
    );

    emit(ProfileUpdating(updated));
    try {
      // await _repository.updateProfile(updated);
      emit(ProfileLoaded(profile: updated));
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }
}