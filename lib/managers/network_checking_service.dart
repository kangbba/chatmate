import 'package:flutter_network_connectivity/flutter_network_connectivity.dart';

class NetworkCheckingService {
  final FlutterNetworkConnectivity _flutterNetworkConnectivity =
  FlutterNetworkConnectivity(
    isContinousLookUp: true,
    lookUpDuration: const Duration(seconds: 5),
    lookUpUrl: 'example.com',
  );

  Future<bool> isInternetConnectionAvailable() async {
    try {
      final isInternetAvailable =
      await _flutterNetworkConnectivity.isInternetConnectionAvailable();
      return isInternetAvailable ?? false;
    } catch (_) {
      return false;
    }
  }

  Stream<bool> getInternetAvailabilityStream() {
    return _flutterNetworkConnectivity.getInternetAvailabilityStream();
  }

  Future<void> registerAvailabilityListener() async {
    await _flutterNetworkConnectivity.registerAvailabilityListener();
  }

  void unregisterAvailabilityListener() {
    _flutterNetworkConnectivity.unregisterAvailabilityListener();
  }
}
