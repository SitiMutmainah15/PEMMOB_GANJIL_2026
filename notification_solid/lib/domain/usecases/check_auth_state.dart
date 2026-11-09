import '../repositories/auth_repository.dart';

class CheckAuthState {
  const CheckAuthState(this._repository);

  final AuthRepository _repository;

  Future<bool> call() => _repository.hasSession();
}
