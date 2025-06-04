import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stay_fit/src/features/workout_tracker/application/workout_providers.dart';
import 'package:stay_fit/src/features/workout_tracker/domain/exercise.dart';
import 'package:stay_fit/src/routing/app_router.dart'; // Rota isimleri için
import 'package:go_router/go_router.dart'; // context.pushNamed için

class WorkoutTrackerPage extends ConsumerStatefulWidget {
  // ConsumerStatefulWidget olarak değiştirildi
  const WorkoutTrackerPage({super.key});

  @override
  ConsumerState<WorkoutTrackerPage> createState() => _WorkoutTrackerPageState();
}

class _WorkoutTrackerPageState extends ConsumerState<WorkoutTrackerPage> {
  // State sınıfı oluşturuldu
  List<WorkoutLog> _displayedWorkoutLogs = [];

  // Dialog metodları state sınıfına taşındı (eğer state'e bağlıysa)
  // Bu örnekte _showDeleteConfirmationDialog state'e bağlı değil, olduğu gibi kalabilir veya static yapılabilir.

  @override
  Widget build(BuildContext context) {
    // WidgetRef ref parametresi build metoduna eklendi
    final workoutLogsAsync = ref.watch(workoutLogsProvider);
    final theme = Theme.of(context);
    final DateFormat listDateFormatter = DateFormat(
      'dd MMMM yyyy, EEEE',
      'tr_TR',
    );

    // Provider'dan gelen veriyi dinle ve _displayedWorkoutLogs'u güncelle
    ref.listen<AsyncValue<List<WorkoutLog>>>(workoutLogsProvider, (_, next) {
      if (next.hasValue) {
        if (mounted) {
          // State'in hala ağaçta olduğundan emin ol
          setState(() {
            _displayedWorkoutLogs = next.value!;
          });
        }
      } else if (next.hasError) {
        if (mounted) {
          setState(() {
            _displayedWorkoutLogs = []; // Hata durumunda listeyi boşalt
          });
        }
      }
    });

    // İlk yüklemede veya provider henüz veri yüklemediyse _displayedWorkoutLogs boş olabilir.
    // Bu yüzden workoutLogsAsync'in durumuna göre _displayedWorkoutLogs'u doldur.
    if (workoutLogsAsync.hasValue &&
        _displayedWorkoutLogs.isEmpty &&
        workoutLogsAsync.value!.isNotEmpty) {
      // Bu senaryo, sayfa ilk açıldığında ve provider'dan veri geldiğinde çalışır.
      // Ancak ref.listen zaten bunu ele almalı. Yine de bir güvenlik önlemi.
      // setState kullanmadan doğrudan atama yapmak build döngüsüne neden olabilir.
      // Bu yüzden ref.listen'in yeterli olması beklenir.
      // Şimdilik bu bloğu yorumda bırakalım, ref.listen'in işini yapıp yapmadığını görelim.
      // _displayedWorkoutLogs = workoutLogsAsync.value!;
    }

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
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Yeni Antrenman Ekle',
                onPressed: () => context.pushNamed(AppRoute.addExercise.name),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Ağırlık Takibi', // Başlık güncellendi
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
          workoutLogsAsync.when(
            data: (fetchedLogs) {
              // Gelen veri `fetchedLogs`
              // Eğer _displayedWorkoutLogs henüz güncellenmediyse (ilk build veya listen tetiklenmediyse)
              // ve fetchedLogs doluysa, _displayedWorkoutLogs'u güncelle.
              // Bu, özellikle sayfa ilk açıldığında ve listen henüz state'e yansımadığında önemli.
              // Ancak bu, build sırasında setState çağırmak anlamına gelir ki bu istenmez.
              // En iyisi, _displayedWorkoutLogs'u doğrudan kullanmak ve ref.listen ile güncellemek.
              // Eğer _displayedWorkoutLogs boşsa ve fetchedLogs doluysa, bu bir sonraki build'de düzelecektir.
              // Şimdilik, _displayedWorkoutLogs'u kullanalım.

              // Eğer provider'dan gelen veri (_displayedWorkoutLogs'a atanmış olan) boşsa
              if (_displayedWorkoutLogs.isEmpty &&
                  !workoutLogsAsync.isLoading) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 60,
                            color: theme.colorScheme.primary.withAlpha((255 * 0.6).round()),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Henüz Antrenman Kaydı Yok',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Yukarıdaki "+" butonu ile ilk antrenmanınızı ekleyebilirsiniz.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withAlpha((255 * 0.7).round()),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              // Antrenman listesi
              return SliverPadding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 16.0,
                  right: 16.0,
                  bottom: 80.0,
                ), // FAB için altta boşluk
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final workoutLog =
                          _displayedWorkoutLogs[index]; // _displayedWorkoutLogs kullanılıyor
                      return Dismissible(
                        key: ValueKey(
                          workoutLog.id ??
                              DateTime.now().millisecondsSinceEpoch,
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          if (workoutLog.id != null) {
                            final logToDeleteId = workoutLog.id!;
                            // Sadece veritabanından silme işlemini tetikle
                            // Provider güncellendiğinde ref.listen UI'ı güncelleyecektir.
                            ref
                                .read(workoutNotifierProvider.notifier)
                                .deleteWorkoutLog(logToDeleteId);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${workoutLog.title ?? listDateFormatter.format(workoutLog.date)} antrenmanı silindi.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        background: Container(
                          color: Colors.redAccent.withAlpha((255 * 0.8).round()),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'SİL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(
                                Icons.delete_sweep_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          child: ExpansionTile(
                            key: PageStorageKey('workoutLog_${workoutLog.id}'),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (workoutLog.title != null &&
                                    workoutLog.title!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 3.0),
                                    child: Text(
                                      workoutLog.title!,
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Text(
                                  listDateFormatter.format(workoutLog.date),
                                  style:
                                      (workoutLog.title != null &&
                                              workoutLog.title!.isNotEmpty)
                                          ? theme.textTheme.labelMedium
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withAlpha((255 * 0.75).round()),
                                              )
                                          : theme.textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                ),
                              ],
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16.0,
                              8.0,
                              16.0,
                              16.0,
                            ),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            children:
                                workoutLog.loggedExercises.map((exercise) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                exercise.exerciseName,
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          theme
                                                              .colorScheme
                                                              .onSurface,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 48,
                                              height: 48,
                                              child: PopupMenuButton<String>(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  size: 24,
                                                  color: theme.iconTheme.color
                                                      ?.withAlpha((255 * 0.8).round()),
                                                ),
                                                tooltip: 'Hareket Seçenekleri',
                                                onSelected: (value) {
                                                  if (value ==
                                                      'edit_exercise') {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Hareket düzenleme özelliği yakında eklenecektir.',
                                                        ),
                                                      ),
                                                    );
                                                  } else if (value ==
                                                      'delete_exercise') {
                                                    if (exercise.id != null && workoutLog.id != null) {
                                                      // Metod adı _showDeleteExerciseConfirmationDialog olarak güncellendi.
                                                      _showDeleteExerciseConfirmationDialog(
                                                        context,
                                                        ref,
                                                        workoutLog.id!, // workoutLogId (String)
                                                        exercise.id!, // loggedExerciseId (String)
                                                      );
                                                    }
                                                  }
                                                },
                                                itemBuilder:
                                                    (context) => [
                                                      const PopupMenuItem<
                                                        String
                                                      >(
                                                        value: 'edit_exercise',
                                                        child: Text(
                                                          'Hareketi Düzenle',
                                                        ),
                                                      ),
                                                      const PopupMenuItem<
                                                        String
                                                      >(
                                                        value:
                                                            'delete_exercise',
                                                        child: Text(
                                                          'Hareketi Sil',
                                                          style: TextStyle(
                                                            color:
                                                                Colors
                                                                    .redAccent,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (exercise.category != null &&
                                            exercise.category!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2.0,
                                              bottom: 6.0,
                                            ),
                                            child: Text(
                                              exercise.category!,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant
                                                        .withAlpha((255 * 0.7).round()),
                                                    fontSize: 13,
                                                  ),
                                            ),
                                          ),
                                        if (exercise.sets.isNotEmpty)
                                          ...exercise.sets.map((set) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                                top: 4.0,
                                                bottom: 4.0,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '${set.reps} tekrar x ${set.weight.toStringAsFixed(1)} kg',
                                                      style: theme
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: theme
                                                                .colorScheme
                                                                .onSurface
                                                                .withAlpha(
                                                                  (255 * 0.85).round(),
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                  if (set.restTimeInSeconds > 0)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 8.0,
                                                          ),
                                                      child: Text(
                                                        '${set.restTimeInSeconds} sn dinlenme',
                                                        style: theme
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color: theme
                                                                  .colorScheme
                                                                  .onSurfaceVariant
                                                                  .withAlpha(
                                                                    (255 * 0.6).round(),
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          })
                                        else
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                              top: 2.0,
                                            ),
                                            child: Text(
                                              'Henüz set eklenmemiş.',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontStyle: FontStyle.italic,
                                                    color: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color
                                                        ?.withAlpha((255 * 0.6).round()),
                                                  ),
                                            ),
                                          ),
                                        if (workoutLog.loggedExercises.indexOf(
                                              exercise,
                                            ) <
                                            workoutLog.loggedExercises.length -
                                                1)
                                          const Divider(
                                            height: 24,
                                            thickness: 0.7,
                                            indent: 8,
                                            endIndent: 8,
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      );
                    },
                    childCount:
                        _displayedWorkoutLogs
                            .length, // _displayedWorkoutLogs kullanılıyor
                  ),
                ),
              );
            },
            loading:
                () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Antrenmanlar yüklenemedi: $err')),
                ),
          ),
        ],
      ),
    );
  }

  // Metod adı ve parametreleri güncellendi: Hareketi (LoggedExercise) silmek için.
  Future<void> _showDeleteExerciseConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    String workoutLogId, // workoutLogId (String) eklendi
    String loggedExerciseId, // exerciseId -> loggedExerciseId (String) olarak güncellendi
  ) async {
    final theme = Theme.of(context); // theme değişkeni eklendi
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Kullanıcı dışarı tıklayarak kapatamaz
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text( // Başlık güncellendi
            'Hareketi Sil',
            style: theme.textTheme.titleLarge
                ?.copyWith(color: theme.colorScheme.error),
          ),
          content: const SingleChildScrollView( // İçerik güncellendi
            child: ListBody(
              children: <Widget>[
                Text('Bu hareketi ve tüm setlerini silmek istediğinizden emin misiniz?'),
                SizedBox(height: 8),
                Text('Bu işlem geri alınamaz.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('İptal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dialog'u kapat
              },
            ),
            ElevatedButton( // Buton stili güncellendi
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Sil'),
              onPressed: () {
                // Hareketi silme işlemini burada çağır
                ref
                    .read(workoutNotifierProvider.notifier)
                    .deleteLoggedExercise(workoutLogId, loggedExerciseId); // Doğru argümanlarla çağrı
                Navigator.of(dialogContext).pop(); // Dialog'u kapat
                ScaffoldMessenger.of(context).showSnackBar( // SnackBar eklendi
                  const SnackBar(
                    content: Text('Hareket başarıyla silindi.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
