class User {
  final int id;
  final String phone;
  final String? email;
  final String? fullName;
  final String kycStatus;
  final double balance;
  final String? photoUrl;
  final String? loginMethod;

  User({
    required this.id,
    required this.phone,
    this.email,
    this.fullName,
    required this.kycStatus,
    required this.balance,
    this.photoUrl,
    this.loginMethod,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'] ?? '',
      email: json['email'],
      fullName: json['full_name'] ?? json['display_name'],
      kycStatus: json['kyc_status'] ?? 'pending',
      balance: double.parse(json['balance']?.toString() ?? '0'),
      photoUrl: json['photo_url'],
      loginMethod: json['login_method'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'full_name': fullName,
      'kyc_status': kycStatus,
      'balance': balance,
      'photo_url': photoUrl,
      'login_method': loginMethod,
    };
  }
}
