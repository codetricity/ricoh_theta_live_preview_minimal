import 'package:flutter/material.dart';
import 'package:theta_client_flutter/theta_client_flutter.dart';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PreviewScreen());
  }
}

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  PreviewScreenState createState() => PreviewScreenState();
}

class PreviewScreenState extends State<PreviewScreen> {
  final _thetaClient = ThetaClientFlutter();
  bool _previewing = false;
  Uint8List? _frameData;

  @override
  void initState() {
    super.initState();
    _initializeAndStartPreview();
  }

  Future<void> _initializeAndStartPreview() async {
    try {
      // Initialize theta client
      await _thetaClient.initialize();
      _startLivePreview();
    } catch (error) {
      print('Error initializing: $error');
    }
  }

  void _startLivePreview() {
    _previewing = true;
    _thetaClient
        .getLivePreview(_frameHandler)
        .then((_) => print('Preview done'))
        .catchError((error) => print('Preview error: $error'));
  }

  bool _frameHandler(Uint8List frameData) {
    if (mounted) {
      setState(() {
        _frameData = frameData;
      });
    }
    return _previewing;
  }

  @override
  void dispose() {
    _previewing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('THETA Live Preview')),
      body: Center(
        child:
            _frameData == null
                ? const CircularProgressIndicator()
                : Image.memory(
                  _frameData!,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.black);
                  },
                ),
      ),
    );
  }
}
