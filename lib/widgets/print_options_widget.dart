import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../services/print_service.dart';
import '../screens/image_preview_screen.dart';

class PrintOptionsWidget extends StatelessWidget {
  final Printer printer;
  final FlutterThermalPrinter flutterThermalPrinterPlugin;

  const PrintOptionsWidget({
    super.key,
    required this.printer,
    required this.flutterThermalPrinterPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildOptionCard(
          context,
          icon: Icons.text_fields,
          title: 'Imprimir Ticket de Prueba',
          subtitle: 'Ticket con productos de ejemplo',
          color: Colors.blue,
          onTap: () => _printTestTicket(context),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          context,
          icon: Icons.edit,
          title: 'Imprimir Texto Personalizado',
          subtitle: 'Escribe el texto que quieras imprimir',
          color: Colors.purple,
          onTap: () => _showCustomTextDialog(context),
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          context,
          icon: Icons.image,
          title: 'Imprimir Imagen',
          subtitle: 'Selecciona y ajusta una imagen de la galería',
          color: Colors.orange,
          onTap: () => _printImage(context),
        ),
      ],
    );
  }

  Widget _buildOptionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // Imprimir ticket de prueba
  void _printTestTicket(BuildContext context) async {
    try {
      _showLoadingDialog(context, 'Imprimiendo ticket...');

      final bytes = await PrintService.generateTestReceipt();
      await flutterThermalPrinterPlugin.printData(
        printer,
        bytes,
        longData: true,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket impreso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Mostrar diálogo para texto personalizado
  void _showCustomTextDialog(BuildContext context) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Texto Personalizado'),
        content: TextField(
          controller: textController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Escribe el texto a imprimir...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _printCustomText(context, textController.text);
            },
            child: const Text('Imprimir'),
          ),
        ],
      ),
    );
  }

  // Imprimir texto personalizado
  void _printCustomText(BuildContext context, String text) async {
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe algo primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      _showLoadingDialog(context, 'Imprimiendo texto...');

      final bytes = await PrintService.generateCustomTextReceipt(text);
      await flutterThermalPrinterPlugin.printData(
        printer,
        bytes,
        longData: true,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Texto impreso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Imprimir imagen de galería con previsualización
  void _printImage(BuildContext context) async {
    try {
      // 1. Seleccionar imagen
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      // 2. Leer los bytes de la imagen
      final bytes = await image.readAsBytes();

      // 3. Navegar a la pantalla de previsualización
      if (context.mounted) {
        final img.Image? processedImage = await Navigator.push<img.Image>(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(imageBytes: bytes),
          ),
        );

        // 4. Si el usuario confirmó (no canceló), imprimir
        if (processedImage != null && context.mounted) {
          _showLoadingDialog(context, 'Imprimiendo imagen...');

          final receiptBytes = await PrintService.generateImageReceiptFromProcessed(
            processedImage,
          );

          await flutterThermalPrinterPlugin.printData(
            printer,
            receiptBytes,
            longData: true,
          );

          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Imagen impresa exitosamente'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Cerrar el diálogo de loading si está abierto
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al imprimir: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );
  }
}