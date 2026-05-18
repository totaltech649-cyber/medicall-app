import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import 'common_widgets.dart';

class DoctorCard extends StatelessWidget {
  final UserModel doctor;
  final VoidCallback? onConsult;

  const DoctorCard({super.key, required this.doctor, required this.onConsult});

  String get _initials => doctor.name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0])
      .join()
      .toUpperCase();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(children: [
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(12)),
            child: doctor.photoUrl != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12),
                    child: Image.network(doctor.photoUrl!, fit: BoxFit.cover, width: 48, height: 48,
                      errorBuilder: (_, __, ___) => Center(child: Text(_initials,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.greenDark)))))
                : Center(child: Text(_initials,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.greenDark))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doctor.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('${doctor.speciality ?? 'Médecine générale'} · Cotonou',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.amber, size: 14),
              const SizedBox(width: 2),
              Text(
                doctor.rating > 0
                    ? '${doctor.rating.toStringAsFixed(1)} · ${doctor.reviewCount} avis'
                    : 'Nouveau médecin',
                style: const TextStyle(fontSize: 11, color: AppColors.amber)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            StatusBadge(
              label: doctor.isAvailable ? '● En ligne' : 'Occupé',
              bgColor: doctor.isAvailable ? AppColors.greenLight : const Color(0xFFFEF3C7),
              textColor: doctor.isAvailable ? AppColors.greenDark : const Color(0xFF92400E)),
            const SizedBox(height: 6),
            const Text('2 500 FCFA', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ]),
        ]),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: doctor.isAvailable ? onConsult : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10),
            disabledBackgroundColor: const Color(0xFFE5E7EB),
            disabledForegroundColor: AppColors.textMuted,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Sora')),
          icon: Icon(doctor.isAvailable ? Icons.video_call_outlined : Icons.access_time, size: 16),
          label: Text(doctor.isAvailable ? 'Consulter maintenant' : 'Occupé — Revenir plus tard'))),
      ]),
    );
  }
}
