import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'chat_screen.dart';

class PaymentScreen extends StatefulWidget {
  final UserModel doctor;
  const PaymentScreen({super.key, required this.doctor});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'mtn';
  final _phoneCtrl = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_phoneCtrl.text.trim().isEmpty) {
      showAppToast(context, 'Entrez votre numéro de paiement');
      return;
    }
    setState(() => _isProcessing = true);

    final user = context.read<app.AuthProvider>().user!;
    final db = FirestoreService();

    try {
      final consult = await db.createConsultation(
        patientId: user.uid,
        patientName: user.name,
        doctorId: widget.doctor.uid,
        doctorName: widget.doctor.name,
        reason: 'Consultation médicale',
        amount: 2500,
        paymentMethod: _method,
      );

      if (!mounted) return;
      showAppToast(context, 'Paiement confirmé !', success: true);

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ChatScreen(
          consultationId: consult.id,
          doctorName: widget.doctor.name,
          patientName: user.name,
        ),
      ));
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        showAppToast(context, 'Erreur : ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.doctor.speciality == 'Cardiologie' ? '3 000' : '2 500';

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: MediCallAppBar(title: 'Paiement'),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Info médecin
        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Consultation avec', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(widget.doctor.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.green)),
          Text(widget.doctor.speciality ?? 'Médecin', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const Divider(height: 20, color: AppColors.border),
          const Text('Mode de paiement', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _payOption('mtn', '📱', 'MTN Mobile Money', 'Paiement via MTN MoMo', const Color(0xFFFAEEDA)),
          const SizedBox(height: 8),
          _payOption('moov', '📱', 'Moov Money', 'Paiement via Moov Flooz', const Color(0xFFE6F1FB)),
          const SizedBox(height: 8),
          _payOption('card', '💳', 'Carte bancaire', 'Visa, Mastercard', AppColors.greenLight),
        ])),
        const SizedBox(height: 14),

        AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_method == 'card' ? 'Numéro de carte' : 'Numéro Mobile Money',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(controller: _phoneCtrl,
            keyboardType: _method == 'card' ? TextInputType.number : TextInputType.phone,
            decoration: InputDecoration(hintText: _method == 'card' ? 'XXXX XXXX XXXX XXXX' : '+229 XX XX XX XX')),
        ])),
        const SizedBox(height: 14),

        AppCard(child: Column(children: [
          _row('Consultation', '$price FCFA', false),
          const SizedBox(height: 8),
          _row('Frais de service', 'Gratuit', true),
          const Divider(height: 20, color: AppColors.border),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            Text('$price FCFA', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.green)),
          ]),
        ])),
        const SizedBox(height: 20),

        SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
          onPressed: _isProcessing ? null : _confirm,
          child: _isProcessing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Confirmer et payer'),
        )),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, child: OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textMuted, side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(vertical: 14)),
          child: const Text('Annuler', style: TextStyle(fontFamily: 'Sora')),
        )),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _payOption(String id, String emoji, String label, String desc, Color bg) {
    final sel = _method == id;
    return GestureDetector(
      onTap: () => setState(() => _method = id),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: sel ? AppColors.green : AppColors.border, width: sel ? 2 : 1),
          borderRadius: BorderRadius.circular(10), color: sel ? AppColors.greenLight : AppColors.surface),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Container(width: 20, height: 20,
            decoration: BoxDecoration(shape: BoxShape.circle,
              border: Border.all(color: sel ? AppColors.green : AppColors.border, width: 2),
              color: sel ? AppColors.green : Colors.transparent),
            child: sel ? const Icon(Icons.check, color: Colors.white, size: 12) : null),
        ])),
    );
  }

  Widget _row(String label, String value, bool green) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: green ? AppColors.green : AppColors.text)),
    ],
  );
}
