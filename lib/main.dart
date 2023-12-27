// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:flutter/services.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.green, backgroundColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _status = false;
  String _text = 'Start';
  late CameraController _controller;
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    _controller = CameraController(cameras[0], ResolutionPreset.max);
    _controller.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      },
    );
    _controller.pausePreview();
  }

  void _displayText(String a) {
    setState(() {
      _text = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(0, 255, 0, 1),
      ),
      body: Stack(children: [
        Center(
          child: ElevatedButton(
            onPressed: () async {
              if (_status) {
                final file = await _controller.stopVideoRecording();
                await GallerySaver.saveVideo(file.path);
                await _controller.pausePreview();
                _displayText('Start');
                setState(() => _status = false);
              } else {
                await _controller.resumePreview();
                _displayText('Stop');
                await _controller.setFlashMode(FlashMode.off);
                await _controller.prepareForVideoRecording();
                await _controller.startVideoRecording();
                setState(() => _status = true);
              }
            },
            child: Text(
              _text,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
      ]),
    );
  }
}
