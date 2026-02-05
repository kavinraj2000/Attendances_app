import 'dart:convert';


class LoginModel {
  final String? status;
  final String? message;
  final int? statusCode;
  final bool success;
  final LoginData? data;
  final Responder? responder;

  String? get token => data?.accessToken;
  int? get userId => data?.userId;
  String? get username => data?.username;
  int? get employeeId => data?.employeeId;
  int? get companyId => data?.companyId;
  List<String>? get userRole => data?.userRole;

  LoginModel({
    this.status,
    this.message,
    this.statusCode,
    required this.success,
    this.data,
    this.responder,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'],
      message: json['message'],
      statusCode: json['status_code'],
      success: json['status'] == 'Success' && json['status_code'] == 1,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      responder:
          json['created_by'] != null ? Responder.fromJson(json['created_by']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'status_code': statusCode,
      'data': data?.toJson(),
      'created_by': responder?.toJson(),
    };
  }
}


class LoginData {
  final String accessToken;
  final int? employeeId;
  final int companyId;
  final String tokenType;
  final int userId;
  final List<String> userRole;
  final String username;
  final String? emailId; // ✅ ADD THIS

  LoginData({
    required this.accessToken,
    this.employeeId,
    required this.companyId,
    required this.tokenType,
    required this.userId,
    required this.userRole,
    required this.username,
    this.emailId,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accesstoken'],
      employeeId: json['employee_id'],
      companyId: json['company_id'],
      tokenType: json['tokentype'] ?? 'Bearer',
      userId: json['userid'],
      userRole:
          (json['userrole'] as List).map((e) => e.toString()).toList(),
      username: json['username'],
      emailId: json['email_id'], // ✅ API FIELD
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accesstoken': accessToken,
      'employee_id': employeeId,
      'company_id': companyId,
      'tokentype': tokenType,
      'userid': userId,
      'userrole': userRole,
      'username': username,
      'email_id': emailId,
    };
  }
}

/// ─────────────────────────────────────────────────────────────
/// RESPONDER INFO
/// ─────────────────────────────────────────────────────────────
class Responder {
  final String name;
  final String version;
  final String timestamp;

  Responder({
    required this.name,
    required this.version,
    required this.timestamp,
  });

  factory Responder.fromJson(Map<String, dynamic> json) {
    return Responder(
      name: json['name'],
      version: json['version'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'version': version,
      'timestamp': timestamp,
    };
  }
}
class VerifyEmailRequest {
  final String requestName;
  final VerifyEmailData data;

  VerifyEmailRequest({
    this.requestName = 'verify_email',
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'requestname': requestName,
      'data': data.toJson(),
    };
  }
}

class VerifyEmailData {
  final String email;
  final String password;

  VerifyEmailData({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

