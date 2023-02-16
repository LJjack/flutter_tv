import 'package:flutter/material.dart';
import 'package:flutter_tv/config.dart';
import 'package:flutter_tv/payload.dart';
import 'client_server_sockets/client_server_sockets.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Server server;

  int clientPort = 0;
  bool opening = false;
  double sliderValue = 0.0;

  @override
  void initState() {
    initServer();
    super.initState();
  }

  initServer() async {
    final info = NetworkInfo();
    final wifiIP = await info.getWifiIP();
    server = Server();
    final started = await server.startServer(wifiIP ?? "172.0.0.1");
    if (!started) {
      print("initServer  出错");
      return;
    }

    // Prevents a null exception
    server.onSocketDone = (port) {
      print('portportportportportportportport');
      print(port);
    };

    server.stream.listen((event) {
      print(event);

      try {
        Payload payload = Payload.fromJson(event);
        clientPort = payload.port;
        if (payload.port != server.port) {
          if (payload.type == PlayType.video.index) {
            setState(() {
              if (payload.data?.name == kVideoNextPause) {
                opening = false;
              } else if (payload.data?.name == kVideoNextPlay) {
                opening = true;
              } else if (payload.data?.name == kVideoSlider) {
                sliderValue = payload.data?.progress ?? 0.0;
              }
            });
          }
        } else {
          print(payload.data);
        }
      } catch (e) {
        print("出错： $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '测试电视样式',
              style: Theme.of(context).textTheme.headline4,
            ),
            MaterialButton(
                onPressed: () {
                  Payload payload = Payload(
                      port: server.port,
                      message: "服务端发送消息",
                      type: PlayType.video.index,
                      data: PlayModel(
                          name: opening ? kVideoNextPlay : kVideoNextPause));

                  server.sendTo(clientPort, payload.toJson());
                  setState(() {
                    opening = !opening;
                  });
                },
                child: Icon(
                  opening ? Icons.pause : Icons.play_arrow,
                  size: 100,
                )),
            SizedBox(
                height: 20,
                child: Slider(
                    value: sliderValue, onChanged: (vv) {}, divisions: 10)),
          ],
        ),
      ),
    );
  }
}
