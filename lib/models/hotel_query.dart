class HotelQuery {
  final String search;
  final String? country;
  final int? stars;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const HotelQuery({
    this.search = '',
    this.country,
    this.stars,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  HotelQuery copyWith({
    String? search,
    Object? country = _unset,
    Object? stars = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return HotelQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      stars: stars == _unset ? this.stars : stars as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  factory HotelQuery.fromUri(Uri uri) {
    final q = uri.queryParameters;
    final sort = q['sort'] ?? 'name,asc';
    final parts = sort.split(',');
    final country = q['country'];
    return HotelQuery(
      search: q['search'] ?? '',
      country: (country == null || country.isEmpty) ? null : country,
      stars: int.tryParse(q['stars'] ?? ''),
      sortField: parts.isEmpty || parts.first.isEmpty ? 'name' : parts.first,
      sortAscending: parts.length < 2 || parts[1] != 'desc',
      page: int.tryParse(q['page'] ?? '') ?? 1,
      size: int.tryParse(q['size'] ?? '') ?? 10,
      includeDeleted:
          q['includeDeleted'] == '1' || q['includeDeleted'] == 'true',
    );
  }

  Map<String, String> toQueryParameters() {
    final m = <String, String>{};
    if (search.isNotEmpty) m['search'] = search;
    if (country != null && country!.isNotEmpty) m['country'] = country!;
    if (stars != null) m['stars'] = '$stars';
    if (sortField != 'name' || !sortAscending) {
      m['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) m['page'] = '$page';
    if (size != 10) m['size'] = '$size';
    if (includeDeleted) m['includeDeleted'] = '1';
    return m;
  }

  @override
  bool operator ==(Object other) {
    return other is HotelQuery &&
        other.search == search &&
        other.country == country &&
        other.stars == stars &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.page == page &&
        other.size == size &&
        other.includeDeleted == includeDeleted;
  }

  @override
  int get hashCode => Object.hash(
    search,
    country,
    stars,
    sortField,
    sortAscending,
    page,
    size,
    includeDeleted,
  );

  static const _unset = Object();
}
