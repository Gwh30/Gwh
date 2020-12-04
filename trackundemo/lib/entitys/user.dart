import 'package:flutter/foundation.dart';

// 登录请求
class UserRequestEntity {
  String grant_type;
  String client_id;
  String username;
  String password;

  UserRequestEntity({
    @required this.grant_type,
    @required this.client_id,
    @required this.username,
    @required this.password,
    String,
  });

  factory UserRequestEntity.fromJson(Map<String, dynamic> json) =>
      UserRequestEntity(
        grant_type: json["grant_type"],
        client_id: json["client_id"],
        username: json["username"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "grant_type": grant_type,
        "client_id": client_id,
        "username": username,
        "password": password,
      };
}

// 登录返回
class UserResponseEntity {
  String access_token;
  int expires_in;
  String refresh_token;
  int refresh_expires_in;
  String token_type;
  int not_before_policy;
  String session_state;
  String scope;

  UserResponseEntity(
      {@required this.access_token,
      this.expires_in,
      this.refresh_token,
      this.refresh_expires_in,
      this.token_type,
      this.not_before_policy,
      this.session_state,
      this.scope});

  factory UserResponseEntity.fromJson(Map<String, dynamic> json) =>
      UserResponseEntity(
        access_token: json["access_token"],
        expires_in: json["expires_in"],
        refresh_token: json["refresh_token"],
        refresh_expires_in: json["refresh_expires_in"],
        token_type: json["token_type"],
        not_before_policy: json["not_before_policy"],
        session_state: json["session_state"],
        scope: json["scope"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": access_token,
        "expires_in": expires_in,
        "refresh_token": refresh_token,
        "refresh_expires_in": refresh_expires_in,
        "token_type": token_type,
        "not_before_policy": not_before_policy,
        "session_state": session_state,
        "scope": scope
      };
}
