import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid();

  // ── Photo de profil ────────────────────────────────────────────────────────

  /// Choisir et uploader une photo de profil
  Future<String?> uploadProfilePhoto(String userId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null) return null;

    final ref = _storage.ref().child('profiles/$userId/avatar.jpg');
    final uploadTask = await ref.putFile(
      File(image.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  /// Prendre une photo avec la caméra
  Future<String?> uploadProfilePhotoFromCamera(String userId) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null) return null;

    final ref = _storage.ref().child('profiles/$userId/avatar.jpg');
    final uploadTask = await ref.putFile(
      File(image.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await uploadTask.ref.getDownloadURL();
  }

  // ── Documents de consultation ──────────────────────────────────────────────

  /// Uploader une image médicale pendant une consultation
  Future<String?> uploadConsultationImage({
    required String consultationId,
    required String senderId,
  }) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image == null) return null;

    final fileName = '${_uuid.v4()}.jpg';
    final ref = _storage
        .ref()
        .child('consultations/$consultationId/images/$fileName');

    final task = await ref.putFile(
      File(image.path),
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  /// Uploader un fichier PDF (ordonnance, résultat d'analyse)
  Future<Map<String, String>?> uploadDocument({
  required String consultationId,
}) async {
  return null;
}

  /// Uploader une ordonnance générée
  Future<String> uploadPrescriptionPdf({
    required String consultationId,
    required List<int> pdfBytes,
  }) async {
    final fileName = 'ordonnance_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final ref = _storage
        .ref()
        .child('consultations/$consultationId/prescriptions/$fileName');

    final task = await ref.putData(
      Uint8List.fromList(pdfBytes),
      SettableMetadata(contentType: 'application/pdf'),
    );
    return await task.ref.getDownloadURL();
  }

  // ── Upload avec progression ────────────────────────────────────────────────

  /// Upload avec callback de progression (pour gros fichiers)
  Future<String?> uploadWithProgress({
    required String path,
    required File file,
    required String contentType,
    required void Function(double progress) onProgress,
  }) async {
    final ref = _storage.ref().child(path);
    final task = ref.putFile(file, SettableMetadata(contentType: contentType));

    task.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      onProgress(progress);
    });

    final snapshot = await task;
    return await snapshot.ref.getDownloadURL();
  }

  // ── Supprimer ──────────────────────────────────────────────────────────────

  Future<void> deleteFile(String downloadUrl) async {
    try {
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (_) {
      // Le fichier n'existe peut-être plus, on ignore
    }
  }
}
