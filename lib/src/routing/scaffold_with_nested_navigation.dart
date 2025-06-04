import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ConsumerWidget için eklendi
import 'package:go_router/go_router.dart';
import 'package:stay_fit/src/features/auth/application/auth_providers.dart'; // authServiceProvider için eklendi
// import 'package:stay_fit/src/routing/app_router.dart'; // AppRoute enum'u için - Artık kullanılmıyor

class ScaffoldWithNestedNavigation extends ConsumerWidget { // StatelessWidget'tan ConsumerWidget'a değiştirildi
  const ScaffoldWithNestedNavigation({Key? key, required this.navigationShell})
    : super(key: key ?? const ValueKey<String>('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) { // WidgetRef ref eklendi
    final theme = Theme.of(context);
    const double iconSize = 28.0; // İkon boyutu
    const double selectedIconSize = 32.0; // Seçili ikon boyutu (animasyon için)

    return Scaffold(
      appBar: AppBar( // AppBar eklendi
        leading: IconButton( // Sol üst köşeye çıkış butonu
          icon: const Icon(Icons.logout),
          tooltip: 'Çıkış Yap',
          onPressed: () async {
            final bool? confirmSignOut = await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('Çıkış Yap'),
                  content: const Text('Çıkmak istediğinize emin misiniz?'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('İptal'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false); // Onaylanmadı
                      },
                    ),
                    TextButton(
                      child: const Text('Çıkış Yap'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(true); // Onaylandı
                      },
                    ),
                  ],
                );
              },
            );

            if (confirmSignOut == true) {
              await ref.read(authServiceProvider).signOut();
              // Manuel yönlendirme veya refresh çağrısına gerek yok.
              // app_router.dart'taki ValueNotifier değişikliği bunu halletmeli.
            }
          },
        ),
        title: const Text('Stay Fit'), // Uygulama başlığı geri getirildi
        centerTitle: true,
      ),
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _goBranch,
        iconSize: iconSize, // Genel ikon boyutu
        selectedFontSize: 0, // Seçili etiketi gizle
        unselectedFontSize: 0, // Seçili olmayan etiketi gizle
        type:
            BottomNavigationBarType
                .fixed, // Etiketler gizlendiğinde fixed daha iyi durabilir
        // backgroundColor: theme.bottomNavigationBarTheme.backgroundColor, // Temadan alır
        // selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor, // Temadan alır
        // unselectedItemColor: theme.bottomNavigationBarTheme.unselectedItemColor, // Temadan alır
        items: [
          _buildNavItem(
            Icons.home_outlined,
            Icons.home,
            0,
            theme,
            iconSize,
            selectedIconSize,
          ),
          _buildNavItem(
            Icons.fitness_center_outlined,
            Icons.fitness_center,
            1,
            theme,
            iconSize,
            selectedIconSize,
          ),
          _buildNavItem(
            Icons.calculate_outlined,
            Icons.calculate,
            2,
            theme,
            iconSize,
            selectedIconSize,
          ),
          _buildNavItem(
            Icons.chat_bubble_outline,
            Icons.chat_bubble,
            3,
            theme,
            iconSize,
            selectedIconSize,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    int index,
    ThemeData theme,
    double baseSize,
    double activeSize,
  ) {
    final bool isSelected = navigationShell.currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: isSelected ? activeSize + 4 : baseSize + 4, // Hafif padding için
        height: isSelected ? activeSize + 4 : baseSize + 4,
        child: Icon(
          isSelected ? activeIcon : icon,
          size: isSelected ? activeSize : baseSize,
          // color: isSelected ? theme.bottomNavigationBarTheme.selectedItemColor : theme.bottomNavigationBarTheme.unselectedItemColor, // Temadan alır
        ),
      ),
      label: '', // Etiketleri boş bırakıyoruz
    );
  }
}
