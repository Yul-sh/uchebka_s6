class CatalogQuery {
  final String search;
  final String? country;
  final String? status;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const CatalogQuery({
    this.search = '',
    this.country,
    this.status,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  CatalogQuery copyWith({
    String? search,
    Object? country = _unset,
    Object? status = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return CatalogQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      status: status == _unset ? this.status : status as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  factory CatalogQuery.fromUri(Uri uri, {String defaultSort = 'name'}) {
    final q = uri.queryParameters;
    final sort = q['sort'] ?? '$defaultSort,asc';
    final parts = sort.split(',');
    final country = q['country'];
    final status = q['status'];
    return CatalogQuery(
      search: q['search'] ?? '',
      country: (country == null || country.isEmpty) ? null : country,
      status: (status == null || status.isEmpty) ? null : status,
      sortField: parts.isEmpty || parts.first.isEmpty
          ? defaultSort
          : parts.first,
      sortAscending: parts.length < 2 || parts[1] != 'desc',
      page: int.tryParse(q['page'] ?? '') ?? 1,
      size: int.tryParse(q['size'] ?? '') ?? 10,
      includeDeleted:
          q['includeDeleted'] == '1' || q['includeDeleted'] == 'true',
    );
  }

  Map<String, String> toQueryParameters({String defaultSort = 'name'}) {
    final m = <String, String>{};
    if (search.isNotEmpty) m['search'] = search;
    if (country != null && country!.isNotEmpty) m['country'] = country!;
    if (status != null && status!.isNotEmpty) m['status'] = status!;
    if (sortField != defaultSort || !sortAscending) {
      m['sort'] = '$sortField,${sortAscending ? 'asc' : 'desc'}';
    }
    if (page != 1) m['page'] = '$page';
    if (size != 10) m['size'] = '$size';
    if (includeDeleted) m['includeDeleted'] = '1';
    return m;
  }

  @override
  bool operator ==(Object other) {
    return other is CatalogQuery &&
        other.search == search &&
        other.country == country &&
        other.status == status &&
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
    status,
    sortField,
    sortAscending,
    page,
    size,
    includeDeleted,
  );

  static const _unset = Object();
}
