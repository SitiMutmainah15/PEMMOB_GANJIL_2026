import '../../domain/entities/auth_session.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final access = json['accessToken'];
    final refresh = json['refreshToken'];
    if (access is! String ||
        access.isEmpty ||
        refresh is! String ||
        refresh.isEmpty) {
      throw const FormatException('Token tidak ditemukan di respons API');
    }
    return AuthSessionModel(accessToken: access, refreshToken: refresh);
  }

  AuthSession toEntity() =>
      AuthSession(accessToken: accessToken, refreshToken: refreshToken);
}
