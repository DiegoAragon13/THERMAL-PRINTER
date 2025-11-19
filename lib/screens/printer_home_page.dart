import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../widgets/printer_selector_widget.dart';
import '../widgets/print_options_widget.dart';

class PrinterHomePage extends StatefulWidget {
  const PrinterHomePage({super.key});

  @override
  State<PrinterHomePage> createState() => _PrinterHomePageState();
}

class _PrinterHomePageState extends State<PrinterHomePage> {
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
  List<Printer> printers = [];
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;
  bool _isScanning = false;
  Printer? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _requestBluetoothPermissions();
    });
  }

  Future<void> _requestBluetoothPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.location,
      ].request();

      bool allGranted = statuses.values.every((status) => status.isGranted);

      if (!allGranted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Se necesitan permisos de Bluetooth'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Configurar',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      } else {
        startScan();
      }
    } catch (e) {
      log('Error permisos: $e');
    }
  }

  void startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      printers.clear();
    });

    try {
      _devicesStreamSubscription?.cancel();
      await _flutterThermalPrinterPlugin.getPrinters(
        connectionTypes: [ConnectionType.BLE],
      );

      _devicesStreamSubscription = _flutterThermalPrinterPlugin.devicesStream
          .listen((List<Printer> event) {
        setState(() {
          // Filtrar impresoras sin nombre
          List<Printer> filteredPrinters = event
              .where((element) => element.name != null && element.name != '')
              .toList();

          // Eliminar duplicados basándose en la dirección
          final Map<String, Printer> uniquePrinters = {};
          for (var printer in filteredPrinters) {
            if (printer.address != null) {
              uniquePrinters[printer.address!] = printer;
            }
          }

          printers = uniquePrinters.values.toList();

          // Si la impresora seleccionada ya no está en la lista, actualizarla
          if (_selectedPrinter != null) {
            final updatedPrinter = printers.firstWhere(
                  (p) => p.address == _selectedPrinter!.address,
              orElse: () => _selectedPrinter!,
            );
            _selectedPrinter = updatedPrinter;
          }
        });
      });
    } catch (e) {
      log('Error escaneo: $e');
    }
  }

  void stopScan() {
    _flutterThermalPrinterPlugin.stopScan();
    setState(() => _isScanning = false);
  }

  @override
  void dispose() {
    _devicesStreamSubscription?.cancel();
    stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impresora Bluetooth'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Widget de selección de impresora
          PrinterSelectorWidget(
            printers: printers,
            isScanning: _isScanning,
            selectedPrinter: _selectedPrinter,
            onScan: startScan,
            onStop: stopScan,
            onPrinterSelected: (printer) {
              setState(() => _selectedPrinter = printer);
            },
            flutterThermalPrinterPlugin: _flutterThermalPrinterPlugin,
          ),

          const Divider(height: 1, thickness: 2),

          // Opciones de impresión
          Expanded(
            child: _selectedPrinter == null
                ? const Center(
              child: Text(
                'Selecciona una impresora primero',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : PrintOptionsWidget(
              printer: _selectedPrinter!,
              flutterThermalPrinterPlugin: _flutterThermalPrinterPlugin,
            ),
          ),
        ],
      ),
    );
  }
}