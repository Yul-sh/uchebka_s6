import '../data/json_codec.dart';

class Tour {
  final int id;
  final String title;
  final String code;
  final int year;
  final int durationDays;
  final int destinationId;
  final List<int> hotelIds;
  final List<int> categoryIds;
  final int seatsTotal;
  final int seatsAvailable;
  final int price;
  final DateTime? deletedAt;

  const Tour({
    required this.id,
    required this.title,
    required this.code,
    required this.year,
    required this.durationDays,
    required this.destinationId,
    required this.hotelIds,
    required this.categoryIds,
    required this.seatsTotal,
    required this.seatsAvailable,
    required this.price,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Tour copyWith({
    String? title,
    String? code,
    int? year,
    int? durationDays,
    int? destinationId,
    List<int>? hotelIds,
    List<int>? categoryIds,
    int? seatsTotal,
    int? seatsAvailable,
    int? price,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Tour(
      id: id,
      title: title ?? this.title,
      code: code ?? this.code,
      year: year ?? this.year,
      durationDays: durationDays ?? this.durationDays,
      destinationId: destinationId ?? this.destinationId,
      hotelIds: hotelIds ?? this.hotelIds,
      categoryIds: categoryIds ?? this.categoryIds,
      seatsTotal: seatsTotal ?? this.seatsTotal,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      price: price ?? this.price,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'code': code,
    'year': year,
    'durationDays': durationDays,
    'destinationId': destinationId,
    'hotelIds': hotelIds,
    'categoryIds': categoryIds,
    'seatsTotal': seatsTotal,
    'seatsAvailable': seatsAvailable,
    'price': price,
    'deletedAt': deletedAt?.toIso8601String(),
  };

  factory Tour.fromJson(Map<String, dynamic> json) => Tour(
    id: jsonInt(json['id']),
    title: jsonString(json['title']),
    code: jsonString(json['code']),
    year: jsonInt(json['year']),
    durationDays: jsonInt(json['durationDays']),
    destinationId: json['destinationId'] != null
        ? jsonInt(json['destinationId'])
        : jsonNestedId(json['destination']),
    hotelIds: json['hotelIds'] != null
        ? jsonIntList(json['hotelIds'])
        : jsonNestedIds(json['hotels']),
    categoryIds: json['categoryIds'] != null
        ? jsonIntList(json['categoryIds'])
        : jsonNestedIds(json['categories']),
    seatsTotal: jsonInt(json['seatsTotal']),
    seatsAvailable: jsonInt(json['seatsAvailable']),
    price: jsonInt(json['price']),
    deletedAt: jsonDate(json['deletedAt']),
  );
}
