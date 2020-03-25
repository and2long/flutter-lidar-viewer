import 'dart:convert';
import 'dart:io';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:livox/lidar_data_model.dart';
import 'package:livox/lidar_scanner_widget.dart';
import 'package:livox/lidar_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Livox',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Livox'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  Socket _socket; //socket对象
  bool _receiving = false; //是否正在接受数据。
  LidarData _data = LidarData.init();
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _controller.addStatusListener((state) {
      if (state == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(top: 30, bottom: 20),
                child: Stack(children: <Widget>[
                  LidarWidget(data: _data),
                  Offstage(
                    offstage: !_receiving,
                    child: RotationTransition(
                      child: LidarScanner(),
                      turns: _controller,
                    ),
                  ),
                ])),
            Container(
              margin: EdgeInsets.all(20),
              child: Text(
                  '位置：${double.parse(_data.horizontalAngle) * Math.pi ~/ 180}'),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Text('距离：${double.parse(_data.radius).toInt()}mm'),
            ),
          ]),
      floatingActionButton: FloatingActionButton(
        child: Icon(_receiving ? Icons.pause : Icons.play_arrow),
        onPressed: () {
          if (_receiving) {
            _stop();
          } else {
            _start();
          }
        },
      ),
    );
  }

  /// 开始接受数据
  void _start() {
    _socket?.close();
    _controller.forward();
    _connect();
  }

  /// 停止接受数据
  void _stop() {
    _socket?.close();
    print('断开连接，停止接受数据。');
    _receiving = false;
    _controller.reset();
    setState(() {});
  }

  /// 连接服务器
  void _connect() async {
    Socket.connect('118.89.80.49', 8888).then((Socket socket) {
      _socket = socket;
      print('连接成功，开始接受数据。');
      _socket?.add(utf8.encode('youteacher_lidar'));
      setState(() {
        _receiving = true;
      });
      _socket?.listen((var data) {
        // {"radius": "4434.523649728345", "elevation_angle": "-1.9384284188413052", "horizontal_angle": "-23.962488974578186"}
        print('data from server ${utf8.decode(data)}');
        setState(() {
          _data = LidarData.fromJson(json.decode(utf8.decode(data)));
        });
      });
    }).catchError((err) {
      print(err);
      showDialog(
          context: context,
          barrierDismissible: false,
          child: AlertDialog(content: Text(err.toString()), actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () => Navigator.pop(context),
            )
          ]));
    });
  }

  @override
  void dispose() {
    _stop();
    _controller.dispose();
    super.dispose();
  }
}
