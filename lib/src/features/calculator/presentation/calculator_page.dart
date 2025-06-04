import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Eklendi
import 'package:stay_fit/src/features/calculator/application/calculator_providers.dart';
import 'package:stay_fit/src/features/calculator/application/calculator_service.dart';

class CalculatorPage extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget olarak değiştir
  const CalculatorPage({super.key});

  @override
  ConsumerState<CalculatorPage> createState() => _CalculatorPageState(); // State oluştur
}

class _CalculatorPageState extends ConsumerState<CalculatorPage> {
  // State sınıfı
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  SharedPreferences? _prefs; // Eklendi

  static const String _heightKey = 'calculator_height'; // Eklendi
  static const String _ageKey = 'calculator_age'; // Eklendi

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController();
    _ageController = TextEditingController();
    _loadPreferences(); // Değiştirildi

    // Listener'ları controller'lara ekleyerek değişiklikleri kaydet
    _heightController.addListener(_saveHeightPreference);
    _ageController.addListener(_saveAgePreference);
  }

  Future<void> _loadPreferences() async {
    // Eklendi
    _prefs = await SharedPreferences.getInstance();
    final notifier = ref.read(calculatorNotifierProvider.notifier);

    final double? savedHeight = _prefs?.getDouble(_heightKey);
    if (savedHeight != null) {
      _heightController.text = savedHeight.toStringAsFixed(1);
      notifier.updateHeight(savedHeight);
    } else {
      // Eğer kayıtlı değer yoksa, Riverpod state'inden ilk değeri al (varsa)
      final initialHeight =
          ref.read(calculatorNotifierProvider).asData?.value.heightCm;
      if (initialHeight != null) {
        _heightController.text = initialHeight.toStringAsFixed(1);
      }
    }

    final int? savedAge = _prefs?.getInt(_ageKey);
    if (savedAge != null) {
      _ageController.text = savedAge.toString();
      notifier.updateAge(savedAge);
    } else {
      final initialAge = ref.read(calculatorNotifierProvider).asData?.value.age;
      if (initialAge != null) {
        _ageController.text = initialAge.toString();
      }
    }
  }

  Future<void> _saveHeightPreference() async {
    // Eklendi
    final heightValue = double.tryParse(_heightController.text);
    if (heightValue != null) {
      await _prefs?.setDouble(_heightKey, heightValue);
      // Riverpod state'ini de güncelle (eğer controller değişikliği doğrudan state'i tetiklemiyorsa)
      // Bu örnekte notifier.updateHeight çağrısı _buildNumberInput içinde yapılıyor,
      // bu yüzden burada tekrar çağırmak döngüye neden olabilir.
      // Ancak, eğer kullanıcı yazmayı bitirip başka bir yere tıklarsa ve onChanged tetiklenmezse
      // diye burada da bir güncelleme düşünülebilir veya debounce eklenebilir.
      // Şimdilik sadece kaydetme işlemini yapalım.
      // ref.read(calculatorNotifierProvider.notifier).updateHeight(heightValue);
    }
  }

  Future<void> _saveAgePreference() async {
    // Eklendi
    final ageValue = int.tryParse(_ageController.text);
    if (ageValue != null) {
      await _prefs?.setInt(_ageKey, ageValue);
      // Benzer şekilde, Riverpod state güncellenmesi burada da düşünülebilir.
      // ref.read(calculatorNotifierProvider.notifier).updateAge(ageValue);
    }
  }

  @override
  void dispose() {
    _heightController.removeListener(_saveHeightPreference); // Eklendi
    _ageController.removeListener(_saveAgePreference); // Eklendi
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WidgetRef ref parametresi state sınıfında build metoduna gelir
    final calculatorStateAsync = ref.watch(calculatorNotifierProvider);
    final notifier = ref.read(calculatorNotifierProvider.notifier);
    final theme = Theme.of(context);

    // State değiştiğinde controller'ları güncellemek için listener
    ref.listen<AsyncValue<CalculatorState>>(calculatorNotifierProvider, (
      _,
      next,
    ) {
      next.whenData((state) {
        // Sadece state'deki değer controller'daki değerden farklıysa güncelle
        final currentHeightText = state.heightCm?.toStringAsFixed(1) ?? '';
        if (_heightController.text != currentHeightText) {
          final oldSelection = _heightController.selection;
          _heightController.text = currentHeightText;
          try {
            if (oldSelection.start <= _heightController.text.length &&
                oldSelection.end <= _heightController.text.length) {
              _heightController.selection = oldSelection;
            } else {
              _heightController.selection = TextSelection.fromPosition(
                TextPosition(offset: _heightController.text.length),
              );
            }
          } catch (e) {
            _heightController.selection = TextSelection.fromPosition(
              TextPosition(offset: _heightController.text.length),
            );
          }
        }

        final currentAgeText = state.age?.toString() ?? '';
        if (_ageController.text != currentAgeText) {
          final oldSelection = _ageController.selection;
          _ageController.text = currentAgeText;
          try {
            if (oldSelection.start <= _ageController.text.length &&
                oldSelection.end <= _ageController.text.length) {
              _ageController.selection = oldSelection;
            } else {
              _ageController.selection = TextSelection.fromPosition(
                TextPosition(offset: _ageController.text.length),
              );
            }
          } catch (e) {
            _ageController.selection = TextSelection.fromPosition(
              TextPosition(offset: _ageController.text.length),
            );
          }
        }
      });
    });

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight:
                100.0, // Başlığın daha aşağıda görünmesi için artırıldı
            floating: true,
            snap: true,
            pinned:
                true, // Kaydırma sırasında başlık alanının sabit kalması için
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Hesaplayıcılar', // Başlık zaten doğru
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize:
                      (theme.textTheme.headlineMedium?.fontSize ?? 28.0) *
                      0.6, // %40 küçültme
                ),
              ),
              centerTitle: true, // Başlığı ortala
              titlePadding: const EdgeInsets.only(
                bottom: 16.0,
              ), // Başlığın dikey konumunu ayarla
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                calculatorStateAsync.when(
                  data:
                      (state) => _buildCalculatorForm(
                        context,
                        ref,
                        state,
                        notifier,
                        theme,
                        _heightController,
                        _ageController,
                      ),
                  loading:
                      () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  error:
                      (err, stack) => Center(
                        child: Text('Veriler yüklenirken hata oluştu: $err'),
                      ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
} // _CalculatorPageState sınıfının sonu

// _buildCalculatorForm ve diğer yardımcı metodlar için extension
extension _CalculatorFormBuilder on _CalculatorPageState {
  Widget _buildCalculatorForm(
    BuildContext context,
    WidgetRef ref,
    CalculatorState state,
    CalculatorNotifier notifier,
    ThemeData theme,
    TextEditingController heightController,
    TextEditingController ageController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionTitle(theme, 'Kişisel Bilgiler'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildNumberInput(
                label: 'Boy (cm)',
                controller: heightController,
                onChanged: (value) {
                  // Değiştirildi
                  final newHeight = double.tryParse(value);
                  notifier.updateHeight(newHeight);
                  // _saveHeightPreference(); // Listener zaten kaydedecek
                },
                icon: Icons.height,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildNumberInput(
                label: 'Yaş',
                controller: ageController,
                onChanged: (value) {
                  // Değiştirildi
                  final newAge = int.tryParse(value);
                  notifier.updateAge(newAge);
                  // _saveAgePreference(); // Listener zaten kaydedecek
                },
                icon: Icons.cake_outlined,
                isDecimal: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDropdown<Gender>(
          context: context,
          label: 'Cinsiyet',
          value: state.gender,
          items: Gender.values,
          onChanged: (value) => notifier.updateGender(value),
          itemText: (gender) => gender == Gender.male ? 'Erkek' : 'Kadın',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 24),

        _buildSectionTitle(theme, 'Aktivite ve Hedef'),
        const SizedBox(height: 16),
        _buildDropdown<ActivityLevel>(
          context: context,
          label: 'Aktivite Seviyesi',
          value: state.activityLevel,
          items: ActivityLevel.values,
          onChanged: (value) => notifier.updateActivityLevel(value!),
          itemText: _getActivityLevelText,
          icon: Icons.directions_run,
        ),
        const SizedBox(height: 16),
        _buildDropdown<Goal>(
          context: context,
          label: 'Hedefiniz',
          value: state.goal,
          items: Goal.values,
          onChanged: (value) => notifier.updateGoal(value!),
          itemText: _getGoalText,
          icon: Icons.flag_outlined,
        ),
        const SizedBox(height: 24),

        ElevatedButton.icon(
          icon: const Icon(Icons.calculate_outlined),
          label: const Text('Hesapla'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed:
              state.heightCm != null &&
                      state.age != null &&
                      state.gender != null &&
                      state.weightKg != null
                  ? () => notifier.calculate()
                  : null,
        ),
        const SizedBox(height: 24),

        // Sonuçlar Bölümü
        if (state.bmi != null) ...[
          _buildSectionTitle(theme, 'Sonuçlar'),
          const SizedBox(height: 16),
          _buildResultCard(theme, state),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildNumberInput({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required IconData icon,
    bool isDecimal = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      keyboardType: TextInputType.numberWithOptions(
        decimal: isDecimal,
        signed: false,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label gerekli.';
        final number = double.tryParse(value);
        if (number == null) return 'Geçerli sayı girin.';
        if (number <= 0) return '0\'dan büyük olmalı.';
        return null;
      },
      onChanged: onChanged,
    );
  }

  // Görseldeki yapıya benzeyen Dropdown
  Widget _buildDropdown<T>({
    required BuildContext context,
    required String label,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) itemText,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        // Kapalı halinin görünümü (kullanıcı bunu beğenmişti)
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary.withAlpha((255 * 0.8).round()),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: theme.dividerColor.withAlpha((255 * 0.5).round()),
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: theme.dividerColor.withAlpha((255 * 0.5).round()),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface.withAlpha((255 * 0.05).round()),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 12.0,
        ),
      ),
      // Açılan menünün genel stili
      dropdownColor: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8.0),
      elevation: 3, // Biraz daha belirgin gölge
      icon: Icon(
        // Kapalı durumdaki ikon
        Icons.keyboard_arrow_down,
        color: theme.iconTheme.color?.withAlpha((255 * 0.7).round()),
        size: 24,
      ),
      menuMaxHeight: 350, // Yüksekliği biraz daha artıralım
      // DropdownMenuItem'ların içeriğini görseldeki gibi yapalım
      items:
          items.map((item) {
            bool isSelected = item == value;
            String? subtitle;
            // Alt başlıkları belirleyelim
            if (item is ActivityLevel) {
              subtitle = _getActivityLevelSubtitle(item);
            } else if (item is Gender) {
              subtitle = item == Gender.male ? 'Male' : 'Female';
            } else if (item is Goal) {
              subtitle =
                  item == Goal.lose
                      ? 'Lose Weight'
                      : (item == Goal.maintain
                          ? 'Maintain Weight'
                          : 'Gain Weight');
            }

            return DropdownMenuItem<T>(
              value: item,
              child: Container(
                // Her öğe için Container
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 14.0,
                ), // Dikey padding'i artıralım
                // Son öğe hariç alt çizgi ekleyelim
                decoration:
                    item != items.last
                        ? BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor.withAlpha((255 * 0.5).round()),
                              width: 0.5,
                            ),
                          ),
                        )
                        : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Dikeyde ortala
                  children: [
                    Column(
                      // Sol taraf: Başlık ve Alt Başlık
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          itemText(item), // Ana başlık
                          style: theme.textTheme.titleMedium?.copyWith(
                            // Başlık stili
                            fontWeight: FontWeight.w500, // Biraz daha kalın
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(
                            height: 3,
                          ), // Başlık ve alt başlık arası boşluk
                          Text(
                            // Alt başlık
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              // Alt başlık stili
                              color: theme.textTheme.bodySmall?.color
                                  ?.withAlpha((255 * 0.7).round()),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Sağ taraf: Seçili durumu gösteren ikon
                    if (isSelected)
                      Icon(
                        Icons
                            .check_circle_outline_rounded, // Farklı bir check ikonu
                        color: theme.colorScheme.primary,
                        size: 24, // İkon boyutu
                      )
                    else
                      // Seçili değilse boşluk bırakalım (ikonla aynı boyutta)
                      const SizedBox(width: 24),
                  ],
                ),
              ),
            );
          }).toList(),
      selectedItemBuilder: (BuildContext context) {
        // Seçili öğenin DropdownButtonFormField içinde nasıl görüneceği
        return items.map<Widget>((T item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Text(
              itemText(item),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge, // Kapalıykenki stil
            ),
          );
        }).toList();
      },
      onChanged: onChanged,
      validator: (value) => value == null ? '$label seçin.' : null,
    );
  }

  // Aktivite seviyesi için alt başlık döndüren yardımcı metod
  String? _getActivityLevelSubtitle(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Ofis işi, az hareket';
      case ActivityLevel.light:
        return 'Haftada 1-3 gün egzersiz';
      case ActivityLevel.moderate:
        return 'Haftada 3-5 gün egzersiz';
      case ActivityLevel.active:
        return 'Haftada 6-7 gün egzersiz';
      case ActivityLevel.veryActive:
        return 'Ağır iş/antrenman';
    }
  }

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Hareketsiz (Ofis işi)';
      case ActivityLevel.light:
        return 'Hafif Aktif';
      case ActivityLevel.moderate:
        return 'Orta Aktif';
      case ActivityLevel.active:
        return 'Aktif';
      case ActivityLevel.veryActive:
        return 'Çok Aktif';
    }
  }

  String _getGoalText(Goal goal) {
    switch (goal) {
      case Goal.lose:
        return 'Kilo Vermek';
      case Goal.maintain:
        return 'Kilo Korumak';
      case Goal.gain:
        return 'Kilo Almak';
    }
  }

  Widget _buildResultCard(ThemeData theme, CalculatorState state) {
    // Minimalist bir kart görünümü için Card widget'ını kullanalım
    return Card(
      elevation: 1.0, // Çok hafif bir gölge
      color: theme.colorScheme.surface, // Temanın yüzey rengi
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Kart içi boşluk
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildResultRow(
              theme,
              'Son Girilen Kilo:',
              '${state.weightKg?.toStringAsFixed(1) ?? '-'} kg',
            ),
            const Divider(height: 20),
            _buildResultRow(
              theme,
              'BMI (Vücut Kitle İndeksi):',
              state.bmi?.toStringAsFixed(1) ?? '-',
            ),
            _buildResultRow(
              theme,
              'BMI Kategorisi:',
              state.bmiCategory ?? '-',
              valueColor: _getBmiColor(state.bmi),
            ),
            const Divider(height: 20),
            _buildResultRow(
              theme,
              'BMR (Bazal Metabolizma Hızı):',
              '${state.bmr?.round() ?? '-'} kcal',
            ),
            _buildResultRow(
              theme,
              'TDEE (Günlük Kalori İhtiyacı):',
              '${state.tdee?.round() ?? '-'} kcal',
            ),
            const Divider(height: 20),
            _buildResultRow(
              theme,
              'Hedef Kalori (${_getGoalText(state.goal)}):',
              '${state.targetCalories?.round() ?? '-'} kcal',
              isBold: true,
            ),
            const SizedBox(height: 12),
            Text('Tahmini Makro Dağılımı:', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (state.macros != null) ...[
              _buildMacroRow(
                theme,
                'Protein:',
                state.macros!['protein']?.round(),
              ),
              _buildMacroRow(
                theme,
                'Karbonhidrat:',
                state.macros!['carbs']?.round(),
              ),
              _buildMacroRow(theme, 'Yağ:', state.macros!['fat']?.round()),
            ] else
              const Text('-'),
          ],
        ), // Column bitti
      ), // Padding bitti
    ); // Card bitti
  }

  Widget _buildResultRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyLarge),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor ?? theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(ThemeData theme, String label, int? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            '${value ?? '-'} g',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color? _getBmiColor(double? bmi) {
    if (bmi == null || bmi <= 0) return null;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 24.9) return Colors.green;
    if (bmi < 29.9) return Colors.orange;
    return Colors.red;
  }
}
