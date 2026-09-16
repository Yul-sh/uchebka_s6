import '../data/json_codec.dart';

class LoyaltyCard {
  final String number;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final String status;

  const LoyaltyCard({
    required this.number,
    required this.issuedAt,
    this.expiresAt,
    this.status = 'active',
  });

  LoyaltyCard copyWith({
    String? number,
    DateTime? issuedAt,
    DateTime? expiresAt,
    String? status,
    bool clearExpiresAt = false,
  }) {
    return LoyaltyCard(
      number: number ?? this.number,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'number': number,
    'issuedAt': issuedAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'status': status,
  };

  factory LoyaltyCard.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LoyaltyCard(number: '', issuedAt: DateTime.now());
    }
    return LoyaltyCard(
      number: jsonString(json['number']),
      issuedAt: jsonDate(json['issuedAt']) ?? DateTime.now(),
      expiresAt: jsonDate(json['expiresAt']),
      status: jsonString(json['status'], 'active'),
    );
  }
}
