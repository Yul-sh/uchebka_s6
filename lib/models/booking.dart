class Booking {
  final int id;
  final int tourId;
  final String tourTitle;
  final int userId;
  final String status;
  final DateTime expiresAt;

  const Booking({
    required this.id,
    required this.tourId,
    required this.tourTitle,
    required this.userId,
    required this.status,
    required this.expiresAt,
  });

  bool get isActive => status == 'active';

  String get statusRu => isActive ? 'активно' : 'не активно';

  String get expiresFormatted {
    final d = expiresAt.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  String get managerSubtitle =>
      'клиент #$userId · $statusRu · до $expiresFormatted';

  String get subtitleRu => isActive
      ? 'активно до $expiresFormatted'
      : 'не активно · до $expiresFormatted';

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as int? ?? 0,
    tourId: json['tourId'] as int? ?? 0,
    tourTitle: '${json['tourTitle'] ?? ''}',
    userId: json['userId'] as int? ?? 0,
    status: '${json['status'] ?? 'active'}',
    expiresAt: DateTime.tryParse('${json['expiresAt']}') ?? DateTime.now(),
  );
}
