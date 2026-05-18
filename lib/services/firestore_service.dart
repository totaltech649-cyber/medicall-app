import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/consultation_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════
  // UTILISATEURS
  // ═══════════════════════════════════════════════════════════

  /// Met à jour le profil utilisateur
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Toggle disponibilité médecin
  Future<void> setDoctorAvailability(String uid, bool isAvailable) async {
    await _db.collection('users').doc(uid).update({'isAvailable': isAvailable});
  }

  /// Liste des médecins disponibles (temps réel)
  Stream<List<UserModel>> availableDoctorsStream({String? speciality}) {
    Query query = _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('isAvailable', isEqualTo: true)
        .orderBy('rating', descending: true);

    if (speciality != null && speciality != 'Tous') {
      query = query.where('speciality', isEqualTo: speciality);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map(UserModel.fromFirestore).toList(),
    );
  }

  /// Tous les médecins (temps réel)
  Stream<List<UserModel>> allDoctorsStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(UserModel.fromFirestore).toList());
  }

  // ═══════════════════════════════════════════════════════════
  // CONSULTATIONS
  // ═══════════════════════════════════════════════════════════

  /// Créer une nouvelle consultation
  Future<ConsultationModel> createConsultation({
    required String patientId,
    required String patientName,
    required String doctorId,
    required String doctorName,
    required String reason,
    required double amount,
    required String paymentMethod,
  }) async {
    final ref = _db.collection('consultations').doc();
    final consult = ConsultationModel(
      id: ref.id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      status: ConsultationStatus.waiting,
      reason: reason,
      amount: amount,
      paymentMethod: paymentMethod,
      isPaid: true,
      createdAt: DateTime.now(),
    );
    await ref.set(consult.toFirestore());
    return consult;
  }

  /// Mettre à jour le statut d'une consultation
  Future<void> updateConsultationStatus(
    String consultId,
    ConsultationStatus status, {
    String? diagnosis,
    List<String>? prescription,
  }) async {
    final data = <String, dynamic>{'status': status.name};
    if (status == ConsultationStatus.active) {
      data['startedAt'] = Timestamp.fromDate(DateTime.now());
    }
    if (status == ConsultationStatus.completed) {
      data['endedAt'] = Timestamp.fromDate(DateTime.now());
    }
    if (diagnosis != null) data['diagnosis'] = diagnosis;
    if (prescription != null) data['prescription'] = prescription;
    await _db.collection('consultations').doc(consultId).update(data);
  }

  /// Historique consultations patient (temps réel)
  Stream<List<ConsultationModel>> patientConsultationsStream(String patientId) {
    return _db
        .collection('consultations')
        .where('patientId', isEqualTo: patientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ConsultationModel.fromFirestore).toList());
  }

  /// File d'attente médecin (temps réel)
  Stream<List<ConsultationModel>> doctorQueueStream(String doctorId) {
    return _db
        .collection('consultations')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', whereIn: ['waiting', 'active'])
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(ConsultationModel.fromFirestore).toList());
  }

  /// Historique consultations médecin
  Stream<List<ConsultationModel>> doctorHistoryStream(String doctorId) {
    return _db
        .collection('consultations')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ConsultationModel.fromFirestore).toList());
  }

  // ═══════════════════════════════════════════════════════════
  // MESSAGES (CHAT)
  // ═══════════════════════════════════════════════════════════

  /// Envoyer un message texte
  Future<void> sendMessage({
    required String consultationId,
    required String senderId,
    required String senderName,
    required bool isDoctor,
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    List<String>? prescriptionItems,
  }) async {
    final msg = MessageModel(
      id: '',
      senderId: senderId,
      senderName: senderName,
      isDoctor: isDoctor,
      content: content,
      type: type,
      fileUrl: fileUrl,
      fileName: fileName,
      prescriptionItems: prescriptionItems,
      sentAt: DateTime.now(),
    );

    await _db
        .collection('consultations')
        .doc(consultationId)
        .collection('messages')
        .add(msg.toFirestore());

    // Mettre à jour le dernier message sur la consultation
    await _db.collection('consultations').doc(consultationId).update({
      'lastMessage': content,
      'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      'lastMessageSender': senderId,
    });
  }

  /// Stream de messages d'une consultation (temps réel)
  Stream<List<MessageModel>> messagesStream(String consultationId) {
    return _db
        .collection('consultations')
        .doc(consultationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snap) => snap.docs.map(MessageModel.fromFirestore).toList());
  }

  /// Marquer les messages comme lus
  Future<void> markMessagesRead(String consultationId, String userId) async {
    final batch = _db.batch();
    final unread = await _db
        .collection('consultations')
        .doc(consultationId)
        .collection('messages')
        .where('senderId', isNotEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ═══════════════════════════════════════════════════════════
  // STATISTIQUES MÉDECIN
  // ═══════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getDoctorStats(String doctorId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final monthly = await _db
        .collection('consultations')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'completed')
        .where('createdAt', isGreaterThan: Timestamp.fromDate(startOfMonth))
        .get();

    double totalEarnings = 0;
    for (final doc in monthly.docs) {
      final data = doc.data();
      totalEarnings += (data['amount'] ?? 0).toDouble();
    }

    return {
      'monthlyConsultations': monthly.docs.length,
      'monthlyEarnings': totalEarnings,
    };
  }
}
