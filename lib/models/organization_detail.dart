class OrganizationArea {
  const OrganizationArea({required this.id, required this.name});

  final int id;
  final String name;

  factory OrganizationArea.fromJson(Map<String, dynamic> json) =>
      OrganizationArea(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name']?.toString() ?? '',
      );
}

class OrganizationCnae {
  const OrganizationCnae({
    required this.code,
    required this.name,
    required this.isPrimary,
  });

  final String code;
  final String name;
  final bool isPrimary;

  factory OrganizationCnae.fromJson(Map<String, dynamic> json) {
    final cnae = json['cnae'] as Map<String, dynamic>? ?? {};
    return OrganizationCnae(
      code: json['cnae_code']?.toString() ?? cnae['code']?.toString() ?? '',
      name: cnae['name']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
    );
  }
}

class CompletenessCategory {
  const CompletenessCategory({
    required this.key,
    required this.label,
    required this.percentage,
  });

  final String key;
  final String label;
  final double percentage;

  factory CompletenessCategory.fromJson(Map<String, dynamic> json) =>
      CompletenessCategory(
        key: json['key']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      );
}

class OrganizationDetail {
  const OrganizationDetail({
    required this.id,
    required this.cnpj,
    required this.legalName,
    required this.tradeName,
    required this.legalNatureCode,
    required this.matrixOrBranch,
    required this.registrationStatus,
    required this.removedFromMosc,
    required this.foundationDate,
    required this.closingDate,
    required this.closingYear,
    required this.address,
    required this.municipalityCode,
    required this.latitude,
    required this.longitude,
    required this.areas,
    required this.subareas,
    required this.cnaes,
    required this.completenessAverage,
    required this.completenessCategories,
  });

  final int id;
  final String cnpj;
  final String legalName;
  final String tradeName;
  final int? legalNatureCode;
  final String matrixOrBranch;
  final String registrationStatus;
  final bool removedFromMosc;
  final String? foundationDate;
  final String? closingDate;
  final int? closingYear;
  final String address;
  final int? municipalityCode;
  final double? latitude;
  final double? longitude;
  final List<OrganizationArea> areas;
  final List<OrganizationArea> subareas;
  final List<OrganizationCnae> cnaes;
  final double completenessAverage;
  final List<CompletenessCategory> completenessCategories;

  factory OrganizationDetail.fromJson(Map<String, dynamic> json) {
    final completeness =
        json['completeness'] as Map<String, dynamic>? ?? {};

    List<OrganizationArea> parseAreas(dynamic value) =>
        (value as List? ?? [])
            .whereType<Map>()
            .map((e) => OrganizationArea.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();

    return OrganizationDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      cnpj: json['cnpj']?.toString() ?? '',
      legalName: json['legal_name']?.toString() ?? '',
      tradeName: json['trade_name']?.toString() ?? '',
      legalNatureCode: (json['legal_nature_code'] as num?)?.toInt(),
      matrixOrBranch: json['matrix_or_branch']?.toString() ?? '',
      registrationStatus: json['registration_status']?.toString() ?? '',
      removedFromMosc: json['removed_from_mosc'] == true,
      foundationDate: json['foundation_date']?.toString(),
      closingDate: json['closing_date']?.toString(),
      closingYear: (json['closing_year'] as num?)?.toInt(),
      address: json['address']?.toString() ?? '',
      municipalityCode: (json['municipality_code'] as num?)?.toInt(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      areas: parseAreas(json['areas']),
      subareas: parseAreas(json['subareas']),
      cnaes: (json['cnaes'] as List? ?? [])
          .whereType<Map>()
          .map((e) => OrganizationCnae.fromJson(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
      completenessAverage:
          (completeness['average'] as num?)?.toDouble() ?? 0,
      completenessCategories:
          (completeness['categories'] as List? ?? [])
              .whereType<Map>()
              .map((e) => CompletenessCategory.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList(),
    );
  }
}
