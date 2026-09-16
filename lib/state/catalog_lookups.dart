import 'package:flutter/foundation.dart';

import '../models/hotel.dart';
import '../models/lookups.dart';
import '../repositories/hotel_repository.dart';
import '../repositories/lookup_repositories.dart';

class CatalogLookups extends ChangeNotifier {
  CatalogLookups({
    required this._destinations,
    required this._hotels,
    required this._categories,
  });

  final DestinationRepository _destinations;
  final HotelRepository _hotels;
  final CategoryRepository _categories;

  List<Destination> destinations = [];
  List<Hotel> hotels = [];
  List<TourCategory> categories = [];

  List<Destination> get activeDestinations =>
      destinations.where((d) => !d.isDeleted).toList();
  List<Hotel> get activeHotels => hotels.where((h) => !h.isDeleted).toList();
  List<TourCategory> get activeCategories =>
      categories.where((c) => !c.isDeleted).toList();

  bool _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded && destinations.isNotEmpty) return;
    await reload();
  }

  Future<void> reload() async {
    destinations = await _destinations.findAll(includeDeleted: true);
    hotels = await _hotels.findAll(includeDeleted: true);
    categories = await _categories.findAll(includeDeleted: true);
    _loaded = true;
    notifyListeners();
  }

  String destinationName(int id) {
    for (final item in destinations) {
      if (item.id == id) return item.name;
    }
    return '—';
  }

  String categoryNames(List<int> ids) {
    final names = <String>[];
    for (final id in ids) {
      for (final item in categories) {
        if (item.id == id) names.add(item.name);
      }
    }
    return names.isEmpty ? '—' : names.join(', ');
  }

  String hotelNames(List<int> ids) {
    final names = <String>[];
    for (final id in ids) {
      for (final item in hotels) {
        if (item.id == id) names.add(item.name);
      }
    }
    return names.isEmpty ? '—' : names.join(', ');
  }
}
