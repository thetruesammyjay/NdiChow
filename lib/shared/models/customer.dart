class Customer {
  const Customer({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class AuthSession {
  const AuthSession({
    required this.customer,
    required this.token,
    required this.expiresAt,
  });

  final Customer customer;
  final String token;
  final DateTime expiresAt;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
    token: json['token'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );
}
