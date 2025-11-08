import 'package:get/get.dart';
import 'package:hiralfutterpractical/screens/splash_screen.dart';
import 'package:hiralfutterpractical/screens/home_screen.dart';
import 'package:hiralfutterpractical/screens/profile_screen.dart';
import 'package:hiralfutterpractical/routes/app_routes.dart';
import 'package:hiralfutterpractical/screens/event_calendar_screen.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: Routes.splash, page: () => const SplashScreen()),
    GetPage(name: Routes.home, page: () => const HomeScreen()),
    GetPage(name: Routes.profile, page: () => const ProfileScreen()),
    GetPage(name: Routes.calendar, page: () => const EventCalendarScreen()),
  ];
}
