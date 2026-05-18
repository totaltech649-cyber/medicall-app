import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/consultation_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/doctor_card.dart';
import 'payment_screen.dart';
import 'profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  final String userName;
  const PatientHomeScreen({super.key, required this.userName});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _tab = 0;
  String _filter = 'Tous';
  final _filters = ['Tous', 'Généraliste', 'Pédiatrie', 'Cardiologie', 'Gynécologie'];
  final _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<app.AuthProvider>().user!;
    final screens = [_homeTab(user), _consultTab(user), _historyTab(user), ProfileScreen(isDoctor: false)];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: MediCallAppBar(actions: [
        Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: AppColors.textMuted),
            onPressed: () => showAppToast(context, 'Notifications bientôt disponibles')),
          Positioned(top: 10, right: 10,
            child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle))),
        ]),
        GestureDetector(onTap: () => setState(() => _tab = 3),
          child: Container(width: 36, height: 36, margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(color: AppColors.greenLight, shape: BoxShape.circle),
            child: Center(child: Text(user.name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase(),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.greenDark))))),
      ]),
      body: screens[_tab],
      bottomNavigationBar: _nav(),
    );
  }

  Widget _nav() {
    final items = [
      [Icons.home_outlined, Icons.home_rounded, 'Accueil'],
      [Icons.video_call_outlined, Icons.video_call_rounded, 'Consulter'],
      [Icons.history_outlined, Icons.history_rounded, 'Historique'],
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
              Text(items[i][2] as String,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: active ? AppColors.green : AppColors.textLight)),
            ])));
        })))),
    );
  }

  Widget _homeTab(UserModel user) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      // Hero
      Container(padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.green, AppColors.greenDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Bonjour 👋', style: TextStyle(fontSize: 13, color: Colors.white70)),
          const SizedBox(height: 4),
          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.greenDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
            onPressed: () => setState(() => _tab = 1),
            icon: const Icon(Icons.video_call_outlined, size: 18),
            label: const Text('Consulter un médecin', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
        ])),
      const SizedBox(height: 20),

      // Stats
      StreamBuilder<List<ConsultationModel>>(
        stream: _db.patientConsultationsStream(user.uid),
        builder: (ctx, snap) {
          final list = snap.data ?? [];
          final done = list.where((c) => c.status == ConsultationStatus.completed).length;
          return Row(children: [
            _stat(done.toString(), 'Consultations\neffectuées', AppColors.green),
            const SizedBox(width: 10),
            _stat('2', 'Ordonnances\nactives', AppColors.blue),
            const SizedBox(width: 10),
            _stat(user.rating > 0 ? user.rating.toStringAsFixed(1) : '—', 'Note\nmoyenne', AppColors.amber),
          ]);
        }),
      const SizedBox(height: 24),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Médecins disponibles', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        TextButton(onPressed: () => setState(() => _tab = 1),
          child: const Text('Voir tout', style: TextStyle(fontSize: 12, color: AppColors.green))),
      ]),
      const SizedBox(height: 12),

      // Filtres
      SizedBox(height: 36, child: ListView.separated(scrollDirection: Axis.horizontal,
        itemCount: _filters.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = _filters[i] == _filter;
          return GestureDetector(onTap: () => setState(() => _filter = _filters[i]),
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: active ? AppColors.greenLight : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.greenMid : AppColors.border)),
              child: Text(_filters[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,
                color: active ? AppColors.greenDark : AppColors.textMuted))));
        })),
      const SizedBox(height: 14),

      // Doctors stream
      StreamBuilder<List<UserModel>>(
        stream: _db.availableDoctorsStream(speciality: _filter == 'Tous' ? null : _filter),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.green)));
          }
          final docs = snap.data ?? [];
          if (docs.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.all(32),
              child: Text('Aucun médecin disponible pour cette spécialité.', style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center)));
          }
          return Column(children: docs.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: DoctorCard(doctor: d, onConsult: () => _pay(d)),
          )).toList());
        }),
      const SizedBox(height: 20),
    ]);
  }

  Widget _consultTab(UserModel user) {
    return StreamBuilder<List<UserModel>>(
      stream: _db.availableDoctorsStream(),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.green));
        }
        final docs = snap.data ?? [];
        return ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Médecins disponibles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text('${docs.length} médecin(s) en ligne maintenant', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ...docs.map((d) => Padding(padding: const EdgeInsets.only(bottom: 10), child: DoctorCard(doctor: d, onConsult: () => _pay(d)))),
          if (docs.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(32),
            child: Text('Aucun médecin disponible pour l\'instant.\nRevenez dans quelques minutes.', style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center))),
        ]);
      });
  }

  Widget _historyTab(UserModel user) {
    return StreamBuilder<List<ConsultationModel>>(
      stream: _db.patientConsultationsStream(user.uid),
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.green));
        }
        final list = snap.data ?? [];
        if (list.isEmpty) {
          return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.history_rounded, size: 64, color: AppColors.textLight),
            SizedBox(height: 12),
            Text('Aucune consultation pour l\'instant', style: TextStyle(color: AppColors.textMuted)),
          ]));
        }
        return ListView(padding: const EdgeInsets.all(20), children: [
          const Text('Historique', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...list.map((c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: _historyCard(c))),
        ]);
      });
  }

  Widget _historyCard(ConsultationModel c) {
    return AppCard(child: Row(children: [
      Container(width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.medical_services_outlined, color: AppColors.green, size: 20)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(c.doctorName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(c.reason ?? 'Consultation', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(_fmtDate(c.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${c.amount.toInt()} FCFA', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.green)),
        const SizedBox(height: 4),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: _statusColor(c.status).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Text(_statusLabel(c.status), style: TextStyle(fontSize: 10, color: _statusColor(c.status), fontWeight: FontWeight.w600))),
      ]),
    ]));
  }

  Widget _stat(String val, String label, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
    child: Column(children: [
      Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
    ])));

  void _pay(UserModel doctor) => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(doctor: doctor)));

  String _fmtDate(DateTime d) => '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  String _statusLabel(ConsultationStatus s) {
    switch (s) {
      case ConsultationStatus.completed: return 'Terminée';
      case ConsultationStatus.active: return 'En cours';
      case ConsultationStatus.cancelled: return 'Annulée';
      default: return 'En attente';
    }
  }
  Color _statusColor(ConsultationStatus s) {
    switch (s) {
      case ConsultationStatus.completed: return AppColors.green;
      case ConsultationStatus.active: return AppColors.blue;
      case ConsultationStatus.cancelled: return AppColors.red;
      default: return AppColors.amber;
    }
  }
}
