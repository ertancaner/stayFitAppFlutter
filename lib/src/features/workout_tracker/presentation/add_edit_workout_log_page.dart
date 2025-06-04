import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:stay_fit/src/features/workout_tracker/application/workout_providers.dart';
// exercise.dart içinde LoggedExercise ve LoggedSet var, Exercise ve ExerciseSet yok.
// Bu import doğru, ancak içindeki sınıfların adları farklı.
import 'package:stay_fit/src/features/workout_tracker/domain/exercise.dart';
import 'package:go_router/go_router.dart'; // GoRouter importu
// predefined_exercises.dart dosyasını import edelim
import 'package:stay_fit/src/features/workout_tracker/data/predefined_exercises.dart';

// Sayfanın amacı artık bir antrenman gününü (WorkoutLog) ve içindeki egzersizleri (LoggedExercise) eklemek.
// Bu yüzden exerciseToEdit parametresi WorkoutLog veya WorkoutLog'un ID'si olabilir.
// Şimdilik, sadece yeni antrenman günü eklemeye odaklanalım.
class AddEditWorkoutLogPage extends ConsumerStatefulWidget {
  // Sınıf adını güncelleyelim
  final int? workoutLogIdToEdit; // Düzenlenecek antrenman gününün ID'si (opsiyonel)

  const AddEditWorkoutLogPage({super.key, this.workoutLogIdToEdit});

  @override
  ConsumerState<AddEditWorkoutLogPage> createState() =>
      _AddEditWorkoutLogPageState();
}

class _AddEditWorkoutLogPageState extends ConsumerState<AddEditWorkoutLogPage> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  bool _isSaving = false;

  // O anki antrenman gününe eklenecek egzersizleri tutar
  final List<LoggedExercise> _currentLoggedExercises = [];
  // O an seçili/eklenmekte olan egzersizin bilgileri
  String? _selectedCategory;
  PredefinedExercise? _selectedPredefinedExercise;
  List<LoggedSet> _currentExerciseSets = [];

  @override
  void initState() {
    super.initState();
    // Başlangıçta bir boş set ekleyelim (yeni bir hareket için)
    _addEmptySetToCurrentExercise();

    if (widget.workoutLogIdToEdit != null) {
      _loadWorkoutLogForEditing();
    } else {
      _selectedDate = DateTime.now();
    }
    // workoutLogIdToEdit varsa, o log'u yükleyip _selectedDate ve _currentLoggedExercises'i doldurma işlemi _loadWorkoutLogForEditing içinde yapılıyor.
  }

Future<void> _loadWorkoutLogForEditing() async {
    if (widget.workoutLogIdToEdit == null) return;

    // workoutLogsProvider'dan veriyi oku.
    // Bu provider Future<List<WorkoutLog>> döndürdüğü için .future ile erişebiliriz.
    try {
      final allLogs = await ref.read(workoutLogsProvider.future);
      final logToEdit = allLogs.firstWhere(
        (log) => log.id == widget.workoutLogIdToEdit?.toString(), // widget.workoutLogIdToEdit String'e çevrildi
        // orElse bloğu, eğer log bulunamazsa ne yapılacağını belirtir.
        // Bu durumda, teorik olarak ID geçerliyse bulunmalı.
        // Eğer bulunamazsa, yeni bir log gibi davranılabilir veya hata gösterilebilir.
        // Şimdilik, bulunamazsa boş bir log (veya varsayılan tarihle) oluşturuyoruz.
        // Ancak bu senaryo, yönlendirme mantığı doğruysa pek olası değil.
        orElse: () {
          // Log bulunamadıysa, belki bir hata mesajı göstermek veya
          // yeni bir log oluşturma moduna geçmek daha uygun olabilir.
          // Şimdilik, sadece konsola bir uyarı yazıp varsayılan bir tarihle devam edelim.
          // print('Düzenlenecek WorkoutLog bulunamadı: ID ${widget.workoutLogIdToEdit}');
          return WorkoutLog(date: DateTime.now(), loggedExercises: []);
        },
      );

      if (mounted) {
        setState(() {
          _selectedDate = logToEdit.date;
          _currentLoggedExercises.clear();
          _currentLoggedExercises.addAll(logToEdit.loggedExercises);
          // Kullanıcı arayüzünde _currentLoggedExercises listesini göstermek için
          // bir yapı eklenmeli. Örneğin, eklenen egzersizlerin bir listesi.
          // Ayrıca, bir egzersizi düzenleme veya silme işlevselliği de eklenebilir.
        });
      }
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi verilebilir.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Antrenman yüklenirken hata oluştu: $e')),
        );
      }
    }
  }

  void _addEmptySetToCurrentExercise() {
    setState(() {
      // loggedExerciseId'yi burada bilemiyoruz, bu setler bir LoggedExercise'e eklenecek.
      // Bu ID, _addCurrentExerciseToLog metodu içinde LoggedExercise oluşturulurken atanacak.
      // Şimdilik geçici bir ID (örn: 0) veya null (eğer model izin veriyorsa) kullanılabilir.
      // LoggedSet modeli loggedExerciseId'yi required olarak tutuyor.
      // Bu yüzden, bu setler geçici bir listede tutulup, LoggedExercise'e eklenirken
      // doğru loggedExerciseId ile kopyalanmalı.
      // Kullanıcının isteği üzerine const kaldırıldı.
      // Hata mesajına göre LoggedSet.loggedExerciseId String tipinde.
      _currentExerciseSets.add(
        LoggedSet(loggedExerciseId: '', reps: 0, weight: 0),
      );
    });
  }

  void _removeSetFromCurrentExercise(int index) {
    if (_currentExerciseSets.length > 1) {
      setState(() {
        _currentExerciseSets.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir set kalmalıdır.')),
      );
    }
  }

  void _updateSetInCurrentExercise(int index, LoggedSet updatedSet) {
    setState(() {
      _currentExerciseSets[index] = updatedSet;
    });
  }

  // Seçilen _selectedPredefinedExercise ve _currentExerciseSets'i alıp
  // _currentLoggedExercises listesine ekler VE VERİTABANINA KAYDEDER.
  Future<void> _addCurrentExerciseToLogAndSave() async {
    // Metod adını güncelleyelim
    if (_selectedPredefinedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir hareket seçin.')),
      );
      return;
    }

    final validSets =
        _currentExerciseSets.where((s) => s.reps > 0 || s.weight > 0).toList();

    if (validSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir geçerli set girin.')),
      );
      return;
    }

    setState(() => _isSaving = true); // Kaydetme işlemi başlıyor
    final notifier = ref.read(workoutNotifierProvider.notifier);

    try {
      // 1. LoggedExercise'i DB'ye ekle ve ID'leri al
      final exerciseLogIds = await notifier.addExerciseToLog(
        _selectedPredefinedExercise!.name,
        _selectedPredefinedExercise!.category,
        _selectedDate,
      );
      final workoutLogIdForSets = exerciseLogIds['workoutLogId'];
      final newLoggedExerciseIdString = exerciseLogIds['loggedExerciseId'];

      if (workoutLogIdForSets == null || newLoggedExerciseIdString == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Egzersiz veya antrenman günlüğü ID alınamadı.')),
          );
        }
        setState(() => _isSaving = false);
        return;
      }

      // 2. Setleri bu yeni LoggedExercise ID'si ve WorkoutLog ID'si ile DB'ye ekle
      for (var set in validSets) {
        await notifier.addSetToExercise(
          workoutLogIdForSets, // workoutLogId (String)
          newLoggedExerciseIdString, // loggedExerciseId (String)
          set.copyWith(
            // LoggedSet içindeki loggedExerciseId de String olmalı.
            // Modelde (domain/exercise.dart) LoggedSet.loggedExerciseId String olarak tanımlı.
            loggedExerciseId: newLoggedExerciseIdString,
          ), // LoggedSet nesnesi
        );
      }

      // UI'da gösterilen _currentLoggedExercises listesini de güncelleyebiliriz,
      // ancak bu sayfa artık anlık kayıt yaptığı için bu liste belki gereksiz olabilir.
      // Şimdilik, sadece başarılı mesajı gösterip formu sıfırlayalım.
      // _currentLoggedExercises.add(newlySavedExercise); // Eğer gerekirse

      ref.invalidate(workoutLogsProvider); // WorkoutTrackerPage'i güncelle

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '"${_selectedPredefinedExercise!.name}" günlüğe eklendi ve kaydedildi.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Formu bir sonraki hareket için sıfırla
      setState(() {
        _selectedPredefinedExercise = null;
        // _selectedCategory = null; // Kullanıcı aynı kategoriden devam etmek isteyebilir
        _currentExerciseSets = [];
        _addEmptySetToCurrentExercise();
      });
    } catch (e) {
      // print('Hareket eklenirken hata oluştu: $e');
      // print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hareket eklenemedi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false); // Kaydetme işlemi bitti
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // _saveForm metodu artık kullanılmıyor çünkü her hareket anlık olarak
  // _addCurrentExerciseToLogAndSave metodu ile kaydediliyor.
  // AppBar'daki "BİTTİ" butonu sadece sayfadan çıkış yapıyor.
  // Bu metodu tamamen kaldırabiliriz.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Seçilen kategoriye göre filtrelenmiş egzersizler
    final List<PredefinedExercise> exercisesForCategory =
        _selectedCategory == null
            ? []
            : predefinedExercises
                .where((ex) => ex.category == _selectedCategory)
                .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workoutLogIdToEdit == null
            ? 'Yeni Antrenman Günü'
            : 'Antrenmanı Düzenle'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            // IconButton(
            //   icon: const Icon(Icons.save_outlined),
            //   tooltip: 'Antrenman Gününü Kaydet', // Artık anlık kayıt var
            //   onPressed: _saveForm, // _saveForm artık farklı bir amaç için veya kaldırıldı
            // ),
            // Şimdilik AppBar'da kaydet butonu olmasın, geri tuşuyla çıkılabilir.
            // Ya da bir "Bitti" butonu eklenebilir.
            TextButton(
              onPressed: () {
                if (mounted) {
                  // Eğer eklenmemiş bir hareket varsa kullanıcıyı uyarabiliriz.
                  if (_selectedPredefinedExercise != null &&
                      _currentExerciseSets.any(
                        (s) => s.reps > 0 || s.weight > 0,
                      )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Eklenmemiş bir hareket var. Lütfen önce günlüğe ekleyin veya silin.',
                        ),
                      ),
                    );
                  } else {
                    context.pop();
                  }
                }
              },
              child: const Text('BİTTİ', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form( // Form widget'ı en dışta
        key: _formKey,
        child: SingleChildScrollView( // SingleChildScrollView, Form'un çocuğu
          child: Padding( // Padding, SingleChildScrollView'ın çocuğu
            padding: const EdgeInsets.all(16.0),
            child: Column( // Column, Padding'in çocuğu
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
              // Tarih Seçimi
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tarih: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(_selectedDate)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  TextButton(
                    child: const Text('Değiştir'),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kategori Seçimi
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Antrenman Kategorisi',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                hint: const Text('Kategori Seçin'),
                isExpanded: true,
                items:
                    MuscleGroup.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _selectedPredefinedExercise =
                        null; // Kategori değişince hareket seçimini sıfırla
                    // _currentExerciseSets = []; // İsteğe bağlı, setleri de sıfırlayabiliriz
                    // _addEmptySetToCurrentExercise();
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Lütfen bir kategori seçin.' : null,
              ),
              const SizedBox(height: 16),

              // Hareket Seçimi (Kategoriye göre filtrelenmiş)
              if (_selectedCategory != null)
                DropdownButtonFormField<PredefinedExercise>(
                  decoration: const InputDecoration(
                    labelText: 'Hareket Seçin',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPredefinedExercise,
                  hint: const Text('Hareket Seçin'),
                  isExpanded: true,
                  items:
                      exercisesForCategory
                          .map(
                            (exercise) => DropdownMenuItem(
                              value: exercise,
                              child: Text(exercise.name),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPredefinedExercise = value;
                      // _currentExerciseSets = []; // Hareket değişince setleri sıfırla
                      // _addEmptySetToCurrentExercise();
                    });
                  },
                  validator:
                      (value) =>
                          value == null ? 'Lütfen bir hareket seçin.' : null,
                ),
              const SizedBox(height: 16),

              // O anki hareket için setler
              if (_selectedPredefinedExercise != null) ...[
                Text(
                  '"${_selectedPredefinedExercise!.name}" için Setler:',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  // Bu ListView'ın yüksekliği sınırlı olmalı veya Expanded içinde olmalı
                  shrinkWrap: true, // Column içinde olduğu için
                  physics:
                      const NeverScrollableScrollPhysics(), // Column içinde olduğu için
                  itemCount: _currentExerciseSets.length,
                  itemBuilder: (context, index) {
                    // _buildSetRow'u _currentExerciseSets ve _updateSetInCurrentExercise ile kullan
                    return _buildSetRow(
                      context,
                      index,
                      theme,
                      _currentExerciseSets,
                      _updateSetInCurrentExercise,
                      _removeSetFromCurrentExercise,
                    );
                  },
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Bu Harekete Set Ekle'),
                    onPressed: _addEmptySetToCurrentExercise,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_task),
                    label: const Text(
                      'Bu Hareketi Günlüğe Ekle ve Kaydet',
                    ), // Buton metni güncellendi
                    onPressed:
                        _addCurrentExerciseToLogAndSave, // Yeni metot çağrılıyor
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
                const Divider(height: 32, thickness: 1),
              ],

              // Günlüğe Eklenmiş Egzersizler
              // Günlüğe Eklenmiş Egzersizler bölümü artık gereksiz, çünkü her hareket anlık kaydediliyor
              // ve WorkoutTrackerPage'de görüntülenecek.
              // if (_currentLoggedExercises.isNotEmpty) ...[
              //   Text(
              //     'Günlüğe Eklenen Hareketler:',
              //     style: theme.textTheme.titleLarge,
              //   ),
              //   const SizedBox(height: 8),
              //   Expanded(
              //     child: ListView.builder(
              //       itemCount: _currentLoggedExercises.length,
              //       itemBuilder: (context, index) {
              //         final loggedEx = _currentLoggedExercises[index];
              //         return Card(
              //           margin: const EdgeInsets.symmetric(vertical: 4),
              //           child: ListTile(
              //             title: Text(loggedEx.exerciseName),
              //             subtitle: Text(
              //               '${loggedEx.category} - ${loggedEx.sets.length} set',
              //             ),
              //           ),
              //         );
              //       },
              //     ),
              //   ),
              // ] else if (_selectedPredefinedExercise != null)
              //   const Spacer(),
              // Eski set listesi ve ekleme butonu (artık yukarıda hareket bazlı)
              // Text('Setler:', style: theme.textTheme.titleMedium),
              // const SizedBox(height: 8),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: _sets.length,
              //     itemBuilder: (context, index) {
              //       return _buildSetRow(context, index, theme);
              //     },
              //   ),
              // ),
              // const SizedBox(height: 8),
              // Center(
              //   child: TextButton.icon(
              //     icon: const Icon(Icons.add_circle_outline),
              //     label: const Text('Set Ekle'),
              //     onPressed: _addSet,
              //   ),
              // ),
            ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetRow(
    BuildContext context,
    int index,
    ThemeData theme,
    List<LoggedSet> targetSets, // Hangi set listesinin güncelleneceği
    Function(int, LoggedSet) onUpdateSet, // Güncelleme fonksiyonu
    Function(int) onRemoveSet, // Silme fonksiyonu
  ) {
    final currentSet = targetSets[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey(
                'reps_${_selectedPredefinedExercise?.name}_$index',
              ), // Key'i unik yapalım
              initialValue:
                  currentSet.reps == 0 &&
                          currentSet.weight == 0 &&
                          targetSets.length > 1 &&
                          index == targetSets.length - 1
                      ? ''
                      : currentSet.reps.toString(),
              decoration: InputDecoration(
                labelText: 'Tekrar',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                onUpdateSet(
                  index,
                  currentSet.copyWith(reps: int.tryParse(value) ?? 0),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              key: ValueKey(
                'weight_${_selectedPredefinedExercise?.name}_$index',
              ), // Key'i unik yapalım
              initialValue:
                  currentSet.reps == 0 &&
                          currentSet.weight == 0 &&
                          targetSets.length > 1 &&
                          index == targetSets.length - 1
                      ? ''
                      : currentSet.weight.toString(),
              decoration: InputDecoration(
                labelText: 'Ağırlık (kg)',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (value) {
                onUpdateSet(
                  index,
                  currentSet.copyWith(weight: double.tryParse(value) ?? 0.0),
                );
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.remove_circle_outline,
              color: targetSets.length > 1 ? Colors.redAccent : Colors.grey,
            ),
            onPressed: targetSets.length > 1 ? () => onRemoveSet(index) : null,
          ),
        ],
      ),
    );
  }
}
