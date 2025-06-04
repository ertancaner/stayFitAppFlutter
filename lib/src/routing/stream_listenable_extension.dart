import 'dart:async';
import 'package:flutter/foundation.dart';

// Stream'i ChangeNotifier'a dönüştüren bir genişletme.
// GoRouter'ın refreshListenable parametresi ile kullanılabilir.
extension StreamListenableExtension<T> on Stream<T> {
  ChangeNotifier get listenable => _StreamChangeNotifier<T>(this);
}

class _StreamChangeNotifier<T> extends ChangeNotifier {
  _StreamChangeNotifier(Stream<T> stream) {
    _subscription = stream.listen(
      (T data) => notifyListeners(),
      onError: (Object error, StackTrace stackTrace) => notifyListeners(),
      onDone: () => notifyListeners(),
    );
  }

  late final StreamSubscription<T> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}