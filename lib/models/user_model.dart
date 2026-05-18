import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { patient, doctor }

class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final String? speciality;       // médecin seulement
  final String? orderNumber;      // numéro CNOM médecin
  final bool isAvailable;         // médecin : toggle disponibilité
  final double rating;
  final int reviewCount;
  final String? fcmToken;         // token notifications push
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.photoUrl,
    this.speciality,
    this.orderNumber,
    this.isAvailable = true,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.fcmToken,
    required this.createdAt,
  });

  bool get isDoctor => role == UserRole.doctor;
  bool get isPatient => role == UserRole.patient;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] == 'doctor' ? UserRole.doctor : UserRole.patient,
      photoUrl: data['photoUrl'],
      speciality: data['speciality'],
      orderNumber: data['orderNumber'],
      isAvailable: data['isAvailable'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role == UserRole.doctor ? 'doctor' : 'patient',
      'photoUrl': photoUrl,
      'speciality': speciality,
      'orderNumber': orderNumber,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    String? speciality,
    String? orderNumber,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role,
      photoUrl: photoUrl ?? this.photoUrl,
      speciality: speciality ?? this.speciality,
      orderNumber: orderNumber ?? this.orderNumber,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
