import 'package:flutter/material.dart';
import 'app_state.dart';

/// Makes a single [AppState] instance available to the whole widget tree.
/// Any descendant calls `AppScope.of(context)` to read/mutate it; because
/// this extends [InheritedNotifier], every widget that reads it is
/// automatically rebuilt whenever [AppState.notifyListeners] fires.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context — wrap the app with AppScope.');
    return scope!.notifier!;
  }
}
