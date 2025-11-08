import 'package:get/get.dart';

class BottomBarController extends GetxController {
  final RxBool hasUnread = true.obs; // start with unread visible

  void markRead() => hasUnread.value = false;
  void showUnread() => hasUnread.value = true;
}
