import 'role.dart';

class AppUser {
  final int id;
  final String username;
  final String displayName;
  final Role role;

  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] as int? ?? 0,
    username: '${json['username'] ?? ''}',
    displayName: '${json['displayName'] ?? json['username'] ?? ''}',
    role: roleFromApi(json['role'] as String?),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'displayName': displayName,
    'role': role.apiName,
  };

  AppUser copyWith({Role? role, String? displayName}) => AppUser(
    id: id,
    username: username,
    displayName: displayName ?? this.displayName,
    role: role ?? this.role,
  );
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
    accessToken: '${json['accessToken']}',
    refreshToken: '${json['refreshToken']}',
    user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
  );
}
