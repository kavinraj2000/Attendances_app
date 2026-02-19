part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileLogoutRequested extends ProfileEvent {}