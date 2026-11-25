class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.cnpj,
    required this.city,
    required this.state,
    required this.status,
    required this.legalNature,
    required this.foundationYear,
    required this.activityAreas,
  });

  final int id;
  final String name;
  final String cnpj;
  final String city;
  final String state;
  final String status;
  final String legalNature;
  final int? foundationYear;
  final List<String> activityAreas;

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? 'Organização sem nome',
      cnpj: json['cnpj']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      legalNature: json['legal_nature']?.toString() ?? '',
      foundationYear: (json['foundation_year'] as num?)?.toInt(),
      activityAreas: (json['activity_areas'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}

class OrganizationPageResult {
  const OrganizationPageResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  final List<Organization> items;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  factory OrganizationPageResult.fromJson(Map<String, dynamic> json) {
    return OrganizationPageResult(
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((item) => Organization.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['page_size'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 0,
    );
  }
}
