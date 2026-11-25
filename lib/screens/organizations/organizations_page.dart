import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/filter_options.dart';
import '../../models/organization.dart';
import '../../services/organization_service.dart';
import '../../widgets/organization_card.dart';
import '../../widgets/organization_filters_sheet.dart';
import 'organization_detail_page.dart';

class OrganizationsPage extends StatefulWidget {
  const OrganizationsPage({super.key});

  @override
  State<OrganizationsPage> createState() => _OrganizationsPageState();
}

class _OrganizationsPageState extends State<OrganizationsPage> {
  final OrganizationService _service = OrganizationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  FilterOptions? _filterOptions;
  OrganizationFilters _filters = OrganizationFilters.empty;
  final List<Organization> _organizations = [];

  bool _loadingInitial = true;
  bool _loadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _page = 1;
  final int _pageSize = 20;
  int _total = 0;
  int _totalPages = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final options = await _service.getFilters();
      if (!mounted) return;
      setState(() => _filterOptions = options);
      await _loadOrganizations(reset: true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingInitial = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _loadOrganizations(reset: true);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _loadingMore || _loadingInitial) return;
    if (_scrollController.position.extentAfter < 350) {
      _loadNextPage();
    }
  }

  Future<void> _loadOrganizations({required bool reset}) async {
    if (reset) {
      setState(() {
        _loadingInitial = true;
        _hasError = false;
        _errorMessage = null;
        _page = 1;
        _organizations.clear();
      });
    }

    try {
      final result = await _service.getOrganizations(
        page: 1,
        pageSize: _pageSize,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        state: _filters.state,
        city: _filters.city,
        status: _filters.status,
        legalNature: _filters.legalNature,
        foundedFrom: _filters.foundedFrom,
        foundedTo: _filters.foundedTo,
        activityArea: _filters.activityArea,
      );

      if (!mounted) return;
      setState(() {
        _organizations
          ..clear()
          ..addAll(result.items);
        _page = result.page;
        _total = result.total;
        _totalPages = result.totalPages;
        _loadingInitial = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingInitial = false;
        _hasError = true;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _loadNextPage() async {
    if (_page >= _totalPages || _organizations.isEmpty) return;

    setState(() => _loadingMore = true);
    try {
      final result = await _service.getOrganizations(
        page: _page + 1,
        pageSize: _pageSize,
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        state: _filters.state,
        city: _filters.city,
        status: _filters.status,
        legalNature: _filters.legalNature,
        foundedFrom: _filters.foundedFrom,
        foundedTo: _filters.foundedTo,
        activityArea: _filters.activityArea,
      );

      if (!mounted) return;
      setState(() {
        _organizations.addAll(result.items);
        _page = result.page;
        _total = result.total;
        _totalPages = result.totalPages;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadingMore = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _openFilters() async {
    final options = _filterOptions;
    if (options == null) return;

    final selected = await showModalBottomSheet<OrganizationFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => OrganizationFiltersSheet(
        options: options,
        initialFilters: _filters,
        loadCities: _service.getCities,
      ),
    );

    if (selected != null) {
      setState(() => _filters = selected);
      await _loadOrganizations(reset: true);
    }
  }

  Future<void> _openDetails(Organization organization) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrganizationDetailPage(
          organizationId: organization.id,
          service: _service,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeFilters = _filters.activeCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organizações',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w500, color: Color(0xFF17231D)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar nome ou CNPJ',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8A9991)),
                    prefixIcon: const Icon(Icons.search, size: 19, color: Color(0xFF789187)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openFilters,
                        icon: const Icon(Icons.tune, size: 15),
                        label: Text(activeFilters == 0 ? 'Filtros' : 'Filtros ($activeFilters)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF52665B),
                          side: const BorderSide(color: Color(0xFFDCE6E0)),
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (activeFilters > 0) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() => _filters = OrganizationFilters.empty);
                          _loadOrganizations(reset: true);
                        },
                        child: const Text('Limpar'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE5ECE7)),
                bottom: BorderSide(color: Color(0xFFE5ECE7)),
              ),
            ),
            child: Text(
              _loadingInitial
                  ? 'Carregando organizações...'
                  : '${_organizations.length} de ${_total.toString()} organizações',
              style: const TextStyle(fontSize: 11, color: Color(0xFF718078)),
            ),
          ),
          Expanded(child: _buildList()),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        height: 62,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.account_balance_outlined), label: 'Orgs'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Estatísticas'),
        ],
        onDestinationSelected: (index) {
          if (index != 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Esta seção será implementada em breve.')),
            );
          }
        },
      ),
    );
  }

  Widget _buildList() {
    if (_loadingInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _organizations.isEmpty) {
      return _ErrorState(
        message: _errorMessage ?? 'Ocorreu um erro.',
        onRetry: () => _loadOrganizations(reset: true),
      );
    }

    if (_organizations.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _loadOrganizations(reset: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 100),
            Icon(Icons.search_off, size: 42, color: Color(0xFF9AA9A1)),
            SizedBox(height: 12),
            Center(child: Text('Nenhuma organização encontrada')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadOrganizations(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(18, 11, 18, 16),
        itemCount: _organizations.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _organizations.length) {
            return const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final organization = _organizations[index];
          return OrganizationCard(
            organization: organization,
            onTap: () => _openDetails(organization),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: Color(0xFF899A90)),
            const SizedBox(height: 12),
            const Text('Não foi possível carregar as organizações'),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
