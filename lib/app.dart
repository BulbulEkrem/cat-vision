import 'package:flutter/material.dart';
import 'package:kedigoz/features/camera/camera_screen.dart';
import 'package:kedigoz/shared/theme/app_theme.dart';

class KediGozApp extends StatelessWidget {
  const KediGozApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KediGözü',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const CameraScreen(),
    );
  }
}
