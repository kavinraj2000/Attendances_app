class User {
  final int userId;
  final String username;
  final int employeeId;
  final List<String> userRole;
  final int companyId;
  final String emailId;
  final String accessToken;
  final String tokenType;

  User({
    required this.userId,
    required this.username,
    required this.employeeId,
    required this.userRole,
    required this.companyId,
    required this.emailId,
    required this.accessToken,
    required this.tokenType,
  });

  // Convert User object to Map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'username': username,
      'employee_id': employeeId,
      'user_role': userRole.join(','), // Store roles as comma-separated string
      'company_id': companyId,
      'email_id': emailId,
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'] as int,
      username: map['username'] as String,
      employeeId: map['employee_id'] as int,
      userRole: (map['user_role'] as String).split(','), // Split comma-separated roles
      companyId: map['company_id'] as int,
      emailId: map['email_id'] as String,
      accessToken: map['access_token'] as String,
      tokenType: map['token_type'] as String,
    );
  }

  // Create User from API response JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userid'] as int,
      username: json['username'] as String,
      employeeId: json['employee_id'] as int,
      userRole: List<String>.from(json['userrole'] as List),
      companyId: json['company_id'] as int,
      emailId: json['userdetails']['email_id'] as String,
      accessToken: json['accesstoken'] as String,
      tokenType: json['tokentype'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userid': userId,
      'username': username,
      'employee_id': employeeId,
      'userrole': userRole,
      'company_id': companyId,
      'email_id': emailId,
      'accesstoken': accessToken,
      'tokentype': tokenType,
    };
  }

  @override
  String toString() {
    return 'User{userId: $userId, username: $username, emailId: $emailId}';
  }
}