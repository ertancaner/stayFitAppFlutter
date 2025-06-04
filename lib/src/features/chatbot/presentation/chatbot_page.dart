import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stay_fit/src/features/chatbot/application/chatbot_service.dart';
// import 'package:flutter/foundation.dart'; // debugPrint için eklendi - Material.dart altında zaten var

// Mesaj modelini tanımlayalım
class ChatMessage {
  final String text;
  final bool isUser; // true: kullanıcı, false: bot

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotPage extends ConsumerStatefulWidget {
  const ChatbotPage({super.key});

  @override
  ConsumerState<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends ConsumerState<ChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Başlangıç bot mesajı
    _messages.add(ChatMessage(
        text:
            'Merhaba! Ben StayFit asistanın. Fitness, egzersiz, beslenme ve sağlıklı yaşam konularında sana nasıl yardımcı olabilirim?',
        isUser: false));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Mesaj gönderme fonksiyonu
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Kullanıcı mesajını ekle
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true; // Yükleniyor durumunu başlat
    });
    _textController.clear();
    _scrollToBottom(); // Yeni mesaj eklenince aşağı kaydır

    try {
      // Servisi kullanarak API'ye gönder
      final chatbotService = ref.read(chatbotServiceProvider);
      final response = await chatbotService.sendMessage(text);

      // Bot cevabını ekle
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
      });
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      setState(() {
        _messages.add(ChatMessage(
            text: 'Üzgünüm, bir hata oluştu. Lütfen tekrar deneyin.',
            isUser: false));
      });
      debugPrint("Chatbot Hatası: $e"); // print yerine debugPrint
    } finally {
      // Yükleniyor durumunu bitir
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom(); // Bot cevabı gelince aşağı kaydır
    }
  }

  // Listenin en altına kaydırma fonksiyonu
  void _scrollToBottom() {
    // Küçük bir gecikme ile kaydırma işlemi daha stabil çalışır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          // Özel Başlık Alanı
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16.0, // Status bar + ek boşluk
              bottom: 20.0,
            ),
            alignment: Alignment.center,
            child: Text(
              'StayFit Asistan', // Başlık güncellendi
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                fontSize: (theme.textTheme.headlineMedium?.fontSize ?? 28.0) * 1.1,
              ),
            ),
          ),
          // Mesaj Listesi
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0), // Yükleniyorsa +1 item
              itemBuilder: (context, index) {
                // Yüklenme göstergesi
                if (_isLoading && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: SizedBox(
                        width: 24, // Boyutunu ayarlayabilirsiniz
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final message = _messages[index];
                return _buildMessageBubble(message, theme);
              },
            ),
          ),
          // Kullanıcı Giriş Alanı
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Mesajınızı yazın...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha((255 * 0.5).round()), // withOpacity yerine withAlpha
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Enter ile gönder
                    textInputAction: TextInputAction.send, // Klavye gönder butonu
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.primary),
                  onPressed: _isLoading ? null : _sendMessage, // Yükleniyorsa butonu devre dışı bırak
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Mesaj balonu oluşturan yardımcı fonksiyon
  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer.withAlpha((255 * 0.7).round()); // withOpacity yerine withAlpha
    final textColor = isUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isUser ? 16 : 0),
      bottomRight: Radius.circular(isUser ? 0 : 16),
    );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75), // Max genişlik
        decoration: BoxDecoration(
          color: color,
          borderRadius: borderRadius,
        ),
        child: Text(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
        ),
      ),
    );
  }
}
