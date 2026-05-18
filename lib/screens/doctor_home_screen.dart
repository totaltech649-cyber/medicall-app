import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../services/firestore_service.dart';
import '../models/consultation_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _tab = 0;
  final _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<app.AuthProvider>().user!;
    final screens = [_dashTab(user), _consultTab(user), ProfileScreen(isDoctor: true)];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: MediCallAppBar(actions: [
        Stack(children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted),
            onPressed: () => showAppToast(context, 'Notifications bientôt disponibles')),
          Positioned(top: 10, right: 10,
            child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))),
        ]),
        GestureDetector(
          onTap: () => setState(() => _tab = 2),
          child: Container(width: 36, height: 36, margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(color: Color(0xFFE6F1FB), shape: BoxShape.circle),
            child: Center(child: Text(
              user.name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF042C53)))))),
      ]),
      body: screens[_tab],
      bottomNavigationBar: _nav(),
    );
  }

  Widget _nav() {
    final items = [
      [Icons.dashboard_outlined, Icons.dashboard_rounded, 'Tableau'],
      [Icons.video_call_outlined, Icons.video_call_rounded, 'Consulter'],
      [Icons.person_outline_rounded, Icons.person_rounded, 'Profil'],
    ];
    return Container(
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: List.generate(items.length, (i) {
          final active = _tab == i;
          return Expanded(child: GestureDetector(onTap: () => setState(() => _tab = i),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(active ? items[i][1] as IconData : items[i][0] as IconData,
                color: active ? AppColors.green : AppColors.textLight, size: 22),
              const SizedBox(height: 4),
              Text(items[i][2] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,
                color: active ? AppColors.green : AppColors.textLight)),
            ])));
        })))),
    );
  }

  Widget _dashTab(user) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Hero
      Container(padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.greenDark, Color(0xFF0A5040)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          Text('${user.speciality ?? 'Médecin'} · Cotonou',
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Accepter des consultations', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                Text(user.isAvailable ? 'Visible pour les patients' : 'Hors ligne',
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ]),
              GestureDetector(
                onTap: () async {
                  await _db.setDoctorAvailability(user.uid, !user.isAvailable);
                  if (mounted) showAppToast(context,
                    !user.isAvailable ? 'Vous êtes maintenant disponible' : 'Vous êtes hors ligne',
                    success: !user.isAvailable);
                },
                child: AnimatedContainer(duration: const Duration(milliseconds: 250),
                  width: 50, height: 28,
                  decoration: BoxDecoration(
                    color: user.isAvailable ? const Color(0xFF4ADE80) : Colors.white30,
                    borderRadius: BorderRadius.circular(14)),
                  child: AnimatedAlign(duration: const Duration(milliseconds: 250),
                    alignment: user.isAvailable ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(margin: const EdgeInsets.all(3), width: 22, height: 22,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))))),
            ])),
        ])),
      const SizedBox(height: 16),

      // Stats
      FutureBuilder<Map<String, dynamic>>(
        future: _db.getDoctorStats(user.uid),
        builder: (ctx, snap) {
          final stats = snap.data;
          return Row(children: [
            _earnCard('Gains du mois', stats != null ? '${stats['monthlyEarnings'].toInt()} FCFA' : '—', 'ce mois'),
            const SizedBox(width: 10),
            _earnCard('Consultations', stats != null ? '${stats['monthlyConsultations']}' : '—', 'ce mois'),
          ]);
        }),
      const SizedBox(height: 20),

      // File d'attente
      StreamBuilder<List<ConsultationModel>>(
        stream: _db.doctorQueueStream(user.uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.green));
          }
          final queue = snap.data ?? [];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('File d\'attente', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
                child: Text('${queue.length} patient(s)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)))),
            ]),
            const SizedBox(height: 12),
            if (queue.isEmpty)
              const AppCard(child: Center(child: Padding(padding: EdgeInsets.all(16),
                child: Text('Aucun patient en attente', style: TextStyle(color: AppColors.textMuted)))))
            else
              ...queue.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _queueItem(e.key + 1, e.value))),
            if (queue.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => _startConsult(queue.first),
                icon: const Icon(Icons.video_call_outlined, size: 18),
                label: const Text('Démarrer la prochaine consultation'))),
            ],
          ]);
        }),
      const SizedBox(height: 20),

      // Note
      AppCard(child: Row(children: [
        Text(user.rating > 0 ? user.rating.toStringAsFixed(1) : '—',
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.amber)),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('★★★★★', style: TextStyle(color: AppColors.amber, fontSize: 18)),
          Text('Basé sur ${user.reviewCount} avis patients',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ]),
      ])),
      const SizedBox(height: 20),
    ]);
  }

  Widget _consultTab(user) {
    return StreamBuilder<List<ConsultationModel>>(
      stream: _db.doctorQueueStream(user.uid),
      builder: (ctx, snap) {
        final queue = snap.data ?? [];
        return Center(child: Padding(padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.video_call_outlined, color: AppColors.green, size: 40)),
            const SizedBox(height: 20),
            const Text('Prêt à consulter ?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('${queue.length} patient(s) en attente',
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: queue.isEmpty ? null : () => _startConsult(queue.first),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(queue.isEmpty ? 'Aucun patient en attente' : 'Démarrer la consultation'))),
          ])));
      });
  }

  Widget _earnCard(String label, String value, String sub) => Expanded(child: AppCard(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.green)),
      Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
    ])));

  Widget _queueItem(int num, ConsultationModel c) => AppCard(
    onTap: () => _startConsult(c),
    child: Row(children: [
      Container(width: 32, height: 32,
        decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text('$num', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.green)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.patientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(c.reason ?? 'Consultation', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        if (c.status == ConsultationStatus.active)
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
            child: const Text('En cours', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.greenDark)))
        else
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
            child: const Text('En attente', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)))),
        Text(_fmtTime(c.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]),
    ]));

  void _startConsult(ConsultationModel c) {
    _db.updateConsultationStatus(c.id, ConsultationStatus.active);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(
      consultationId: c.id, doctorName: c.doctorName, patientName: c.patientName)));
  }

  String _fmtTime(DateTime d) =>
      '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
}
