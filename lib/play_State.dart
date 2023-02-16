import 'package:flutter/material.dart';

import 'client_server_sockets/client_server_sockets.dart';
import 'package:network_info_plus/network_info_plus.dart';

abstract class PlayState<T extends StatefulWidget> extends State<T> {
  late Server server;

  int clientPort = 0;
  bool opening = false;
  double sliderValue = 0.0;

  @protected
  @mustCallSuper
  @override
  void initState() {
    initServer();
    super.initState();
  }
  @protected
  @mustCallSuper
  Future initServer() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    server = Server();
    final started = await server.startServer(wifiIP ?? "172.0.0.1");
    if (!started) {
      print("initServer  出错");
      return;
    }
  }

}