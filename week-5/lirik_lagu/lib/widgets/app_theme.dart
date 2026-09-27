import 'package:flutter/material.dart';

class AppTheme extends InheritedWidget {
  final Color warnaUtama;

  const AppTheme({
    super.key,
    required this.warnaUtama,
    required super.child,
  });

  static AppTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheme>()!;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return warnaUtama != oldWidget.warnaUtama;
  }
}
