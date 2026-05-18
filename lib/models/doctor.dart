enum DoctorStatus { online, busy, offline }

class Doctor {
  final String id;
  final String name;
  final String initials;
  final String speciality;
  final String city;
  final double rating;
  final int reviewCount;
  final String price;
  final DoctorStatus status;
  final Color avatarBg;
  final Color avatarText;

  const Doctor({
    required this.id,
    required this.name,
    required this.initials,
    required this.speciality,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.status,
    required this.avatarBg,
    required this.avatarText,
  });
}

// Using int instead of Color to avoid import issues in model
class Color {
  final int value;
  const Color(this.value);
}

final List<Doctor> sampleDoctors = [
  Doctor(
    id: 'dr-regina',
    name: 'Dr. Régina Hounkpatin',
    initials: 'RH',
    speciality: 'Médecine générale',
    city: 'Cotonou',
    rating: 4.9,
    reviewCount: 128,
    price: '2 500',
    status: DoctorStatus.online,
    avatarBg: Color(0xFFE1F5EE),
    avatarText: Color(0xFF085041),
  ),
  Doctor(
    id: 'dr-moussa',
    name: 'Dr. Moussa Sanni',
    initials: 'MS',
    speciality: 'Pédiatrie',
    city: 'Cotonou',
    rating: 4.7,
    reviewCount: 89,
    price: '2 000',
    status: DoctorStatus.online,
    avatarBg: Color(0xFFE6F1FB),
    avatarText: Color(0xFF042C53),
  ),
  Doctor(
    id: 'dr-kofi',
    name: 'Dr. Kofi Adjovi',
    initials: 'KA',
    speciality: 'Cardiologie',
    city: 'Cotonou',
    rating: 5.0,
    reviewCount: 64,
    price: '3 000',
    status: DoctorStatus.busy,
    avatarBg: Color(0xFFFAEEDA),
    avatarText: Color(0xFF412402),
  ),
  Doctor(
    id: 'dr-fatou',
    name: 'Dr. Fatou Dossou',
    initials: 'FD',
    speciality: 'Gynécologie',
    city: 'Cotonou',
    rating: 4.8,
    reviewCount: 112,
    price: '2 500',
    status: DoctorStatus.online,
    avatarBg: Color(0xFFFBEAF0),
    avatarText: Color(0xFF4B1528),
  ),
];
