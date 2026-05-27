import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class KameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const KameraScreen({super.key, required this.cameras});

  @override
  State<KameraScreen> createState() => _KameraScreenState();
}

class _KameraScreenState extends State<KameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _kameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initKamera(widget.cameras[_kameraIndex]);
  }

  void _initKamera(CameraDescription kamera) {
    _controller = CameraController(kamera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ambilFoto() async {
    try {
      await _initializeControllerFuture;

      final XFile foto = await _controller.takePicture();

      if (!mounted) return;

      Navigator.pop(context, foto.path);
    } catch (e) {
      debugPrint('Error mengambil foto: $e');
    }
  }

  void _gantiKamera() {
    if (widget.cameras.length < 2) return;
    setState(() {
      _kameraIndex = _kameraIndex == 0 ? 1 : 0;
      _initKamera(widget.cameras[_kameraIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Kamera', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Gagal membuka kamera: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return Stack(
            children: [
              CameraPreview(_controller),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: _gantiKamera,
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      GestureDetector(
                        onTap: _ambilFoto,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: Colors.white.withAlpha(76),
                          ),
                        ),
                      ),
                      const SizedBox(width: 56),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}