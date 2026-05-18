import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, ordonnance, image, file }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final bool isDoctor;
  final String content;
  final MessageType type;
  final String? fileUrl;
  final String? fileName;
  final List<String>? prescriptionItems;
  final DateTime sentAt;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.isDoctor,
    required this.content,
    this.type = MessageType.text,
    this.fileUrl,
    this.fileName,
    this.prescriptionItems,
    required this.sentAt,
    this.isRead = false,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      isDoctor: d['isDoctor'] ?? false,
      content: d['content'] ?? '',
      type: _parseType(d['type']),
      fileUrl: d['fileUrl'],
      fileName: d['fileName'],
      prescriptionItems: d['prescriptionItems'] != null
          ? List<String>.from(d['prescriptionItems'])
          : null,
      sentAt: (d['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: d['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'isDoctor': isDoctor,
      'content': content,
      'type': type.name,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'prescriptionItems': prescriptionItems,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
    };
  }

  static MessageType _parseType(String? t) {
    switch (t) {
      case 'ordonnance': return MessageType.ordonnance;
      case 'image': return MessageType.image;
      case 'file': return MessageType.file;
      default: return MessageType.text;
    }
  }
}
