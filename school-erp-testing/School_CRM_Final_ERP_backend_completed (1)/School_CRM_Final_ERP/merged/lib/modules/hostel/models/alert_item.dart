import "package:flutter/material.dart";

class AlertItem {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String time;

  const AlertItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.time,
  });
}
