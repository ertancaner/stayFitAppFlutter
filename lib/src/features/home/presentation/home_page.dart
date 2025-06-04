import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stay_fit/src/features/auth/application/auth_providers.dart'; // authStateChangesProvider için geri eklendi
import 'package:stay_fit/src/features/home/application/home_providers.dart';
import 'package:stay_fit/src/features/home/domain/weight_entry.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _showAddEditWeightDialog(
    BuildContext context,
    WidgetRef ref, {
    WeightEntry? entryToEdit,
  }) async {
    final formKey = GlobalKey<FormState>();
    double? weight = entryToEdit?.weight;
    DateTime selectedDate = entryToEdit?.date ?? DateTime.now();
    final TextEditingController weightController = TextEditingController(
      text: weight?.toString() ?? '',
    );
    final theme = Theme.of(context); // Dialog için tema

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Dialog içeriğini anlık güncellemek için StatefulBuilder
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                entryToEdit == null ? 'Yeni Tartım Ekle' : 'Tartımı Düzenle',
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: weightController,
                      decoration: const InputDecoration(
                        labelText: 'Kilo (kg)',
                        // icon: Icon(Icons.monitor_weight_outlined), // Daha sade bir görünüm için kaldırıldı
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen kilonuzu girin.';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Lütfen geçerli bir sayı girin.';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Kilo 0\'dan büyük olmalıdır.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        weight = double.tryParse(value!);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        // const Icon(Icons.calendar_today_outlined), // Daha sade
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            DateFormat(
                              'dd MMMM yyyy',
                              'tr_TR',
                            ).format(selectedDate),
                          ),
                        ),
                        TextButton(
                          child: const Text('Tarih Seç'),
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                              context: dialogContext,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                              locale: const Locale(
                                'tr',
                                'TR',
                              ), // Tarih seçici için Türkçe lokalizasyon
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() {
                                // StatefulBuilder sayesinde dialog içi state güncellenir
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('İptal'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(entryToEdit == null ? 'Ekle' : 'Güncelle'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      if (weight != null) {
                        final notifier = ref.read(
                          homeNotifierProvider.notifier,
                        );
                        if (entryToEdit == null) {
                          notifier.addWeightEntry(weight!, selectedDate);
                        } else {
                          notifier.updateWeightEntry(
                            entryToEdit.copyWith(
                              weight: weight!,
                              date: selectedDate,
                            ),
                          );
                        }
                        Navigator.of(dialogContext).pop();
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSetTargetWeightDialog(
    BuildContext context,
    WidgetRef ref,
    double? currentTarget,
  ) async {
    final formKey = GlobalKey<FormState>();
    double? targetWeight = currentTarget;
    final TextEditingController targetWeightController = TextEditingController(
      text: targetWeight?.toString() ?? '',
    );
    final theme = Theme.of(context);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hedef Kilo Belirle'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: targetWeightController,
              decoration: const InputDecoration(
                labelText: 'Hedef Kilo (kg)',
                // icon: Icon(Icons.flag_outlined), // Sade görünüm
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen hedef kilonuzu girin.';
                }
                if (double.tryParse(value) == null) {
                  return 'Lütfen geçerli bir sayı girin.';
                }
                if (double.parse(value) <= 0) {
                  return 'Hedef kilo 0\'dan büyük olmalıdır.';
                }
                return null;
              },
              onSaved: (value) {
                targetWeight = double.tryParse(value!);
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Kaydet'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  if (targetWeight != null) {
                    ref
                        .read(targetWeightProvider.notifier)
                        .setTargetWeight(targetWeight!);
                    Navigator.of(dialogContext).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateChangesProvider); // Auth state'i izle
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final targetWeightAsync = ref.watch(targetWeightProvider);
    final theme = Theme.of(context);
    final DateFormat listDateFormatter = DateFormat(
      'dd MMMM yyyy, EEEE',
      'tr_TR',
    ); // Liste için Türkçe format

    return Scaffold(
      // AppBar artık temadan yönetiliyor
      // appBar: AppBar(
      //   title: const Text('StayFit'), // AppBar başlığı temadan gelecek
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.flag_outlined),
      //       tooltip: 'Hedef Kilo Belirle',
      //       onPressed: () {
      //         targetWeightAsync.whenData((currentTarget) {
      //           _showSetTargetWeightDialog(context, ref, currentTarget);
      //         });
      //       },
      //     ),
      //   ],
      // ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(weightEntriesProvider);
          ref.invalidate(targetWeightProvider);
        },
        child: authStateAsync.when(
          data: (user) {
            // Kullanıcı null ise (çıkış yapılmışsa) veya henüz auth state gelmemişse
            // (bu durum !authStateAsync.hasValue ile de kontrol edilebilir ama user == null daha net)
            // go_router yönlendirmesi gerçekleşene kadar yükleme göstergesi göster.
            if (user == null) {
              return const Center(child: CircularProgressIndicator());
            }
            // Kullanıcı varsa, normal akışa devam et
            return weightEntriesAsync.when(
              data: (entries) {
                final currentWeight =
                    entries.isNotEmpty ? entries.first.weight : null;
                return targetWeightAsync.when(
                  data: (targetWeight) {
                    double difference = 0;
                double progress = 0;
                String? initialWeightForCalc;

                if (entries.isNotEmpty) {
                  initialWeightForCalc =
                      entries.last.weight.toString(); // En eski kayıt
                }

                if (currentWeight != null && targetWeight != null) {
                  difference = currentWeight - targetWeight;
                  if (targetWeight > 0 && initialWeightForCalc != null) {
                    double initialW = double.parse(initialWeightForCalc);
                    if (initialW != targetWeight) {
                      progress =
                          (initialW - currentWeight) /
                          (initialW - targetWeight);
                    } else if (initialW == currentWeight &&
                        initialW == targetWeight) {
                      progress = 1.0;
                    }
                  } else if (currentWeight == targetWeight) {
                    progress = 1.0;
                  }
                  progress = progress.clamp(0.0, 1.0);
                }

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight:
                          100.0, // Başlığın daha aşağıda görünmesi için artırıldı
                      floating: true,
                      snap: true,
                      pinned:
                          true, // Kaydırma sırasında başlık alanının sabit kalması için
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.flag_outlined),
                          tooltip: 'Hedef Kilo Belirle',
                          onPressed: () {
                            targetWeightAsync.whenData((currentTarget) {
                              _showSetTargetWeightDialog(
                                context,
                                ref,
                                currentTarget,
                              );
                            });
                          },
                        ),
                        // Genel AppBar'a taşındığı için buradaki çıkış butonu kaldırıldı.
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'Kilo Takibi', // Yeni başlık eklendi
                          style: theme.textTheme.titleLarge?.copyWith( // Stil headlineMedium'dan titleLarge'a değiştirildi ve küçültme kaldırıldı
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        centerTitle: true,
                        titlePadding: const EdgeInsets.only(
                          bottom: 16.0,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildWeightSummaryCard(
                            context,
                            theme,
                            currentWeight,
                            targetWeight,
                            difference,
                            progress,
                          ),
                          const SizedBox(height: 24), // Biraz azaltıldı
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4.0,
                              bottom: 8.0,
                            ),
                            child: Text(
                              'Geçmiş Tartımlar',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (entries.isEmpty)
                            _buildEmptyState(context, theme)
                          else
                            _buildWeightHistoryList(
                              context,
                              ref,
                              entries,
                              listDateFormatter,
                            ),
                        ]),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
                  error:
                      (err, stack) =>
                          Center(child: Text('Hedef kilo yüklenemedi: $err')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (err, stack) =>
                      Center(child: Text('Tartımlar yüklenemedi: $err')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Kimlik durumu yüklenemedi: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditWeightDialog(context, ref),
        label: const Text('Yeni Tartım'),
        icon: const Icon(Icons.add),
        // elevation: 4.0, // Temadan alır
        // backgroundColor: theme.colorScheme.primary, // Temadan alır
        // foregroundColor: theme.colorScheme.onPrimary, // Temadan alır
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      // decoration: BoxDecoration(
      //   color: theme.cardTheme.color,
      //   borderRadius: BorderRadius.circular(12.0),
      // ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 60,
            color: theme.colorScheme.primary.withAlpha((255 * 0.6).round()),
          ),
          const SizedBox(height: 20),
          Text(
            'Henüz Tartım Kaydı Yok',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Sağ alttaki "+" butonu ile ilk tartımınızı ekleyebilirsiniz.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.7).round()),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeightSummaryCard(
    BuildContext context,
    ThemeData theme,
    double? currentWeight,
    double? targetWeight,
    double difference,
    double progress,
  ) {
    return Card(
      // elevation: 0, // Temadan alır
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // Temadan alır
      // color: theme.cardTheme.color, // Temadan alır
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildWeightDisplay(
                    theme,
                    'Güncel Kilo',
                    currentWeight,
                    'kg',
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildWeightDisplay(
                    theme,
                    'Hedef Kilo',
                    targetWeight,
                    'kg',
                    Colors.green.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (currentWeight != null && targetWeight != null)
              Center(
                child: Text(
                  difference == 0
                      ? 'Hedefindesin! 🎉'
                      : 'Hedefe: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(1)} kg',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        difference == 0
                            ? Colors.green.shade700
                            : (difference < 0
                                ? Colors.green.shade700
                                : Colors.orange.shade700),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (targetWeight != null && targetWeight > 0)
              Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(
                      milliseconds: 1200,
                    ), // Animasyon süresi
                    curve: Curves.easeInOutCubic, // Animasyon eğrisi
                    tween: Tween<double>(
                      begin: 0, // Animasyonun başlangıç değeri
                      end: progress, // Animasyonun bitiş değeri
                    ),
                    builder:
                        (context, value, _) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: value, // Anlık animasyon değeri
                            minHeight: 10, // Biraz daha kalın ve belirgin
                            // backgroundColor: theme.progressIndicatorTheme.linearTrackColor, // Temadan alır
                            // valueColor: AlwaysStoppedAnimation<Color>(theme.progressIndicatorTheme.color!), // Temadan alır
                          ),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Tamamlandı',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha((255 * 0.7).round()),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightDisplay(
    ThemeData theme,
    String label,
    double? value,
    String unit,
    Color valueColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withAlpha((255 * 0.8).round()),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value != null ? value.toStringAsFixed(1) : '-',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(
          value != null ? unit : '',
          style: theme.textTheme.bodySmall?.copyWith(
            color: valueColor.withAlpha((255 * 0.8).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<WeightEntry> entries,
    DateFormat formatter,
  ) {
    final theme = Theme.of(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          // contentPadding: EdgeInsets.zero, // Daha kompakt görünüm için
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
            foregroundColor: theme.colorScheme.primary,
            child: Text(
              DateFormat('dd').format(entry.date),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            '${entry.weight.toStringAsFixed(1)} kg',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            formatter.format(entry.date),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha((255 * 0.7).round()),
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.iconTheme.color?.withAlpha((255 * 0.7).round()),
            ),
            // Açılan menünün stilini ayarlayalım (Dropdown'a benzer)
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            elevation: 2,
            color: theme.colorScheme.surface, // Veya theme.cardColor
            tooltip: 'Seçenekler', // Erişilebilirlik için
            onSelected: (value) {
              if (value == 'edit') {
                _showAddEditWeightDialog(context, ref, entryToEdit: entry);
              } else if (value == 'delete') {
                // Silme işlemi için ID'nin null olmadığını kontrol edelim (gerçi listede varsa null olmamalı)
                if (entry.id != null) {
                  _showDeleteConfirmationDialog(context, ref, entry.id!);
                }
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  // Düzenle Öğesi
                  PopupMenuItem<String>(
                    value: 'edit',
                    padding:
                        EdgeInsets
                            .zero, // İçerideki widget padding'i kontrol etsin
                    child: Container(
                      // Minimalist görünüm için Container
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: theme.iconTheme.color?.withAlpha((255 * 0.8).round()),
                          ),
                          const SizedBox(width: 12),
                          Text('Düzenle', style: theme.textTheme.bodyLarge),
                        ],
                      ),
                    ),
                  ),
                  // Ayırıcı
                  const PopupMenuDivider(height: 1),
                  // Sil Öğesi
                  PopupMenuItem<String>(
                    value: 'delete',
                    padding: EdgeInsets.zero,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sil',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
          ),
        );
      },
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.grey[200],
          ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String entryId, // Tip int'ten String'e değiştirildi
  ) async {
    // final theme = Theme.of(context); // Bu değişken kullanılmıyor.
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Kaydı Sil'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bu tartım kaydını silmek istediğinizden emin misiniz?'),
                Text('Bu işlem geri alınamaz.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
              onPressed: () {
                ref
                    .read(homeNotifierProvider.notifier)
                    .deleteWeightEntry(entryId);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
