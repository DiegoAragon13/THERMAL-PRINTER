import 'dart:typed_data';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:image/image.dart' as img;

class PrintService {

  // -------------------------------------------------------------
  // 1) TICKET DE PRUEBA
  // -------------------------------------------------------------
  static Future<List<int>> generateTestReceipt() async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Título
    bytes += generator.text(
      'TICKET DE PRUEBA',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    bytes += generator.hr();

    // Encabezado
    bytes += generator.row([
      PosColumn(
        text: 'Articulo',
        width: 7,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: 'Precio',
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);
    bytes += generator.hr();

    // Productos
    bytes += generator.row([
      PosColumn(text: 'Manzana', width: 7),
      PosColumn(
        text: '\$1.00',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Platano', width: 7),
      PosColumn(
        text: '\$0.50',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    bytes += generator.row([
      PosColumn(text: 'Naranja', width: 7),
      PosColumn(
        text: '\$0.75',
        width: 5,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);
    bytes += generator.hr();

    // Total
    bytes += generator.row([
      PosColumn(
        text: 'Total',
        width: 7,
        styles: const PosStyles(bold: true),
      ),
      PosColumn(
        text: '\$2.25',
        width: 5,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]);

    bytes += generator.feed(1);

    // Fecha
    bytes += generator.text(
      'Fecha: ${DateTime.now().toString().substring(0, 19)}',
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.feed(1);

    // Despedida
    bytes += generator.text(
      '¡Gracias por tu compra!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );

    bytes += generator.feed(1);
    bytes += generator.cut();

    return bytes;
  }

  // -------------------------------------------------------------
  // 2) TICKET CON TEXTO PERSONALIZADO
  // -------------------------------------------------------------
  static Future<List<int>> generateCustomTextReceipt(String text) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Título
    bytes += generator.text(
      'TEXTO PERSONALIZADO',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += generator.hr();

    // Imprimir texto línea por línea
    final lines = text.split('\n');

    for (var line in lines) {
      bytes += generator.text(
        line,
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    bytes += generator.feed(1);
    bytes += generator.cut();

    return bytes;
  }

  // -------------------------------------------------------------
  // 3) TICKET CON IMAGEN (RECIBE BYTES Y PROCESA)
  // -------------------------------------------------------------
  static Future<List<int>> generateImageReceipt(Uint8List imageBytes) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Decodificar
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('No se pudo procesar la imagen');
    }

    // Redimensionar a ancho óptimo para 58mm (más pequeño)
    // 58mm ≈ 384 pixeles, pero usamos menos para ahorrar papel
    const int targetWidth = 300; // Reducido de 384 a 300

    if (image.width > targetWidth) {
      image = img.copyResize(image, width: targetWidth);
    }

    // Convertir a escala de grises
    image = img.grayscale(image);

    // NO imprimimos título para ahorrar espacio
    // Directamente la imagen
    bytes += generator.image(image);

    // Mínimo feed y corte
    bytes += generator.feed(1);
    bytes += generator.cut(mode: PosCutMode.partial);

    return bytes;
  }

  // -------------------------------------------------------------
  // 4) TICKET CON IMAGEN YA PROCESADA (OPTIMIZADO)
  // -------------------------------------------------------------
  static Future<List<int>> generateImageReceiptFromProcessed(
      img.Image processedImage,) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Redimensionar si es necesario a un ancho más pequeño
    // Para ahorrar papel en impresoras de 58mm
    const int maxWidth = 300; // Ancho óptimo para 58mm

    img.Image finalImage = processedImage;

    if (finalImage.width > maxWidth) {
      finalImage = img.copyResize(finalImage, width: maxWidth);
    }

    // NO agregamos título ni separadores para minimizar espacio
    // Directamente imprimimos la imagen
    bytes += generator.image(finalImage);

    // Mínimo espacio antes del corte
    bytes += generator.feed(1);

    // Corte parcial (más limpio y ahorra papel)
    bytes += generator.cut(mode: PosCutMode.partial);

    return bytes;
  }

  // -------------------------------------------------------------
  // 5) NUEVA FUNCIÓN: Imagen compacta con opciones personalizadas
  // -------------------------------------------------------------
  static Future<List<int>> generateCompactImageReceipt({
    required img.Image processedImage,
    int maxWidth = 300,
    bool addMargins = false,
    int topFeed = 0,
    int bottomFeed = 1,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = [];

    // Espacio superior opcional
    if (topFeed > 0) {
      bytes += generator.feed(topFeed);
    }

    // Redimensionar imagen
    img.Image finalImage = processedImage;
    if (finalImage.width > maxWidth) {
      finalImage = img.copyResize(finalImage, width: maxWidth);
    }

    // Imprimir imagen
    bytes += generator.image(finalImage);

    // Espacio inferior
    bytes += generator.feed(bottomFeed);

    // Corte
    bytes += generator.cut(mode: PosCutMode.partial);

    return bytes;
  }
}