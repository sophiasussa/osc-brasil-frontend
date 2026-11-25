import 'package:flutter/material.dart';
import '../models/organization.dart';

class OrganizationCard extends StatelessWidget {
  const OrganizationCard({
    super.key,
    required this.organization,
    required this.onTap,
  });

  final Organization organization;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = organization.isActive;

    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFE0E8E3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                color: active ? const Color(0xFF147A4B) : Colors.deepPurple,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              organization.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF17231D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusPill(active: active, label: _statusLabel(organization.status)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Icon(Icons.location_on, size: 13, color: Color(0xFF789187)),
                          Text(
                            [organization.city, organization.state]
                                .where((e) => e.isNotEmpty)
                                .join(', '),
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF718078),
                            ),
                          ),
                          if (organization.foundationYear != null) ...[
                            const Text('·', style: TextStyle(color: Colors.grey)),
                            Text(
                              'Est. ${organization.foundationYear}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF718078),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (organization.activityAreas.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: organization.activityAreas.take(2).map((area) {
                            return _Tag(label: area);
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9AA9A1)),
              const SizedBox(width: 7),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Ativa';
      case 'INAPT':
        return 'Inapta';
      case 'SUSPENDED':
        return 'Suspensa';
      case 'CLOSED_OR_NULL':
        return 'Encerrada';
      default:
        return status.isEmpty ? 'Não informada' : status;
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF147A4B) : const Color(0xFF8A5A20);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE7F4EC) : const Color(0xFFFFF2DF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 9.5, color: Color(0xFF52665B)),
      ),
    );
  }
}
