import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';

class PrinterSelectorWidget extends StatelessWidget {
  final List<Printer> printers;
  final bool isScanning;
  final Printer? selectedPrinter;
  final VoidCallback onScan;
  final VoidCallback onStop;
  final Function(Printer?) onPrinterSelected;
  final FlutterThermalPrinter flutterThermalPrinterPlugin;

  const PrinterSelectorWidget({
    super.key,
    required this.printers,
    required this.isScanning,
    required this.selectedPrinter,
    required this.onScan,
    required this.onStop,
    required this.onPrinterSelected,
    required this.flutterThermalPrinterPlugin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isScanning ? null : onScan,
                  icon: isScanning
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.search),
                  label: Text(isScanning ? 'Buscando...' : 'Buscar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isScanning ? onStop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (printers.isEmpty)
            const Text(
              'No se encontraron impresoras',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            )
          else
            DropdownButton<String>(
              isExpanded: true,
              value: selectedPrinter?.address,
              hint: const Text('Selecciona una impresora'),
              items: printers.map((printer) {
                final isConnected = printer.isConnected ?? false;
                return DropdownMenuItem<String>(
                  value: printer.address,
                  child: Row(
                    children: [
                      Icon(
                        Icons.bluetooth,
                        color: isConnected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(printer.name ?? 'Sin nombre'),
                      ),
                      if (isConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Conectada',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (address) async {
                if (address != null) {
                  final printer = printers.firstWhere(
                        (p) => p.address == address,
                  );
                  try {
                    await flutterThermalPrinterPlugin.connect(printer);
                    onPrinterSelected(printer);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Conectada'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  } catch (e) {
                    log('Error conectando: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}