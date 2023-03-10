import 'package:flutter/material.dart';

import 'client_server_sockets/client_server_sockets.dart';
import 'package:network_info_plus/network_info_plus.dart';

mixin ServerBaseMixin<T extends StatefulWidget> on State<T> {
  late Server server;

  int clientPort = 0;

  Future setupServer() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    print("当前IP地址： $wifiIP");
    server = Server();
    final started = await server.startServer(wifiIP ?? "172.0.0.1");
    if (!started) {
      print("initServer  出错");
      return;
    }
  }
}
