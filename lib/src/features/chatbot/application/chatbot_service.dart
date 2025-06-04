import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ref için doğru import
import 'package:flutter/foundation.dart'; // debugPrint için eklendi

part 'chatbot_service.g.dart';

class ChatbotService {
  final GenerativeModel _model;

  ChatbotService()
      : _model = GenerativeModel(
          // Şimdilik 'gemini-pro' modelini kullanıyoruz. İhtiyaç olursa değiştirebiliriz.
          // Farklı modeller için bkz: https://ai.google.dev/models/gemini
          model: 'gemini-1.5-flash-latest', 
          apiKey: dotenv.env['GEMINI_API_KEY']!,
          // Fitness ve spor odaklı olması için başlangıç talimatları ekleyelim
          generationConfig: GenerationConfig(
            temperature: 0.7, // Yaratıcılık seviyesi (0.0 - 1.0)
          ),
          safetySettings: [
             SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
             SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
             SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
             SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
          ],
          // Sisteme rolünü ve odaklanması gereken konuyu belirtelim
          systemInstruction: Content.system(
            'Sen StayFit uygulamasının fitness ve sağlıklı yaşam asistanısın. '
            'Sadece fitness, egzersiz, beslenme, sağlıklı yaşam ve motivasyon konularında '
            'yardımcı olabilirsin. Diğer konulardaki sorulara cevap verme ve '
            'kibarca konuya dönmesini iste.'
          ),
        );

  /// Kullanıcı mesajını Gemini API'ye gönderir ve cevabı alır.
  Future<String> sendMessage(String message) async {
    try {
      // Konuşma geçmişini yönetmek için ChatSession kullanılıyor.
      final chat = _model.startChat();
      final content = Content.text(message);
      final response = await chat.sendMessage(content);
      return response.text ?? 'Üzgünüm, bir sorun oluştu.';
    } catch (e) {
      // Hata yönetimi eklenebilir (örn. loglama)
      debugPrint('Gemini API Hatası: $e'); // print yerine debugPrint
      return 'Üzgünüm, isteğinizi işlerken bir hata oluştu.';
    }
  }
}

// Riverpod provider'ı oluşturuyoruz
@riverpod
ChatbotService chatbotService(Ref ref) {
  return ChatbotService();
}