import 'package:expense/core/common/entities/user.dart';
import 'package:expense/core/error/failure.dart';
import 'package:expense/core/usecase/usecase.dart';
import 'package:expense/features/auth/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUser implements Usecase<User, NoParams> {
  final AuthRepository authRepository;
  CurrentUser(this.authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await authRepository.currentUser();
  }
}
