import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.loading;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
      } else {
        try {
          _user = await _authService.getUser(firebaseUser.uid);
          _status = AuthStatus.authenticated;
          // Écouter les mises à jour du profil en temps réel
          _authService.userStream(firebaseUser.uid).listen((updatedUser) {
            if (updatedUser != null) {
              _user = updatedUser;
              notifyListeners();
            }
          });
        } catch (e) {
          _status = AuthStatus.error;
          _errorMessage = e.toString();
        }
      }
      notifyListeners();
    });
  }

  // ── Inscription ────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String? speciality,
    String? orderNumber,
  }) async {
    try {
      _setLoading();
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
        speciality: speciality,
        orderNumber: orderNumber,
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _translateFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Connexion ──────────────────────────────────────────────────────────────
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = _translateFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Déconnexion ────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Réinitialisation mot de passe ─────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Mise à jour locale du profil ──────────────────────────────────────────
  void updateLocalUser(UserModel updated) {
    _user = updated;
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _translateFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'invalid-email':
        return 'Email invalide.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Pas de connexion internet.';
      default:
        return 'Erreur : $code';
    }
  }
}
