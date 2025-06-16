import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:expense/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense/features/auth/domain/usecases/user_signup.dart';
import 'package:expense/features/auth/domain/usecases/user_login.dart';
import 'package:expense/features/auth/domain/usecases/user_logout.dart';
import 'package:expense/features/auth/domain/usecases/current_user.dart';
import 'package:expense/features/auth/presentation/bloc/auth_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initFirebase();
  _initAuth();

  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton(() => sharedPreferences);

  // Register AppUserCubit
  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initFirebase() {
  // Register Firebase services
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator<FirebaseAuth>(), // Get FirebaseAuth instance
        serviceLocator<FirebaseFirestore>(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()),
    )
    ..registerFactory(() => UserSignup(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => UserLogout(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    ..registerLazySingleton(
      () => AuthBloc(
        userSignup: serviceLocator(),
        userLogin: serviceLocator(),
        userLogout: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}
