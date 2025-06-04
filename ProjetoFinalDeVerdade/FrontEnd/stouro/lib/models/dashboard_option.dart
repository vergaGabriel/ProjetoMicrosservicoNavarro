import 'package:flutter/material.dart';

class DashboardOption {
  final String label;
  final IconData icon;
  final String? route;
  final VoidCallback? action;

  DashboardOption({
    required this.label,
    required this.icon,
    this.route,
    this.action,
  });
}
