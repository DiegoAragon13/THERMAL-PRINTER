import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ImagePreviewScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ImagePreviewScreen({
    super.key,
    required this.imageBytes,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  img.Image? _originalImage;
  img.Image? _processedImage;

  // Configuraciones
  double _brightness = 0.0; // -100 a 100
  double _contrast = 1.0; // 0.5 a 2.0
  double _threshold = 128.0; // 0 a 255 (para blanco y negro)
  bool _useThreshold = false; // Usar umbral o escala de grises
  int _maxWidth = 300; // REDUCIDO de 384 a 300 para ahorrar papel

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() => _isProcessing = true);

    _originalImage = img.decodeImage(widget.imageBytes);
    if (_originalImage != null) {
      await _processImage();
    }

    setState(() => _isProcessing = false);
  }

  Future<void> _processImage() async {
    if (_originalImage == null) return;

    setState(() => _isProcessing = true);

    // Procesar en un compute para no bloquear la UI
    await Future.delayed(const Duration(milliseconds: 50));

    img.Image processed = img.Image.from(_originalImage!);

    // 1. Redimensionar al ancho configurado
    if (processed.width > _maxWidth) {
      processed = img.copyResize(processed, width: _maxWidth);
    }

    // 2. Ajustar brillo
    if (_brightness != 0) {
      processed = img.adjustColor(
        processed,
        brightness: _brightness / 100,
      );
    }

    // 3. Ajustar contraste
    if (_contrast != 1.0) {
      processed = img.adjustColor(
        processed,
        contrast: _contrast,
      );
    }

    // 4. Convertir a escala de grises
    processed = img.grayscale(processed);

    // 5. Aplicar umbral (blanco y negro) si está activado
    if (_useThreshold) {
      for (int y = 0; y < processed.height; y++) {
        for (int x = 0; x < processed.width; x++) {
          final pixel = processed.getPixel(x, y);
          final gray = pixel.r.toInt();
          final newColor = gray > _threshold ? 255 : 0;
          processed.setPixelRgba(x, y, newColor, newColor, newColor, 255);
        }
      }
    }

    setState(() {
      _processedImage = processed;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustar Imagen'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _processedImage == null
                ? null
                : () {
              Navigator.pop(context, _processedImage);
            },
            tooltip: 'Confirmar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview de la imagen
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade200,
              child: Center(
                child: _isProcessing
                    ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Procesando imagen...'),
                  ],
                )
                    : _processedImage == null
                    ? const Text('Error al cargar imagen')
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mostrar dimensiones
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_processedImage!.width} x ${_processedImage!.height} px',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Imagen con scroll
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Image.memory(
                            Uint8List.fromList(
                              img.encodePng(_processedImage!),
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Controles
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView(
                children: [
                  // NUEVO: Control de ancho
                  _buildSlider(
                    label: 'Ancho de impresión',
                    icon: Icons.straighten,
                    value: _maxWidth.toDouble(),
                    min: 200,
                    max: 384,
                    divisions: 23,
                    onChanged: (value) {
                      setState(() => _maxWidth = value.toInt());
                      _processImage();
                    },
                    valueLabel: '${_maxWidth}px',
                    subtitle: 'Menor = ahorra más papel',
                  ),

                  const Divider(),

                  // Modo blanco y negro
                  SwitchListTile(
                    title: const Text(
                      'Blanco y Negro Puro',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Mejor para dibujos y texto. Desactivar para fotos',
                    ),
                    value: _useThreshold,
                    onChanged: (value) {
                      setState(() => _useThreshold = value);
                      _processImage();
                    },
                  ),

                  const Divider(),

                  // Brillo
                  _buildSlider(
                    label: 'Brillo',
                    icon: Icons.brightness_6,
                    value: _brightness,
                    min: -100,
                    max: 100,
                    divisions: 40,
                    onChanged: (value) {
                      setState(() => _brightness = value);
                      _processImage();
                    },
                    valueLabel: _brightness > 0 ? '+${_brightness.toInt()}' : '${_brightness.toInt()}',
                  ),

                  // Contraste
                  _buildSlider(
                    label: 'Contraste',
                    icon: Icons.contrast,
                    value: _contrast,
                    min: 0.5,
                    max: 2.0,
                    divisions: 30,
                    onChanged: (value) {
                      setState(() => _contrast = value);
                      _processImage();
                    },
                    valueLabel: _contrast.toStringAsFixed(2),
                  ),

                  // Umbral (solo si está en modo blanco y negro)
                  if (_useThreshold)
                    _buildSlider(
                      label: 'Umbral',
                      icon: Icons.tune,
                      value: _threshold,
                      min: 0,
                      max: 255,
                      divisions: 51,
                      onChanged: (value) {
                        setState(() => _threshold = value);
                        _processImage();
                      },
                      valueLabel: _threshold.toInt().toString(),
                      subtitle: 'Valores más altos = más blanco',
                    ),

                  const SizedBox(height: 8),

                  // Botones de reset y ayuda
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _brightness = 0.0;
                              _contrast = 1.0;
                              _threshold = 128.0;
                              _useThreshold = false;
                              _maxWidth = 300;
                            });
                            _processImage();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Restablecer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _showHelp,
                          icon: const Icon(Icons.help_outline),
                          label: const Text('Ayuda'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required String valueLabel,
    String? subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange),
            SizedBox(width: 8),
            Text('Consejos'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '💾 Ahorrar papel:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Reduce el "Ancho de impresión"'),
              Text('• 250-300px es ideal para la mayoría'),
              Text('• Menos ancho = menos papel usado'),
              SizedBox(height: 16),
              Text(
                '📸 Para fotos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Desactiva "Blanco y Negro Puro"'),
              Text('• Aumenta el brillo (+20 a +40)'),
              Text('• Aumenta el contraste (1.3 a 1.5)'),
              SizedBox(height: 16),
              Text(
                '✏️ Para dibujos/texto:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Activa "Blanco y Negro Puro"'),
              Text('• Ajusta el umbral (100-150)'),
              Text('• Aumenta ligeramente el contraste'),
              SizedBox(height: 16),
              Text(
                '💡 Problemas comunes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Muy oscura: Aumenta brillo y umbral'),
              Text('• Muy clara: Disminuye brillo y umbral'),
              Text('• Poco definida: Aumenta contraste'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}