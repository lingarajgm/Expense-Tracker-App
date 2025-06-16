import 'package:expense/core/error/failure.dart';
import 'package:expense/core/usecase/usecase.dart';
import 'package:expense/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLogout implements Usecase<void, NoParams> {
  final AuthRepository authRepository;
  UserLogout(this.authRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      await authRepository.logout();
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
