import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app;
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/message_model.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ChatScreen extends StatefulWidget {
  final String consultationId;
  final String doctorName;
  final String patientName;

  const ChatScreen({
    super.key,
    required this.consultationId,
    required this.doctorName,
    required this.patientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _db = FirestoreService();
  final _storage = StorageService();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final uid = context.read<app.AuthProvider>().user?.uid ?? '';
    _db.markMessagesRead(widget.consultationId, uid);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    _inputCtrl.clear();
    final user = context.read<app.AuthProvider>().user!;
    await _db.sendMessage(
      consultationId: widget.consultationId,
      senderId: user.uid, senderName: user.name,
      isDoctor: user.isDoctor, content: text,
    );
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final user = context.read<app.AuthProvider>().user!;
    final url = await _storage.uploadConsultationImage(
        consultationId: widget.consultationId, senderId: user.uid);
    if (url == null || !mounted) return;
    await _db.sendMessage(consultationId: widget.consultationId,
        senderId: user.uid, senderName: user.name, isDoctor: user.isDoctor,
        content: 'Image médicale', type: MessageType.image, fileUrl: url);
    _scrollToBottom();
  }

  Future<void> _sendFile() async {
    final user = context.read<app.AuthProvider>().user!;
    final result = await _storage.uploadDocument(consultationId: widget.consultationId);
    if (result == null || !mounted) return;
    await _db.sendMessage(consultationId: widget.consultationId,
        senderId: user.uid, senderName: user.name, isDoctor: user.isDoctor,
        content: result['name']!, type: MessageType.file,
        fileUrl: result['url'], fileName: result['name']);
    _scrollToBottom();
  }

  Future<void> _sendPrescription() async {
    final user = context.read<app.AuthProvider>().user!;
    final items = ['Paracétamol 1000mg — 3×/jour · 5 jours',
        'Amoxicilline 500mg — 2×/jour · 7 jours', 'Repos — 48h minimum'];
    await _db.sendMessage(consultationId: widget.consultationId,
        senderId: user.uid, senderName: user.name, isDoctor: true,
        content: 'Ordonnance médicale', type: MessageType.ordonnance,
        prescriptionItems: items);
    _scrollToBottom();
    if (mounted) showAppToast(context, 'Ordonnance envoyée !', success: true);
  }

  String _time(DateTime t) =>
      '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<app.AuthProvider>().user!;
    final headerName = user.isDoctor ? widget.patientName : widget.doctorName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F4),
      appBar: AppBar(
        backgroundColor: AppColors.greenDark, foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context)),
        title: Row(children: [
          Container(width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(
              headerName.split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0]).join(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(headerName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis),
            Row(children: [
              Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('Consultation en cours', style: TextStyle(fontSize: 11, color: Colors.white70)),
            ]),
          ])),
        ]),
        actions: [
          if (user.isDoctor)
            TextButton.icon(onPressed: _sendPrescription,
              icon: const Icon(Icons.description_outlined, color: Colors.white, size: 16),
              label: const Text('Ordonnance', style: TextStyle(color: Colors.white, fontSize: 11))),
          IconButton(icon: const Icon(Icons.videocam_outlined), onPressed: () => showAppToast(context, 'Vidéo bientôt disponible !')),
        ],
      ),
      body: Column(children: [
        Expanded(child: StreamBuilder<List<MessageModel>>(
          stream: _db.messagesStream(widget.consultationId),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.green));
            }
            final msgs = snap.data ?? [];
            if (msgs.isEmpty) return const Center(child: Text('Démarrez la conversation !', style: TextStyle(color: AppColors.textMuted)));
            WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
            return ListView.builder(controller: _scrollCtrl, padding: const EdgeInsets.all(16),
              itemCount: msgs.length, itemBuilder: (_, i) => _buildMsg(msgs[i], user.uid));
          },
        )),
        _buildBar(),
      ]),
    );
  }

  Widget _buildMsg(MessageModel msg, String myUid) {
    if (msg.type == MessageType.ordonnance) return _buildOrdo(msg);
    final isMe = msg.senderId == myUid;
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Row(mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start, children: [
        ConstrainedBox(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppColors.green : Colors.white,
              borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4, offset: const Offset(0,1))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              if (msg.type == MessageType.image && msg.fileUrl != null)
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(msg.fileUrl!, width: 200, fit: BoxFit.cover))
              else if (msg.type == MessageType.file)
                Row(children: [
                  Icon(Icons.attach_file, size: 16, color: isMe ? Colors.white70 : AppColors.textMuted),
                  const SizedBox(width: 4),
                  Flexible(child: Text(msg.fileName ?? msg.content,
                    style: TextStyle(fontSize: 13, color: isMe ? Colors.white : AppColors.blue,
                        decoration: TextDecoration.underline))),
                ])
              else
                Text(msg.content, style: TextStyle(fontSize: 13, color: isMe ? Colors.white : AppColors.text, height: 1.5)),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_time(msg.sentAt), style: TextStyle(fontSize: 10, color: isMe ? Colors.white60 : AppColors.textLight)),
                if (isMe) ...[const SizedBox(width: 4),
                  Icon(msg.isRead ? Icons.done_all : Icons.done, size: 12, color: msg.isRead ? Colors.white : Colors.white60)],
              ]),
            ]),
          )),
      ]));
  }

  Widget _buildOrdo(MessageModel msg) {
    return Padding(padding: const EdgeInsets.only(bottom: 10),
      child: Align(alignment: Alignment.centerLeft,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.88),
          child: Container(padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.greenMid.withOpacity(0.4)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(6)),
                  child: const Text('ORDONNANCE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.greenDark))),
                Text(_time(msg.sentAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ]),
              const SizedBox(height: 10),
              if (msg.prescriptionItems != null)
                ...msg.prescriptionItems!.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(padding: EdgeInsets.only(top: 5), child: Icon(Icons.circle, size: 6, color: AppColors.green)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                  ]))),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                onPressed: () => showAppToast(context, 'Ordonnance sauvegardée !', success: true),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.greenLight, foregroundColor: AppColors.greenDark,
                    padding: const EdgeInsets.symmetric(vertical: 10), elevation: 0),
                icon: const Icon(Icons.download_outlined, size: 16),
                label: const Text('Télécharger l\'ordonnance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Sora')))),
            ])))));
  }

  Widget _buildBar() {
    return Container(color: Colors.white, padding: const EdgeInsets.fromLTRB(8, 8, 12, 12),
      child: SafeArea(top: false, child: Row(children: [
        IconButton(icon: const Icon(Icons.image_outlined, color: AppColors.textMuted), onPressed: _sendImage),
        IconButton(icon: const Icon(Icons.attach_file_outlined, color: AppColors.textMuted), onPressed: _sendFile),
        Expanded(child: TextField(controller: _inputCtrl, onSubmitted: (_) => _send(),
          decoration: InputDecoration(hintText: 'Votre message...', filled: true, fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: AppColors.green))))),
        const SizedBox(width: 8),
        GestureDetector(onTap: _isSending ? null : _send,
          child: Container(width: 42, height: 42,
            decoration: BoxDecoration(color: _isSending ? AppColors.textLight : AppColors.green, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 18))),
      ])));
  }
}
