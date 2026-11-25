class FilterOption {
  const FilterOption({required this.code, required this.name});

  final String code;
  final String name;

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      code: json['code'].toString(),
      name: json['name']?.toString() ?? json['code'].toString(),
    );
  }
}

class FilterOptions {
  const FilterOptions({
    required this.states,
    required this.statuses,
    required this.legalNatures,
    required this.activityAreas,
    required this.minFoundationYear,
    required this.maxFoundationYear,
  });

  final List<FilterOption> states;
  final List<String> statuses;
  final List<FilterOption> legalNatures;
  final List<String> activityAreas;
  final int minFoundationYear;
  final int maxFoundationYear;

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    final foundationYear = json['foundationYear'] as Map<String, dynamic>? ?? {};

    return FilterOptions(
      states: (json['states'] as List? ?? [])
          .whereType<Map>()
          .map((item) => FilterOption.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      statuses: (json['statuses'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      legalNatures: (json['legalNatures'] as List? ?? [])
          .whereType<Map>()
          .map((item) => FilterOption.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      activityAreas: (json['activityAreas'] as List? ?? [])
          .map((item) => item.toString())
          .toList(),
      minFoundationYear: (foundationYear['min'] as num?)?.toInt() ?? 1900,
      maxFoundationYear: (foundationYear['max'] as num?)?.toInt() ??
          DateTime.now().year,
    );
  }
}
