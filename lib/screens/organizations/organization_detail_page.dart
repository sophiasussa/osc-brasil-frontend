import 'package:flutter/material.dart';
import '../../models/organization_detail.dart';
import '../../services/organization_service.dart';

class OrganizationDetailPage extends StatefulWidget {
  const OrganizationDetailPage({
    super.key,
    required this.organizationId,
    required this.service,
  });

  final int organizationId;
  final OrganizationService service;

  @override
  State<OrganizationDetailPage> createState() => _OrganizationDetailPageState();
}

class _OrganizationDetailPageState extends State<OrganizationDetailPage> {
  late Future<OrganizationDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.getOrganizationById(widget.organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da organização')),
      body: FutureBuilder<OrganizationDetail>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    const Text('Não foi possível carregar os detalhes.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(() {
                        _future = widget.service.getOrganizationById(widget.organizationId);
                      }),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final organization = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Text(
                organization.tradeName.isNotEmpty
                    ? organization.tradeName
                    : organization.legalName,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              if (organization.tradeName.isNotEmpty &&
                  organization.legalName.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(organization.legalName, style: const TextStyle(color: Colors.black54)),
              ],
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Identificação',
                children: [
                  _InfoRow('CNPJ', organization.cnpj),
                  _InfoRow('Natureza jurídica', organization.legalNatureCode?.toString()),
                  _InfoRow('Matriz ou filial', organization.matrixOrBranch),
                  _InfoRow('Situação cadastral', organization.registrationStatus),
                  _InfoRow('Removida do Mapa OSC', organization.removedFromMosc ? 'Sim' : 'Não'),
                ],
              ),
              _InfoCard(
                title: 'Localização',
                children: [
                  _InfoRow('Endereço', organization.address),
                  _InfoRow('Código do município', organization.municipalityCode?.toString()),
                  _InfoRow(
                    'Coordenadas',
                    organization.latitude != null && organization.longitude != null
                        ? '${organization.latitude}, ${organization.longitude}'
                        : null,
                  ),
                ],
              ),
              _InfoCard(
                title: 'Datas',
                children: [
                  _InfoRow('Data de fundação', _formatDate(organization.foundationDate)),
                  _InfoRow('Data de encerramento', _formatDate(organization.closingDate)),
                  _InfoRow('Ano de encerramento', organization.closingYear?.toString()),
                ],
              ),
              _InfoCard(
                title: 'Áreas de atuação',
                children: [
                  if (organization.areas.isEmpty)
                    const Text('Nenhuma área informada')
                  else
                    ...organization.areas.map((area) => _BulletText(area.name)),
                  if (organization.subareas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text('Subáreas', style: TextStyle(fontWeight: FontWeight.w600)),
                    ...organization.subareas.map((area) => _BulletText(area.name)),
                  ],
                ],
              ),
              _InfoCard(
                title: 'Atividades econômicas (CNAE)',
                children: organization.cnaes.isEmpty
                    ? [const Text('Nenhum CNAE informado')]
                    : organization.cnaes.map((cnae) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${cnae.code} — ${cnae.name}'),
                              if (cnae.isPrimary)
                                const Text('Atividade principal', style: TextStyle(fontSize: 11, color: Color(0xFF147A4B))),
                            ],
                          ),
                        );
                      }).toList(),
              ),
              _InfoCard(
                title: 'Completude dos dados',
                children: [
                  Text(
                    '${organization.completenessAverage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF147A4B)),
                  ),
                  const SizedBox(height: 10),
                  ...organization.completenessCategories.map((category) {
                    final value = (category.percentage / 100).clamp(0.0, 1.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(child: Text(category.label, style: const TextStyle(fontSize: 12))),
                              Text('${category.percentage.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          LinearProgressIndicator(value: value, minHeight: 6),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String? _formatDate(String? value) {
    if (value == null || value.isEmpty || value == 'null') return null;
    final date = DateTime.tryParse(value);
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 13),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE0E8E3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 13),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty || value == 'null') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          const SizedBox(height: 2),
          Text(value!, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  '),
            Expanded(child: Text(text)),
          ],
        ),
      );
}
