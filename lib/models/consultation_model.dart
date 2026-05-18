import 'package:cloud_firestore/cloud_firestore.dart';

enum ConsultationStatus { waiting, active, completed, cancelled }

class ConsultationModel {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final ConsultationStatus status;
  final String? reason;
  final String? diagnosis;
  final List<String> prescription;
  final double amount;
  final String paymentMethod;
  final bool isPaid;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const ConsultationModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.status,
    this.reason,
    this.diagnosis,
    this.prescription = const [],
    required this.amount,
    required this.paymentMethod,
    this.isPaid = false,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  factory ConsultationModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ConsultationModel(
      id: doc.id,
      patientId: d['patientId'] ?? '',
      patientName: d['patientName'] ?? '',
      doctorId: d['doctorId'] ?? '',
      doctorName: d['doctorName'] ?? '',
      status: _parseStatus(d['status']),
      reason: d['reason'],
      diagnosis: d['diagnosis'],
      prescription: List<String>.from(d['prescription'] ?? []),
      amount: (d['amount'] ?? 0).toDouble(),
      paymentMethod: d['paymentMethod'] ?? '',
      isPaid: d['isPaid'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startedAt: (d['startedAt'] as Timestamp?)?.toDate(),
      endedAt: (d['endedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'status': status.name,
      'reason': reason,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }

  static ConsultationStatus _parseStatus(String? s) {
    switch (s) {
      case 'active': return ConsultationStatus.active;
      case 'completed': return ConsultationStatus.completed;
      case 'cancelled': return ConsultationStatus.cancelled;
      default: return ConsultationStatus.waiting;
    }
  }

  ConsultationModel copyWith({
    ConsultationStatus? status,
    String? diagnosis,
    List<String>? prescription,
    bool? isPaid,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return ConsultationModel(
      id: id,
      patientId: patientId,
      patientName: patientName,
      doctorId: doctorId,
      doctorName: doctorName,
      status: status ?? this.status,
      reason: reason,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      amount: amount,
      paymentMethod: paymentMethod,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }
}
