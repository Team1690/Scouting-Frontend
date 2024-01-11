import "dart:async";
import "dart:developer" as developer;
import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter/services.dart";

class ConnectivityCheck {
  Connectivity connectivity = Connectivity();
  bool isOffline = true;

  Future<bool?> getConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log("Couldn't check connectivity status", error: e);
      return null;
    }

    await updateConnectionStatus(result);
    return isOffline;
  }

  Future<void> updateConnectionStatus(final ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      isOffline = true;
    } else {
      isOffline = false;
    }
  }
}
