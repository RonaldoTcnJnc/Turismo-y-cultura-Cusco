import 'package:flutter/material.dart';

import 'pages/cusco_guide_page.dart';
import 'theme/app_theme.dart';

class CuscoGuideApp extends StatelessWidget {
  const CuscoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cusco | Guía turística y cultural',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const CuscoGuidePage(),
    );
  }
}
