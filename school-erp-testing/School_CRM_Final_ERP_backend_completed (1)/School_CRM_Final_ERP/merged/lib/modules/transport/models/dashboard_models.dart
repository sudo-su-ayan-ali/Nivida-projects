import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;
  final int? badge;
  const NavItem({required this.icon, required this.label, this.badge});
}

class NavGroup {
  final String title;
  final List<NavItem> items;
  const NavGroup({required this.title, required this.items});
}

class KpiCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String trend;
  final bool trendUp;
  final String actionLabel;
  final List<double> sparkline;

  const KpiCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.trend,
    required this.trendUp,
    required this.actionLabel,
    required this.sparkline,
  });
}

class TripRow {
  final String route;
  final String driver;
  final String vehicle;
  final String tripType;
  final String time;
  final String status;
  const TripRow({
    required this.route,
    required this.driver,
    required this.vehicle,
    required this.tripType,
    required this.time,
    required this.status,
  });
}

class RouteSummaryRow {
  final String route;
  final String driver;
  final String vehicle;
  final int students;
  final String status;
  final String trips;
  final int attendancePresent;
  final int attendanceTotal;
  final double performance;
  const RouteSummaryRow({
    required this.route,
    required this.driver,
    required this.vehicle,
    required this.students,
    required this.status,
    required this.trips,
    required this.attendancePresent,
    required this.attendanceTotal,
    required this.performance,
  });
}

class FeeCollectionRow {
  final String date;
  final String amount;
  final int transactions;
  final String mode;
  const FeeCollectionRow({
    required this.date,
    required this.amount,
    required this.transactions,
    required this.mode,
  });
}

class AlertData {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final Color bgColor;
  const AlertData({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

class QuickActionData {
  final String label;
  final IconData icon;
  final Color color;
  const QuickActionData({required this.label, required this.icon, required this.color});
}

class NotificationData {
  final String? id;          // <-- naya, Supabase row id (mock rows ke liye null)
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  bool read;
  NotificationData({
    this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    this.read = false,
  });
}

class MessageData {
  final String? id;          // <-- naya
  final String sender;
  final String preview;
  final String time;
  final String initials;
  final Color color;
  bool read;
  MessageData({
    this.id,
    required this.sender,
    required this.preview,
    required this.time,
    required this.initials,
    required this.color,
    this.read = false,
  });
}