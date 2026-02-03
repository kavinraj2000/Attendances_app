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
  String? get emailId => data?.userDetails?.emailId;

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
      status: json['status'] as String?,
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      success: json['status'] == 'Success' && json['status_code'] == 1,
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
      responder: json['created_by'] != null 
          ? Responder.fromJson(json['created_by']) 
          : null,
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
  final int employeeId;
  final int companyId;
  final String tokenType;
  final int userId;
  final List<String> userRole;
  final String username;
  final UserDetails? userDetails;

  LoginData({
    required this.accessToken,
    required this.employeeId,
    required this.companyId,
    required this.tokenType,
    required this.userId,
    required this.userRole,
    required this.username,
    this.userDetails,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accesstoken'] as String,
      employeeId: json['employee_id'] as int,
      companyId: json['company_id'] as int,
      tokenType: json['tokentype'] as String? ?? 'Bearer',
      userId: json['userid'] as int,
      userRole: (json['userrole'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      username: json['username'] as String,
      userDetails: json['userdetails'] != null
          ? UserDetails.fromJson(json['userdetails'])
          : null,
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
      'userdetails': userDetails?.toJson(),
    };
  }

  // Convert to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'employee_id': employeeId,
      'user_role': userRole.join(','),
      'company_id': companyId,
      'email_id': userDetails?.emailId ?? '',
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  // Create from SQLite Map
  factory LoginData.fromMap(Map<String, dynamic> map) {
    return LoginData(
      accessToken: map['access_token'] as String,
      employeeId: map['employee_id'] as int,
      companyId: map['company_id'] as int,
      tokenType: map['token_type'] as String,
      userId: map['user_id'] as int,
      userRole: (map['user_role'] as String).split(','),
      username: map['username'] as String,
      userDetails: UserDetails(
        userId: map['user_id'] as int,
        username: map['username'] as String,
        employeeId: map['employee_id'] as int,
        userRole: (map['user_role'] as String).split(','),
        companyId: map['company_id'] as int,
        emailId: map['email_id'] as String,
      ),
    );
  }
}

class UserDetails {
  final int userId;
  final String username;
  final int employeeId;
  final List<String> userRole;
  final int companyId;
  final String emailId;

  UserDetails({
    required this.userId,
    required this.username,
    required this.employeeId,
    required this.userRole,
    required this.companyId,
    required this.emailId,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      userId: json['user_id'] as int,
      username: json['username'] as String,
      employeeId: json['employee_id'] as int,
      userRole: (json['user_role'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      companyId: json['company_id'] as int,
      emailId: json['email_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'employee_id': employeeId,
      'user_role': userRole,
      'company_id': companyId,
      'email_id': emailId,
    };
  }
}

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
      name: json['name'] as String,
      version: json['version'] as String,
      timestamp: json['timestamp'] as String,
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