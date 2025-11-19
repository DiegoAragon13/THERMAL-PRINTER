# Flutter Thermal Printer

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Bluetooth](https://img.shields.io/badge/Bluetooth-ESC%2FPOS-0082FC?style=for-the-badge&logo=bluetooth&logoColor=white)](https://en.wikipedia.org/wiki/ESC/P)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

**Professional thermal printing solution with advanced image processing capabilities**

A Flutter-based mobile application designed to optimize thermal printing through Bluetooth connectivity, featuring real-time image adjustment and paper-saving algorithms.

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [Hardware](#-Hardware) • [Documentation](#-documentation)



I have another project called "combi&fish" where it's used more extensively in a Java application; you can also find it on my GitHub profile :)
</div>

---

## 📋 Project Overview

Flutter Thermal Printer is a comprehensive mobile solution for ESC/POS thermal printer management. The application addresses common challenges in thermal printing, particularly image quality optimization and resource efficiency through intelligent preprocessing algorithms.

**Key Capabilities:**
- Real-time image preview and adjustment
- Advanced image processing (brightness, contrast, threshold control)
- Adaptive width scaling for paper conservation
- Bluetooth device discovery and management
- ESC/POS command generation

---

## ✨ Features

### Bluetooth Connectivity
- **Automatic Device Discovery** - Scans and lists available thermal printers
- **Connection Management** - Persistent connection handling with status indicators
- **Multi-device Support** - Compatible with ESC/POS protocol printers

### Printing Capabilities
| Feature | Description |
|---------|-------------|
| Test Receipts | Pre-formatted sample tickets for connectivity verification |
| Custom Text | Dynamic text input with configurable formatting |
| Image Printing | Gallery integration with preprocessing pipeline |

### Image Processing Engine
The application includes a sophisticated image optimization system:

- **Brightness Adjustment** - Range: -100 to +100 for exposure correction
- **Contrast Enhancement** - Multiplier: 0.5x to 2.0x for detail optimization
- **Grayscale Conversion** - Smooth tonal reproduction for photographs
- **Binary Threshold** - Pure black & white mode for text and line art
- **Adaptive Scaling** - Width adjustment: 200-384px for paper efficiency
- **Real-time Preview** - Live visualization of all adjustments

---

## 🖨️ Hardware

### Tested Configuration

**Primary Test Device:**  
58mm Bluetooth Thermal Printer (ESC/POS)  
📦 [Product Reference](https://articulo.mercadolibre.com.mx/MLM-1822586718-bluetooth-impresora-termica-inalambrica-ticket-58mm-portatil-_JM#origin%3Dshare%26sid%3Dshare)

**Technical Specifications:**
- Paper Width: 58mm (384px native resolution)
- Connectivity: Bluetooth 2.0+ / BLE
- Protocol: ESC/POS command set
- Power: Rechargeable battery
- Portability: Compact form factor

### Compatibility Notes
This application is compatible with any thermal printer meeting the following criteria:
- 58mm paper width
- Bluetooth connectivity
- ESC/POS protocol support
- Standard receipt printing capabilities

---

## 🚀 Installation

### System Requirements
- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 3.0 or higher
- **Target Platform**: Android 5.0+ (API level 21+)
- **Hardware**: Bluetooth-enabled Android device
- **Printer**: 58mm ESC/POS thermal printer

### Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/flutter-thermal-printer.git
   cd flutter-thermal-printer
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Permissions**
   
   Ensure the following permissions are granted in `AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   ```

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 📱 Usage

### Connection Workflow

1. **Device Discovery**
   - Navigate to the main screen
   - Tap "Buscar" to initiate Bluetooth scan
   - Wait for available printers to appear in the dropdown

2. **Printer Selection**
   - Select your printer from the device list
   - Connection status indicated by colored badge:
     - 🟢 Green: Successfully connected
     - ⚫ Gray: Disconnected

### Printing Operations

#### Test Receipt
Generates a pre-formatted sample receipt with:
- Header and branding
- Product list with pricing
- Total calculation
- Timestamp
- Footer message

**Use Case:** Initial connectivity testing and formatting verification

#### Custom Text Printing
Features:
- Multi-line text input
- Automatic text wrapping
- Consistent formatting

**Use Case:** Quick text-based prints (notes, labels, simple tickets)

#### Image Printing Workflow

1. **Image Selection**
   - Tap "Imprimir Imagen"
   - Select image from device gallery
   - Automatic preprocessing initialization

2. **Image Adjustment Interface**
   
   | Parameter | Range | Purpose | Recommended Use |
   |-----------|-------|---------|-----------------|
   | Width | 200-384px | Paper consumption | Start at 250-300px |
   | Brightness | -100 to +100 | Exposure correction | ±20-40 for most images |
   | Contrast | 0.5-2.0x | Detail enhancement | 1.2-1.5 for definition |
   | Threshold | 0-255 | B&W cutoff point | 100-150 for line art |
   | B&W Mode | Toggle | Processing method | ON for text, OFF for photos |

3. **Print Execution**
   - Review preview
   - Tap checkmark (✓) to confirm
   - Monitor print progress

---

## 🎯 Optimization Guidelines

### Image Type Presets

#### Photography
```yaml
Processing Mode: Grayscale
Brightness: +20 to +40
Contrast: 1.3 to 1.5
Width: 280-300px
Threshold: N/A
```
**Rationale:** Photographs require tonal gradation for proper rendering

#### Line Art / Text Documents
```yaml
Processing Mode: Pure B&W
Brightness: 0 to +10
Contrast: 1.2 to 1.4
Width: 250-280px
Threshold: 100-150
```
**Rationale:** Sharp edges benefit from binary processing

#### QR Codes / Barcodes
```yaml
Processing Mode: Pure B&W
Brightness: 0
Contrast: 1.5
Width: 200-250px
Threshold: 128
```
**Rationale:** Maximum contrast ensures scanner readability

### Paper Conservation Strategies

| Width Setting | Paper Savings | Quality Impact | Recommended For |
|---------------|---------------|----------------|-----------------|
| 200px | ~48% reduction | Moderate | Text, QR codes |
| 250px | ~35% reduction | Minimal | General use |
| 300px | ~22% reduction | Negligible | Detailed images |
| 384px | Baseline | None | Maximum quality |

**Note:** Optimal width depends on content complexity and viewing distance

---

## 🛠️ Technology Stack

### Core Framework
| Component | Version | Purpose |
|-----------|---------|---------|
| Flutter | 3.0+ | Cross-platform UI framework |
| Dart | 3.0+ | Primary programming language |

### Key Dependencies
| Package | Function |
|---------|----------|
| `flutter_thermal_printer` | ESC/POS command generation and Bluetooth communication |
| `image` | Image processing algorithms (resize, grayscale, contrast) |
| `image_picker` | Device gallery integration |

### Architecture
- **Pattern:** Widget-based component architecture
- **State Management:** StatefulWidget with local state
- **Communication:** Bluetooth Serial via flutter_thermal_printer
- **Image Pipeline:** Sequential processing with preview rendering

---

## 🔧 Troubleshooting

### Connection Issues

**Symptom:** Printer not discovered during scan

**Solutions:**
1. Verify Bluetooth is enabled on mobile device
2. Ensure printer is powered on and in pairing mode
3. Check printer is not connected to another device
4. Clear Bluetooth cache: Settings → Apps → Bluetooth → Clear Cache
5. Restart both devices

**Symptom:** Connection drops during printing

**Solutions:**
1. Reduce distance between devices (< 5 meters)
2. Check battery levels on both devices
3. Disable battery optimization for the app
4. Update printer firmware if available

### Print Quality Issues

**Problem:** Images appear too dark
- Increase brightness (+30 to +50)
- Reduce contrast (0.8 to 1.0)
- Lower threshold if using B&W mode (80-100)

**Problem:** Images appear too light
- Decrease brightness (-20 to -40)
- Increase contrast (1.4 to 1.8)
- Raise threshold if using B&W mode (150-180)

**Problem:** Loss of detail
- Increase contrast (1.5 to 2.0)
- Ensure sufficient width (300px+)
- Verify original image resolution

**Problem:** Excessive paper usage
- Reduce width to 250-280px
- Crop unnecessary margins before importing
- Adjust printer's line spacing settings

### Application Errors

**Error:** Gallery access denied
- Grant storage/media permissions in system settings
- Reinstall application if permissions corrupted

**Error:** Out of memory during processing
- Reduce image width before processing
- Close background applications
- Clear app cache

---

## 📚 Documentation

### Project Structure
```plaintext
lib/
├── services/
│   └── print_service.dart       # ESC/POS generation logic
├── screens/
│   └── image_preview_screen.dart # Image adjustment interface
├── widgets/
│   ├── printer_selector_widget.dart
│   └── print_options_widget.dart
└── main.dart                     # Application entry point
```

### Key Classes

**PrintService**
- `generateTestReceipt()` - Creates formatted test ticket
- `generateCustomTextReceipt(String)` - Text-to-receipt conversion
- `generateImageReceiptFromProcessed(Image)` - Image-to-ESC/POS pipeline

**ImagePreviewScreen**
- Real-time image processing
- User control interface
- Preview rendering

---

## 🤝 Contributing

Contributions are welcome. Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes with descriptive messages
4. Push to your fork
5. Submit a pull request with detailed description

### Code Standards
- Follow Dart style guide
- Document public APIs
- Include unit tests for new features
- Maintain backwards compatibility

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for full terms.

```


</div>
