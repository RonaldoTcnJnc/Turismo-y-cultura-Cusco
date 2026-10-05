import 'package:flutter/material.dart';

class GuideCategory {
  const GuideCategory(this.name, this.icon, this.imagePath);

  final String name;
  final IconData icon;
  final String imagePath;
}

class GuidePlace {
  const GuidePlace({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.tags,
  });

  final String name;
  final String category;
  final String imagePath;
  final List<String> tags;
}

class GuideSection {
  const GuideSection({
    required this.title,
    required this.subtitle,
    required this.places,
  });

  final String title;
  final String subtitle;
  final List<GuidePlace> places;
}
