// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hrm/core/model/login_model.dart';
// import 'package:hrm/screens/profile/repo/profile_repo.dart';
// import 'package:logger/logger.dart';

// part 'profile_event.dart';
// part 'profile_state.dart';

// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   final ProfileRepo _repo;

//   ProfileBloc({required ProfileRepo repo})
//       : _repo = repo,
//         super(ProfileInitial()) {
//     on<ProfileLoadRequested>(_onLoad);
//     on<ProfileLogoutRequested>(_onLogout);
//   }

//   Future<void> _onLoad(
//     ProfileLoadRequested event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ProfileLoading());
//     try {
//       final data = await _repo.getProfileData();
//       emit(ProfileLoaded(
//         username:   data.username,
     
//       ));

//       Logger().d('_onLoad::${data.loginData?.toJson()}::::${data.emailId}');
//     } catch (e) {
//       emit(ProfileError('Failed to load profile: $e'));
//     }
//   }

//   Future<void> _onLogout(
//     ProfileLogoutRequested event,
//     Emitter<ProfileState> emit,
//   ) async {
//     try {
//       await _repo.logout();
//       emit(ProfileLoggedOut());
//     } catch (e) {
//       emit(ProfileError('Logout failed: $e'));
//     }
//   }
// }