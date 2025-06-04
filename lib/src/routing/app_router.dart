import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ref tanımı için eklendi
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // User tipi için eklendi
import 'package:stay_fit/src/features/auth/application/auth_providers.dart'; // Auth provider'ları import et
import 'package:stay_fit/src/features/auth/presentation/login_page.dart';
import 'package:stay_fit/src/features/auth/presentation/register_page.dart';
import 'package:stay_fit/src/features/chatbot/presentation/chatbot_page.dart';
import 'package:stay_fit/src/features/calculator/presentation/calculator_page.dart';
import 'package:stay_fit/src/features/home/presentation/home_page.dart';
import 'package:stay_fit/src/features/splash/presentation/splash_page.dart';
import 'package:stay_fit/src/features/workout_tracker/presentation/add_edit_workout_log_page.dart';
import 'package:stay_fit/src/features/workout_tracker/presentation/workout_tracker_page.dart';
import 'package:stay_fit/src/routing/scaffold_with_nested_navigation.dart';
// import 'package:stay_fit/src/routing/stream_listenable_extension.dart'; // Oluşturduğumuz extension'ı import et - Artık kullanılmıyor

part 'app_router.g.dart';

// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');
final _shellNavigatorDKey = GlobalKey<NavigatorState>(debugLabel: 'shellD');

enum AppRoute {
  splash,
  login, // Yeni rota
  register, // Yeni rota
  home,
  workout,
  addExercise, // Yeni rota
  editExercise, // Yeni rota
  calculator,
  chatbot,
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // ValueNotifier'ı oluştur ve authStateChangesProvider'ı dinle
  // Initial value must be provided, so we watch it once here.
  // Note: This means goRouter provider might rebuild if authStateChangesProvider emits synchronously
  // during the first build, which is generally fine.
  final initialAuthAsyncValue = ref.watch(authStateChangesProvider);
  final authStateNotifier = ValueNotifier<AsyncValue<User?>>(initialAuthAsyncValue);

  ref.listen<AsyncValue<User?>>(authStateChangesProvider, (previous, next) {
    authStateNotifier.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: false,
    refreshListenable: authStateNotifier, // ValueNotifier'ı refreshListenable olarak kullan
    redirect: (BuildContext context, GoRouterState state) {
      final String currentRoute = state.uri.toString();
      // authStateNotifier.value yerine ref.watch(authStateChangesProvider) kullanarak
      // redirect her çalıştığında en güncel auth durumunu almasını sağlıyoruz.
      final AsyncValue<User?> authStateAsyncValue = ref.watch(authStateChangesProvider);
      final User? user = authStateAsyncValue.asData?.value;
      final bool isAuthenticated = user != null;
      // isLoadingAuth, authStateChangesProvider'ın hala ilk değerini (veya bir ara yükleme durumunu)
      // döndürüp döndürmediğini kontrol eder. AsyncValue.hasValue, bir değerin (null olsa bile)
      // veya bir hatanın gelip gelmediğini belirtir.
      final bool isLoadingAuth = !authStateAsyncValue.hasValue && !authStateAsyncValue.hasError;
      
      final bool isRegistering = ref.read(registrationInProgressProvider);

      // Debugging için log ekleyelim
      // print('Redirect: Current: $currentRoute, AuthLoading: $isLoadingAuth, Authenticated: $isAuthenticated, Registering: $isRegistering, AuthValue: ${authStateAsyncValue.toString()}');

      // Auth state yükleniyorsa (uygulama ilk açıldığında veya stream henüz bir değer/hata yayınlamadıysa)
      if (isLoadingAuth) {
        if (currentRoute == '/splash') {
          // print('Redirect: Staying on splash while auth loads.');
          return null; // Splash ekranında kal, yükleme bitsin
        }
        // Auth yüklenirken başka bir sayfaya gitmeye çalışılıyorsa (nadiren olmalı), splash'e yönlendir.
        // print('Redirect: Auth still loading (not on splash), redirecting to splash.');
        return '/splash';
      }

      // Kullanıcı kimliği doğrulanmamışsa (authStateChanges null veya error içeriyor)
      if (!isAuthenticated) {
        // print('Redirect: User not authenticated.');
        // Eğer zaten login veya register sayfasındaysa, orada kalmasına izin ver
        if (currentRoute == '/login' || currentRoute == '/register') {
          // print('Redirect: Staying on login/register page.');
          return null;
        }
        // Diğer tüm durumlarda (örneğin /home'a gitmeye çalışıyorsa) login sayfasına yönlendir
        // print('Redirect: Redirecting to login page.');
        return '/login';
      }

      // Kullanıcı kimliği doğrulanmışsa (authStateChanges geçerli bir User içeriyor)
      if (isAuthenticated) {
        // print('Redirect: User is authenticated.');
        
        // Eğer kayıt işlemi devam ediyorsa (registrationInProgressProvider true ise)
        // ve kullanıcı /login sayfasındaysa (RegisterPage'den yönlendirildi),
        // hiçbir şey yapma, /login sayfasında kalmasına izin ver.
        // Bu, RegisterPage'deki signOut sonrası authState'in anlık olarak null olup
        // sonra tekrar user (eğer başka bir yerden login olursa) olmasına karşı bir önlem.
        // RegisterPage'deki signOut'un authStateChangesProvider'ı güncellemesi beklenir.
        if (isRegistering && currentRoute == '/login') {
            // print('Redirect: Registration in progress and on login page. Staying.');
            return null;
        }

        // Eğer kullanıcı kimliği doğrulanmış ve splash ekranındaysa, /home'a yönlendir
        if (currentRoute == '/splash') {
          // print('Redirect: User authenticated, on splash, redirecting to home.');
          return '/home';
        }

        // Eğer kullanıcı kimliği doğrulanmış ve /login veya /register sayfasındaysa
        // (ve kayıt işlemi devam etmiyorsa - yukarıdaki blokla kontrol edildi),
        // bu, kullanıcının bu sayfalara manuel olarak gittiği veya
        // bir şekilde (örneğin tarayıcı geçmişi) geldiği anlamına gelir.
        // Bu durumda /home'a yönlendirmek mantıklıdır.
        if ((currentRoute == '/login' || currentRoute == '/register')) {
          // print('Redirect: User authenticated, on login/register (not during registration process), redirecting to home.');
          return '/home';
        }
        
        // Diğer tüm kimliği doğrulanmış durumlarda (örneğin /home, /workout vb.),
        // herhangi bir yönlendirmeye gerek yok, kullanıcı zaten gitmek istediği yerde.
      }

      // Diğer tüm durumlarda yönlendirme yapma (kullanıcı olduğu yerde kalsın)
      // print('Redirect: No redirection needed for $currentRoute.');
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoute.register.name,
        builder: (context, state) => const RegisterPage(),
      ),
      // Ana kabuk rota (BottomNavigationBar içeren)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Ana Sayfa (Tartım)
          StatefulShellBranch(
            navigatorKey: _shellNavigatorAKey,
            routes: [
              GoRoute(
                path: '/home',
                name: AppRoute.home.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomePage(),
                ),
              ),
            ],
          ),
          // Ağırlık Takip
          StatefulShellBranch(
            navigatorKey: _shellNavigatorBKey,
            routes: [
              GoRoute(
                path: '/workout',
                name: AppRoute.workout.name,
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: WorkoutTrackerPage()),
                routes: [
                  GoRoute(
                    path: 'add', // /workout/add
                    name: AppRoute.addExercise.name,
                    pageBuilder: (context, state) => MaterialPage(
                      key: state.pageKey,
                      fullscreenDialog: true,
                      child: const AddEditWorkoutLogPage(),
                    ),
                  ),
                  GoRoute(
                    path: 'edit/:exerciseId', // /workout/edit/123
                    name: AppRoute.editExercise.name,
                    pageBuilder: (context, state) {
                      return MaterialPage(
                        key: state.pageKey,
                        fullscreenDialog: true,
                        child: const AddEditWorkoutLogPage(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Hesaplayıcılar
          StatefulShellBranch(
            navigatorKey: _shellNavigatorCKey,
            routes: [
              GoRoute(
                path: '/calculator',
                name: AppRoute.calculator.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: CalculatorPage(),
                ),
              ),
            ],
          ),
          // Chatbot
          StatefulShellBranch(
            navigatorKey: _shellNavigatorDKey,
            routes: [
              GoRoute(
                path: '/chatbot',
                name: AppRoute.chatbot.name,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ChatbotPage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    // errorBuilder: (context, state) => const NotFoundScreen(), // Hata yönetimi için errorBuilder eklenebilir
  );
}
