import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hiralfutterpractical/routes/app_pages.dart';
import 'package:hiralfutterpractical/routes/app_routes.dart';
import 'package:hiralfutterpractical/core/app_theme.dart';
import 'package:hiralfutterpractical/core/size_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.dark,
      builder: (context, child) {
        // Initialize responsive helpers once per build tree
        Screen.init(context);
        return child!;
      },
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}

