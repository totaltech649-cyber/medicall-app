import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../models/user_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _regNameCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regSpecialityCtrl = TextEditingController();
  final _regOrderCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.patient;
  bool _obscurePass = true;
  bool _obscureRegPass = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [_emailCtrl,_passCtrl,_regNameCtrl,_regEmailCtrl,_regPhoneCtrl,_regPassCtrl,_regSpecialityCtrl,_regOrderCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) { showAppToast(context, 'Remplissez tous les champs'); return; }
    final auth = context.read<app.AuthProvider>();
    final ok = await auth.signIn(email: _emailCtrl.text.trim(), password: _passCtrl.text);
    if (!ok && mounted) showAppToast(context, auth.errorMessage ?? 'Erreur de connexion');
  }

  Future<void> _doRegister() async {
    if (_regNameCtrl.text.trim().isEmpty || _regEmailCtrl.text.trim().isEmpty || _regPhoneCtrl.text.trim().isEmpty || _regPassCtrl.text.isEmpty) {
      showAppToast(context, 'Remplissez tous les champs obligatoires'); return;
    }
    if (_regPassCtrl.text.length < 6) { showAppToast(context, 'Mot de passe : 6 caractères minimum'); return; }
    final auth = context.read<app.AuthProvider>();
    final ok = await auth.register(
      name: _regNameCtrl.text.trim(), email: _regEmailCtrl.text.trim(),
      password: _regPassCtrl.text, phone: _regPhoneCtrl.text.trim(), role: _selectedRole,
      speciality: _selectedRole == UserRole.doctor ? _regSpecialityCtrl.text.trim() : null,
      orderNumber: _selectedRole == UserRole.doctor ? _regOrderCtrl.text.trim() : null,
    );
    if (!ok && mounted) showAppToast(context, auth.errorMessage ?? "Erreur d'inscription");
  }

  Future<void> _resetPassword() async {
    if (_emailCtrl.text.trim().isEmpty) { showAppToast(context, 'Entrez votre email d\'abord'); return; }
    final ok = await context.read<app.AuthProvider>().sendPasswordReset(_emailCtrl.text.trim());
    if (mounted) showAppToast(context, ok ? 'Email envoyé !' : 'Erreur. Vérifiez l\'email.', success: ok);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<app.AuthProvider>().isLoading;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 32),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 52, height: 52,
              decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 28)),
            const SizedBox(width: 12),
            RichText(text: const TextSpan(
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, fontFamily: 'Sora', color: AppColors.text),
              children: [TextSpan(text: 'Médi'), TextSpan(text: 'Call', style: TextStyle(color: AppColors.green))])),
          ]),
          const SizedBox(height: 8),
          const Text('Téléconsultation médicale au Bénin', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(10)),
            child: TabBar(controller: _tabController,
              indicator: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(8)),
              indicatorSize: TabBarIndicatorSize.tab, dividerColor: Colors.transparent,
              labelColor: Colors.white, unselectedLabelColor: AppColors.greenDark,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: 'Sora'),
              tabs: const [Tab(text: 'Se connecter'), Tab(text: 'Créer un compte')]),
          ),
          const SizedBox(height: 24),
          SizedBox(height: 480, child: TabBarView(controller: _tabController, children: [
            _loginForm(isLoading), _registerForm(isLoading),
          ])),
        ]),
      )),
    );
  }

  Widget _loginForm(bool isLoading) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    _label('Email'), const SizedBox(height: 6),
    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'votre@email.com', prefixIcon: Icon(Icons.email_outlined, color: AppColors.textMuted, size: 20))),
    const SizedBox(height: 14),
    _label('Mot de passe'), const SizedBox(height: 6),
    TextField(controller: _passCtrl, obscureText: _obscurePass,
      decoration: InputDecoration(hintText: '••••••••',
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 20),
        suffixIcon: IconButton(icon: Icon(_obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
          onPressed: () => setState(() => _obscurePass = !_obscurePass)))),
    Align(alignment: Alignment.centerRight, child: TextButton(onPressed: _resetPassword,
      child: const Text('Mot de passe oublié ?', style: TextStyle(color: AppColors.green, fontSize: 13)))),
    SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
      onPressed: isLoading ? null : _doLogin,
      child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                       : const Text('Se connecter'))),
  ]);

  Widget _registerForm(bool isLoading) => SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [_roleBtn(UserRole.patient, '🏥 Patient'), const SizedBox(width: 10), _roleBtn(UserRole.doctor, '👨‍⚕️ Médecin')]),
    const SizedBox(height: 12),
    _label('Nom complet *'), const SizedBox(height: 6),
    TextField(controller: _regNameCtrl, decoration: const InputDecoration(hintText: 'Ex: Ama Kossou')),
    const SizedBox(height: 12),
    _label('Email *'), const SizedBox(height: 6),
    TextField(controller: _regEmailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'votre@email.com')),
    const SizedBox(height: 12),
    _label('Téléphone *'), const SizedBox(height: 6),
    TextField(controller: _regPhoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: '+229 XX XX XX XX')),
    const SizedBox(height: 12),
    _label('Mot de passe *'), const SizedBox(height: 6),
    TextField(controller: _regPassCtrl, obscureText: _obscureRegPass,
      decoration: InputDecoration(hintText: 'Minimum 6 caractères',
        suffixIcon: IconButton(icon: Icon(_obscureRegPass ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textMuted, size: 20),
          onPressed: () => setState(() => _obscureRegPass = !_obscureRegPass)))),
    if (_selectedRole == UserRole.doctor) ...[
      const SizedBox(height: 12),
      _label('Spécialité'), const SizedBox(height: 6),
      TextField(controller: _regSpecialityCtrl, decoration: const InputDecoration(hintText: 'Ex: Médecine générale')),
      const SizedBox(height: 12),
      _label('Numéro CNOM Bénin'), const SizedBox(height: 6),
      TextField(controller: _regOrderCtrl, decoration: const InputDecoration(hintText: "Numéro d'ordre")),
    ],
    const SizedBox(height: 20),
    SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
      onPressed: isLoading ? null : _doRegister,
      child: isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                       : const Text('Créer mon compte'))),
    const SizedBox(height: 20),
  ]));

  Widget _label(String t) => Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.text));

  Widget _roleBtn(UserRole role, String label) {
    final sel = _selectedRole == role;
    return Expanded(child: GestureDetector(onTap: () => setState(() => _selectedRole = role),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: sel ? AppColors.greenLight : AppColors.surface, borderRadius: BorderRadius.circular(10),
          border: Border.all(color: sel ? AppColors.greenMid : AppColors.border, width: sel ? 2 : 1)),
        child: Text(label, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sel ? AppColors.greenDark : AppColors.textMuted)))));
  }
}
