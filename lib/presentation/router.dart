import 'package:go_router/go_router.dart';
import 'pages/home_page.dart';
import 'pages/setting_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      name: "home",
      path: "/",
      builder: (context, state) {
        return const HomePage();
      },
    ),
    GoRoute(
      name: "setting",
      path: "/setting",
      builder: (context, state) {
        return const SettingPage();
      },
    ),
  ],
);
