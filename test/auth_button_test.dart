import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm/core/auth/bloc/auth_bloc.dart';
import 'package:hrm/core/auth/repo/auth_repo.dart';
import 'package:hrm/core/model/login_model.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepo {}

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    authBloc = AuthBloc(mockRepository);
  });

  tearDown(() async {
    await authBloc.close();
  });

  test('initial state is correct', () {
    expect(authBloc.state, AuthState.initial());
  });

  blocTest<AuthBloc, AuthState>(
    'emits updated state when EmailChanged is added',
    build: () => authBloc,
    act: (bloc) =>
        bloc.add(EmailChanged('kavinraj@earnpe.com')),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.email,
        'email',
        'kavinraj@earnpe.com',
      ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [loading, otpsend] when submission successful',
    build: () {
      when(() => mockRepository.requestAuth(
            email: any(named: 'email'),
          )).thenAnswer(
        (_) async => LoginModel(success: true),
      );

      return authBloc;
    },
    act: (bloc) =>
        bloc.add(AuthSubmitted(email: 'kavinraj@earnpe.com')),
    expect: () => [
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.loading,
      ),
      isA<AuthState>().having(
        (s) => s.status,
        'status',
        AuthStatus.otpsend,
      ),
    ],
  );
}