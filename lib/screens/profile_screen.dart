import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDoctor;
  const ProfileScreen({super.key, required this.isDoctor});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _db = FirestoreService();
  final _storage = StorageService();
  bool _uploadingPhoto = false;

  Future<void> _changePhoto() async {
    final user = context.read<app.AuthProvider>().user!;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await _storage.uploadProfilePhoto(user.uid);
      if (url != null) {
        await _db.updateUser(user.uid, {'photoUrl': url});
        if (mounted) showAppToast(context, 'Photo mise à jour !', success: true);
      }
    } catch (e) {
      if (mounted) showAppToast(context, 'Erreur lors de l\'upload');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<app.AuthProvider>().user!;
    final initials = user.name.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join().toUpperCase();

    return ListView(padding: EdgeInsets.zero, children: [
      // Header
      Container(padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        decoration: const BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          Stack(children: [
            GestureDetector(onTap: _changePhoto,
              child: Container(width: 64, height: 64,
                decoration: BoxDecoration(
                  color: widget.isDoctor ? const Color(0xFFE6F1FB) : AppColors.greenLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.greenMid.withOpacity(0.4), width: 2)),
                child: user.photoUrl != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(16),
                        child: Image.network(user.photoUrl!, fit: BoxFit.cover, width: 64, height: 64))
                    : Center(child: Text(initials, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                        color: widget.isDoctor ? const Color(0xFF042C53) : AppColors.greenDark))))),
            if (_uploadingPhoto)
              Positioned.fill(child: Container(decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(18)),
                child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))))
            else
              Positioned(bottom: 0, right: 0,
                child: Container(width: 22, height: 22, decoration: BoxDecoration(color: AppColors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 12))),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(widget.isDoctor ? '${user.speciality ?? 'Médecin'} · Cotonou' : 'Patient · Cotonou',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
          ])),
        ])),

      Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _section('Mon compte'),
        _item(Icons.person_outline_rounded, 'Informations personnelles', onTap: () => _editProfile(context, user)),
        _item(Icons.description_outlined, 'Mes ordonnances', onTap: () => showAppToast(context, 'Bientôt disponible')),
        _item(Icons.credit_card_outlined, 'Moyens de paiement', onTap: () => showAppToast(context, 'Bientôt disponible')),
        _item(Icons.history_rounded, 'Historique consultations', onTap: () => showAppToast(context, 'Bientôt disponible')),
        if (widget.isDoctor) ...[
          _item(Icons.bar_chart_rounded, 'Mes statistiques', onTap: () => showAppToast(context, 'Bientôt disponible')),
          _item(Icons.account_balance_wallet_outlined, 'Mes revenus', onTap: () => showAppToast(context, 'Bientôt disponible')),
        ],
        _section('Application'),
        _item(Icons.settings_outlined, 'Paramètres', onTap: () => showAppToast(context, 'Bientôt disponible')),
        _item(Icons.language_outlined, 'Langue : Français / Fon', onTap: () => showAppToast(context, 'Fon — bientôt disponible !')),
        _item(Icons.help_outline_rounded, 'Aide & Support', onTap: () => showAppToast(context, 'Bientôt disponible')),
        _item(Icons.info_outline_rounded, 'À propos de MédiCall', onTap: () => _about(context)),
        const SizedBox(height: 8),
        _item(Icons.logout_rounded, 'Se déconnecter',
          textColor: AppColors.red, iconBg: const Color(0xFFFEE2E2), iconColor: AppColors.red,
          onTap: () => _logout(context)),
        const SizedBox(height: 32),
        const Center(child: Text('MédiCall v1.0.0 · Bénin 🇧🇯', style: TextStyle(fontSize: 12, color: AppColors.textLight))),
        const SizedBox(height: 20),
      ])),
    ]);
  }

  Widget _section(String t) => Padding(padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
    child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)));

  Widget _item(IconData icon, String label, {VoidCallback? onTap, Color? textColor, Color? iconBg, Color? iconColor}) =>
    GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: iconBg ?? AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor ?? AppColors.green, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor ?? AppColors.text))),
        Icon(Icons.chevron_right_rounded, color: textColor ?? AppColors.textLight, size: 20),
      ])));

  void _editProfile(BuildContext ctx, user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    showModalBottomSheet(context: ctx, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Modifier le profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const Text('Nom complet', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: nameCtrl),
          const SizedBox(height: 12),
          const Text('Téléphone', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          TextField(controller: phoneCtrl, keyboardType: TextInputType.phone),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
            onPressed: () async {
              await _db.updateUser(user.uid, {'name': nameCtrl.text.trim(), 'phone': phoneCtrl.text.trim()});
              if (mounted) { Navigator.pop(ctx); showAppToast(context, 'Profil mis à jour !', success: true); }
            },
            child: const Text('Enregistrer'))),
        ])));
  }

  void _about(BuildContext ctx) => showDialog(context: ctx, builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: const Text('MédiCall', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
    content: const Text('Application de téléconsultation médicale développée pour le Bénin.\n\nVersion 1.0.0 · Firebase\n© 2026 MédiCall',
      style: TextStyle(fontFamily: 'Sora', fontSize: 13, height: 1.6)),
    actions: [TextButton(onPressed: () => Navigator.pop(ctx),
      child: const Text('Fermer', style: TextStyle(color: AppColors.green, fontFamily: 'Sora')))],
  ));

  void _logout(BuildContext ctx) => showDialog(context: ctx, builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: const Text('Déconnexion', style: TextStyle(fontFamily: 'Sora', fontWeight: FontWeight.w700)),
    content: const Text('Voulez-vous vraiment vous déconnecter ?', style: TextStyle(fontFamily: 'Sora', fontSize: 14)),
    actions: [
      TextButton(onPressed: () => Navigator.pop(ctx),
        child: const Text('Annuler', style: TextStyle(color: AppColors.textMuted, fontFamily: 'Sora'))),
      TextButton(onPressed: () { Navigator.pop(ctx); context.read<app.AuthProvider>().signOut(); },
        child: const Text('Déconnecter', style: TextStyle(color: AppColors.red, fontFamily: 'Sora'))),
    ],
  ));
}
