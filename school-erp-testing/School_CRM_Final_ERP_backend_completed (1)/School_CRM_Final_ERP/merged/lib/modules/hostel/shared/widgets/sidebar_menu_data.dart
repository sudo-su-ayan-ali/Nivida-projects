import 'package:flutter/material.dart';

class SidebarChild {
  final String label;
  final String route;
  const SidebarChild(this.label, this.route);
}

class SidebarItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<SidebarChild> children;
  const SidebarItem(this.label, this.icon, {this.route, this.children = const []});
}

/// Full sidebar menu tree — matches the spec's required navigation exactly.
final List<SidebarItem> sidebarMenu = [
  const SidebarItem('Dashboard', Icons.grid_view_rounded, route: '/dashboard'),
  const SidebarItem('Student Management', Icons.groups_rounded, children: [
    SidebarChild('All Students', '/students'),
    SidebarChild('Add Student', '/students/add'),
    SidebarChild('Student Profiles', '/students'),
    SidebarChild('Student Documents', '/students'),
  ]),
  const SidebarItem('Hostel Management', Icons.apartment_rounded, children: [
    SidebarChild('Blocks', '/hostel/blocks'),
    SidebarChild('Floors', '/hostel/blocks'),
    SidebarChild('Rooms', '/hostel/rooms'),
    SidebarChild('Beds', '/hostel/rooms'),
    SidebarChild('Room Allocation', '/hostel/rooms'),
    SidebarChild('Vacant Beds', '/hostel/rooms'),
  ]),
  const SidebarItem('Attendance', Icons.fact_check_rounded, children: [
    SidebarChild('Daily Attendance', '/attendance'),
    SidebarChild('Attendance History', '/attendance'),
    SidebarChild('Attendance Reports', '/reports'),
  ]),
  const SidebarItem('Leave Management', Icons.event_note_rounded, children: [
    SidebarChild('Leave Requests', '/leaves'),
    SidebarChild('Pending Requests', '/leaves'),
    SidebarChild('Approved Leaves', '/leaves'),
    SidebarChild('Rejected Leaves', '/leaves'),
  ]),
  const SidebarItem('Fees & Payments', Icons.account_balance_wallet_rounded, children: [
    SidebarChild('Fee Dashboard', '/fees'),
    SidebarChild('Fee Structure', '/fees'),
    SidebarChild('Pending Fees', '/fees'),
    SidebarChild('Payment History', '/fees'),
    SidebarChild('Receipts', '/fees'),
  ]),
  const SidebarItem('Mess & Food', Icons.restaurant_rounded, children: [
    SidebarChild("Today's Menu", '/mess'),
    SidebarChild('Weekly Menu', '/mess'),
    SidebarChild('Meal Attendance', '/mess'),
    SidebarChild('Mess Expenses', '/mess'),
    SidebarChild('Food Inventory', '/mess'),
  ]),
  const SidebarItem('Complaints', Icons.report_problem_rounded, children: [
    SidebarChild('All Complaints', '/complaints'),
    SidebarChild('Pending Complaints', '/complaints'),
    SidebarChild('Resolved Complaints', '/complaints'),
  ]),
  const SidebarItem('Maintenance', Icons.build_rounded, children: [
    SidebarChild('Maintenance Requests', '/maintenance'),
    SidebarChild('Pending Maintenance', '/maintenance'),
    SidebarChild('Completed Maintenance', '/maintenance'),
    SidebarChild('Maintenance Staff', '/staff'),
  ]),
  const SidebarItem('Visitors', Icons.badge_rounded, children: [
    SidebarChild('Visitor Log', '/visitors'),
    SidebarChild("Today's Visitors", '/visitors'),
    SidebarChild('Visitor History', '/visitors'),
  ]),
  const SidebarItem('Notices', Icons.campaign_rounded, children: [
    SidebarChild('All Notices', '/notices'),
    SidebarChild('Create Notice', '/notices'),
    SidebarChild('Notice Categories', '/notices'),
  ]),
  const SidebarItem('Staff Management', Icons.badge_outlined, children: [
    SidebarChild('Staff List', '/staff'),
    SidebarChild('Add Staff', '/staff'),
    SidebarChild('Staff Roles', '/staff'),
    SidebarChild('Staff Attendance', '/staff'),
  ]),
  const SidebarItem('Reports', Icons.bar_chart_rounded, children: [
    SidebarChild('Student Reports', '/reports'),
    SidebarChild('Hostel Reports', '/reports'),
    SidebarChild('Attendance Reports', '/reports'),
    SidebarChild('Fee Reports', '/reports'),
    SidebarChild('Leave Reports', '/reports'),
    SidebarChild('Mess Reports', '/reports'),
    SidebarChild('Maintenance Reports', '/reports'),
  ]),
  const SidebarItem('Settings', Icons.settings_rounded, children: [
    SidebarChild('Hostel Settings', '/settings'),
    SidebarChild('Academic Year', '/settings'),
    SidebarChild('User Management', '/settings'),
    SidebarChild('Roles & Permissions', '/settings'),
    SidebarChild('Notifications', '/settings'),
    SidebarChild('General Settings', '/settings'),
  ]),
];
