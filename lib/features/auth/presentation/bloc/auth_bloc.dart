import 'package:expense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:expense/core/common/entities/user.dart';
import 'package:expense/core/usecase/usecase.dart';
import 'package:expense/features/auth/domain/usecases/current_user.dart';
import 'package:expense/features/auth/domain/usecases/user_login.dart';
import 'package:expense/features/auth/domain/usecases/user_logout.dart';
import 'package:expense/features/auth/domain/usecases/user_signup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignup _userSignup;
  final UserLogin _userLogin;
  final UserLogout _userLogout;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignup userSignup,
    required UserLogin userLogin,
    required UserLogout userLogout,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
  }) : _userLogin = userLogin,
       _userSignup = userSignup,
       _userLogout = userLogout,
       _currentUser = currentUser,
       _appUserCubit = appUserCubit,
       super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthLogout>(_onAuthLogOut);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    final res = await _userSignup(
      UserSignUpParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final res = await _userLogin(
      UserLoginParams(email: event.email, password: event.password),
    );
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthLogOut(AuthLogout event, Emitter<AuthState> emit) async {
    final result = await _userLogout(NoParams());

    result.fold(
      (failure) => emit(AuthFailure(failure.message)), // Emit failure state
      (_) => emit(AuthLoggedOut()), // Emit logged-out state on success
    );
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
