import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance =
  ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();

  late final Stream<bool> onConnectivityChanged = _connectivity
      .onConnectivityChanged
      .map((results) => _tieneConexion(results))
      .distinct()
      .asBroadcastStream();

  Future<bool> tieneConexion() async {
    final results = await _connectivity.checkConnectivity();
    return _tieneConexion(results);
  }

  bool _tieneConexion(List<ConnectivityResult> results) {
    return results.any((r) =>
    r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
  }
}