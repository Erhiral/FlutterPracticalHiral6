import 'package:flutter/material.dart';
import 'package:hiralfutterpractical/core/app_colors.dart';
import 'package:hiralfutterpractical/core/size_utils.dart';

class FabButton extends StatelessWidget {
  const FabButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Screen.wp(2.8)),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Colors.pinkAccent, Colors.amber]),
      ),
      child: Icon(Icons.add, color: AppColors.textPrimary, size: Screen.sp(20)),
    );
  }
}
