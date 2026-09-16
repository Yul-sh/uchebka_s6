import '../data/json_codec.dart';
import 'loyalty_card.dart';

class Client {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final LoyaltyCard card;
  final DateTime? deletedAt;

  const Client({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.card,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;
  String get fullName => '$lastName $firstName';

  Client copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    LoyaltyCard? card,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Client(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      card: card ?? this.card,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'card': card.toJson(),
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Client.fromJson(Map<String, dynamic> json) => Client(
    id: jsonInt(json['id']),
    firstName: jsonString(json['firstName']),
    lastName: jsonString(json['lastName']),
    email: jsonString(json['email']),
    phone: jsonString(json['phone']),
    card: LoyaltyCard.fromJson(
      json['card'] is Map<String, dynamic>
          ? json['card'] as Map<String, dynamic>
          : null,
    ),
    deletedAt: jsonDate(json['deletedAt']),
  );
}
