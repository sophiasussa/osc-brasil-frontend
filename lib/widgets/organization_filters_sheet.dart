import 'package:flutter/material.dart';
import '../models/filter_options.dart';

class OrganizationFilters {
  const OrganizationFilters({
    this.state,
    this.city,
    this.status,
    this.legalNature,
    this.activityArea,
    this.foundedFrom,
    this.foundedTo,
  });

  final String? state;
  final String? city;
  final String? status;
  final int? legalNature;
  final String? activityArea;
  final int? foundedFrom;
  final int? foundedTo;

  int get activeCount => [
        state,
        city,
        status,
        legalNature,
        activityArea,
        foundedFrom,
        foundedTo,
      ].where((value) => value != null).length;

  OrganizationFilters copyWith({
    Object? state = _unset,
    Object? city = _unset,
    Object? status = _unset,
    Object? legalNature = _unset,
    Object? activityArea = _unset,
    Object? foundedFrom = _unset,
    Object? foundedTo = _unset,
  }) {
    return OrganizationFilters(
      state: identical(state, _unset) ? this.state : state as String?,
      city: identical(city, _unset) ? this.city : city as String?,
      status: identical(status, _unset) ? this.status : status as String?,
      legalNature: identical(legalNature, _unset) ? this.legalNature : legalNature as int?,
      activityArea: identical(activityArea, _unset) ? this.activityArea : activityArea as String?,
      foundedFrom: identical(foundedFrom, _unset) ? this.foundedFrom : foundedFrom as int?,
      foundedTo: identical(foundedTo, _unset) ? this.foundedTo : foundedTo as int?,
    );
  }

  static const _unset = Object();
  static const empty = OrganizationFilters();
}

class OrganizationFiltersSheet extends StatefulWidget {
  const OrganizationFiltersSheet({
    super.key,
    required this.options,
    required this.initialFilters,
    required this.loadCities,
  });

  final FilterOptions options;
  final OrganizationFilters initialFilters;
  final Future<List<String>> Function(String state) loadCities;

  @override
  State<OrganizationFiltersSheet> createState() => _OrganizationFiltersSheetState();
}

class _OrganizationFiltersSheetState extends State<OrganizationFiltersSheet> {
  late OrganizationFilters _filters;
  List<String> _cities = [];
  bool _loadingCities = false;
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _fromController = TextEditingController(text: _filters.foundedFrom?.toString() ?? '');
    _toController = TextEditingController(text: _filters.foundedTo?.toString() ?? '');
    if (_filters.state != null) _fetchCities(_filters.state!);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _fetchCities(String state) async {
    setState(() {
      _loadingCities = true;
      _cities = [];
    });
    try {
      final cities = await widget.loadCities(state);
      if (!mounted) return;
      setState(() {
        _cities = cities;
        if (!_cities.contains(_filters.city)) {
          _filters = _filters.copyWith(city: null);
        }
      });
    } catch (_) {
      if (mounted) setState(() => _cities = []);
    } finally {
      if (mounted) setState(() => _loadingCities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text('Filtros', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filters = OrganizationFilters.empty;
                        _cities = [];
                        _fromController.clear();
                        _toController.clear();
                      });
                    },
                    child: const Text('Limpar tudo'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _fieldLabel('Estado'),
              DropdownButtonFormField<String>(
                value: _filters.state,
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Selecione um estado'),
                items: options.states.map((item) => DropdownMenuItem(
                  value: item.code,
                  child: Text('${item.name} (${item.code})'),
                )).toList(),
                onChanged: (value) {
                  setState(() => _filters = _filters.copyWith(state: value, city: null));
                  if (value != null) {
                    _fetchCities(value);
                  } else {
                    setState(() => _cities = []);
                  }
                },
              ),
              const SizedBox(height: 14),
              _fieldLabel('Cidade'),
              DropdownButtonFormField<String>(
                value: _cities.contains(_filters.city) ? _filters.city : null,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: _filters.state == null ? 'Selecione primeiro um estado' : 'Selecione uma cidade',
                  suffixIcon: _loadingCities
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                ),
                items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                onChanged: _filters.state == null || _loadingCities
                    ? null
                    : (value) => setState(() => _filters = _filters.copyWith(city: value)),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Situação cadastral'),
              DropdownButtonFormField<String>(
                value: options.statuses.contains(_filters.status) ? _filters.status : null,
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Todas as situações'),
                items: options.statuses.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(_statusLabel(status)),
                )).toList(),
                onChanged: (value) => setState(() => _filters = _filters.copyWith(status: value)),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Área de atuação'),
              DropdownButtonFormField<String>(
                value: options.activityAreas.contains(_filters.activityArea) ? _filters.activityArea : null,
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Todas as áreas'),
                items: options.activityAreas.map((area) => DropdownMenuItem(value: area, child: Text(area))).toList(),
                onChanged: (value) => setState(() => _filters = _filters.copyWith(activityArea: value)),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Natureza jurídica'),
              DropdownButtonFormField<int>(
                value: options.legalNatures.any((e) => int.tryParse(e.code) == _filters.legalNature)
                    ? _filters.legalNature
                    : null,
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Todas as naturezas'),
                items: options.legalNatures.map((item) => DropdownMenuItem(
                  value: int.tryParse(item.code),
                  child: Text(item.name),
                )).toList(),
                onChanged: (value) => setState(() => _filters = _filters.copyWith(legalNature: value)),
              ),
              const SizedBox(height: 14),
              _fieldLabel('Ano de fundação'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _fromController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'De'),
                      onChanged: (value) => _filters = _filters.copyWith(foundedFrom: int.tryParse(value)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('até'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _toController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: 'Até'),
                      onChanged: (value) => _filters = _filters.copyWith(foundedTo: int.tryParse(value)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context, _filters);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Aplicar filtros'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
      );

  String _statusLabel(String value) {
    switch (value) {
      case 'ACTIVE': return 'Ativa';
      case 'CLOSED_OR_NULL': return 'Encerrada ou não informada';
      case 'INAPT': return 'Inapta';
      case 'SUSPENDED': return 'Suspensa';
      default: return value;
    }
  }
}
