import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_exceptions.dart';
import '../core/config.dart';
import '../models/app_user.dart';
import '../models/role.dart';
import '../repositories/auth_api.dart';

class AuthNotifier extends ChangeNotifier {
  static const kAccess = 'auth_access_token';
  static const kRefresh = 'auth_refresh_token';
  static const kUser = 'auth_user';
  static const kLastActive = 'auth_last_active';
  static const kSessionStart = 'auth_session_start';

  AuthNotifier(this._prefs, this._api);

  final SharedPreferences _prefs;
  final AuthApi _api;

  AppUser? _user;
  String? _accessToken;
  String? _refreshToken;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null && _accessToken != null;

  DateTime? get sessionStartedAt {
    final started = _prefs.getInt(kSessionStart);
    if (started == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(started);
  }

  bool can(AppOp op) => _user != null && RoleAccess.allows(_user!.role, op);

  Future<void> restore() async {
    final access = _prefs.getString(kAccess);
    final refresh = _prefs.getString(kRefresh);
    final rawUser = _prefs.getString(kUser);
    if (access == null || rawUser == null) return;

    if (_sessionExpired || _inactiveTooLong) {
      await logout();
      return;
    }

    _accessToken = access;
    _refreshToken = refresh;
    try {
      _user = AppUser.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
    } catch (_) {
      await logout();
      return;
    }

    try {
      await _api.me();
    } on UnauthorizedException {
      if (refresh != null) {
        try {
          await refreshTokens();
        } catch (_) {
          await logout();
          return;
        }
      } else {
        await logout();
        return;
      }
    } catch (_) {}
    notifyListeners();
  }

  bool get _sessionExpired {
    final started = _prefs.getInt(kSessionStart);
    if (started == null) return false;
    return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(started),
        ) >=
        maxSessionDuration;
  }

  bool get _inactiveTooLong {
    final last = _prefs.getInt(kLastActive);
    if (last == null) return false;
    return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(last),
        ) >=
        inactivityTimeout;
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username.trim(), password);
    await _apply(result, newSession: true);
  }

  Future<void> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    final result = await _api.register(
      username: username.trim(),
      password: password,
      displayName: displayName.trim(),
    );
    await _apply(result, newSession: true);
  }

  Future<void> refreshTokens() async {
    final refresh = _refreshToken ?? _prefs.getString(kRefresh);
    if (refresh == null) {
      throw const UnauthorizedException();
    }
    final result = await _api.refresh(refresh);
    await _apply(result, newSession: false);
  }

  Future<void> logout() async {
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    await _prefs.remove(kAccess);
    await _prefs.remove(kRefresh);
    await _prefs.remove(kUser);
    await _prefs.remove(kLastActive);
    await _prefs.remove(kSessionStart);
    notifyListeners();
  }

  Future<void> markActivity() async {
    await _prefs.setInt(kLastActive, DateTime.now().millisecondsSinceEpoch);
  }

  @visibleForTesting
  void debugSetSession(AppUser user, {String token = 'test-token'}) {
    _user = user;
    _accessToken = token;
    notifyListeners();
  }

  Future<void> _apply(AuthTokens result, {required bool newSession}) async {
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    if (newSession || _user == null) {
      _user = result.user;
    }
    await _prefs.setString(kAccess, result.accessToken);
    await _prefs.setString(kRefresh, result.refreshToken);
    if (newSession || !_prefs.containsKey(kUser)) {
      await _prefs.setString(kUser, jsonEncode(result.user.toJson()));
    }
    if (newSession) {
      await _prefs.setInt(kSessionStart, DateTime.now().millisecondsSinceEpoch);
    }
    await markActivity();
    notifyListeners();
  }
}
