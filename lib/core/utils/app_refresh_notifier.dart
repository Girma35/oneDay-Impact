import 'package:flutter/foundation.dart';

/// A simple notifier that signals when data should be refreshed across pages.
///
/// Registered as a singleton in DI. MainPage calls [refresh] whenever the
/// user switches tabs, and each page's DataLoader listens and re-fetches
/// its Supabase data.
class AppRefreshNotifier extends ChangeNotifier {
  int _refreshCount = 0;

  /// The current refresh generation counter.
  int get refreshCount => _refreshCount;

  /// Call this to signal all listeners that data should be re-fetched.
  void refresh() {
    _refreshCount++;
    notifyListeners();
  }
}
