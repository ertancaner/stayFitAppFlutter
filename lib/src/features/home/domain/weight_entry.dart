import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_entry.freezed.dart';
part 'weight_entry.g.dart';

// Helper function to convert DateTime to int for JSON (and sqflite)
int _dateTimeToInt(DateTime date) => date.millisecondsSinceEpoch;
// Helper function to convert int to DateTime from JSON (and sqflite)
DateTime _intToDateTime(int milliseconds) =>
    DateTime.fromMillisecondsSinceEpoch(milliseconds);

@freezed
class WeightEntry with _$WeightEntry {
  const factory WeightEntry({
    String? id, // Firestore doküman ID'si için String?
    required String userId, // Kullanıcı ID'si eklendi
    required double weight,
    @JsonKey(toJson: _dateTimeToInt, fromJson: _intToDateTime) // Tarih dönüşümü için
    required DateTime date,
  }) = _WeightEntry;

  // JsonKey.new hatası, @JsonKey'nin yanlış yerde kullanılmasından kaynaklanır.
  // Bu satır gereksiz ve hatalı olduğu için kaldırılmalıdır.
  // @JsonKey()

  // Firestore için Map dönüşümleri.
  // `id` alanı Firestore tarafından yönetildiği için toJson'da genellikle gönderilmez,
  // ancak fromJson'da doküman ID'sini almak için kullanılabilir.
  // Freezed, toJson'da null olan alanları varsayılan olarak dahil etmez.
  factory WeightEntry.fromJson(Map<String, dynamic> json) =>
      _$WeightEntryFromJson(json);
}
