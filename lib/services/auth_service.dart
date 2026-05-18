import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'fcm_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Stream de l'état de connexion ──────────────────────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  // ── Inscription ────────────────────────────────────────────────────────────
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? speciality,
    String? orderNumber,
  }) async {
    // 1. Créer le compte Firebase Auth
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user!.updateDisplayName(name);

    // 2. Récupérer le token FCM
    final fcmToken = await FcmService.getToken();

    // 3. Enregistrer le profil dans Firestore
    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      phone: phone,
      email: email.trim(),
      role: role,
      speciality: role == UserRole.doctor ? speciality : null,
      orderNumber: role == UserRole.doctor ? orderNumber : null,
      fcmToken: fcmToken,
      createdAt: DateTime.now(),
    );

    await _db
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toFirestore());

    return user;
  }

  // ── Connexion email/password ───────────────────────────────────────────────
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Mettre à jour le token FCM à chaque connexion
    final fcmToken = await FcmService.getToken();
    if (fcmToken != null) {
      await _db
          .collection('users')
          .doc(credential.user!.uid)
          .update({'fcmToken': fcmToken});
    }

    return await getUser(credential.user!.uid);
  }

  // ── Déconnexion ────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    // Supprimer le token FCM à la déconnexion
    if (currentUid != null) {
      await _db
          .collection('users')
          .doc(currentUid)
          .update({'fcmToken': null});
    }
    await _auth.signOut();
  }

  // ── Réinitialisation du mot de passe ──────────────────────────────────────
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ── Récupérer un profil utilisateur ───────────────────────────────────────
  Future<UserModel> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('Utilisateur introuvable');
    return UserModel.fromFirestore(doc);
  }

  // ── Stream profil utilisateur (temps réel) ────────────────────────────────
  Stream<UserModel?> userStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }
}
