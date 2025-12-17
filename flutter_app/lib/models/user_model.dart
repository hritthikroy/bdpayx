class User {
  final String id; // Changed to String to support Google IDs
  final String phone;
  final String? email;
  final String? fullName;
  final String kycStatus;
  final double balance;
  final double inrBalance;
  final String? photoUrl;
  final String? loginMethod;

  User({
    required this.id,
    required this.phone,
    this.email,
    this.fullName,
    required this.kycStatus,
    required this.balance,
    this.inrBalance = 0.0,
    this.photoUrl,
    this.loginMethod,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '', // Convert to string for compatibility
      phone: json['phone'] ?? '',
      email: json['email'],
      fullName: json['full_name'] ?? json['display_name'],
      kycStatus: json['kyc_status'] ?? 'pending',
      balance: double.parse(json['balance']?.toString() ?? '0'),
      inrBalance: double.parse(json['inr_balance']?.toString() ?? '0'),
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
      'inr_balance': inrBalance,
      'photo_url': photoUrl,
      'login_method': loginMethod,
    };
  }

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? fullName,
    String? kycStatus,
    double? balance,
    double? inrBalance,
    String? photoUrl,
    String? loginMethod,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      kycStatus: kycStatus ?? this.kycStatus,
      balance: balance ?? this.balance,
      inrBalance: inrBalance ?? this.inrBalance,
      photoUrl: photoUrl ?? this.photoUrl,
      loginMethod: loginMethod ?? this.loginMethod,
    );
  }
}
