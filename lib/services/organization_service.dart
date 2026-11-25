import '../core/api_client.dart';
import '../models/filter_options.dart';
import '../models/organization.dart';
import '../models/organization_detail.dart';

class OrganizationService {
  OrganizationService({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<FilterOptions> getFilters() async {
    final json = await _api.get('/filters') as Map<String, dynamic>;
    return FilterOptions.fromJson(json);
  }

  Future<List<String>> getCities(String stateCode) async {
    final json = await _api.get(
      '/filters/cities',
      queryParameters: {'state': stateCode},
    );

    // Supports either ["City A", "City B"] or {"cities": [...]}.
    // Adjust this parser if your endpoint returns a different structure.
    final dynamic values = json is List
        ? json
        : json is Map
            ? (json['cities'] ?? json['items'] ?? [])
            : [];

    return (values as List)
        .map((item) {
          if (item is Map) {
            return (item['name'] ?? item['city'] ?? '').toString();
          }
          return item.toString();
        })
        .where((city) => city.isNotEmpty)
        .toList();
  }

  Future<OrganizationPageResult> getOrganizations({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? state,
    String? city,
    String? status,
    int? legalNature,
    int? foundedFrom,
    int? foundedTo,
    String? activityArea,
  }) async {
    final query = <String, String?>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      'search': search,
      'state': state,
      'city': city,
      'status': status,
      'legalNature': legalNature?.toString(),
      'foundedFrom': foundedFrom?.toString(),
      'foundedTo': foundedTo?.toString(),
      'activityArea': activityArea,
    };

    final json = await _api.get(
      '/organizations',
      queryParameters: query,
    ) as Map<String, dynamic>;

    return OrganizationPageResult.fromJson(json);
  }

  Future<OrganizationDetail> getOrganizationById(int id) async {
    final json = await _api.get('/organizations/$id') as Map<String, dynamic>;
    return OrganizationDetail.fromJson(json);
  }
}
