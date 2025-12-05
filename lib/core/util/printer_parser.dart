import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:browser_bridge/core/util/log.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class PrinterCommandParser {
  final Generator generator;

  PrinterCommandParser(this.generator);

  Future<List<int>> parse(String jsonStr) async {
    final data = json.decode(jsonStr);
    final cmds = data['commands'] as List;
    final List<int> bytes = [];

    bytes.addAll(generator.reset());

    for (var cmd in cmds) {
      final type = cmd['type'];

      switch (type) {
        case 'text':
          bytes.addAll(_handleText(cmd));
          break;
        case 'row':
          bytes.addAll(await _handleRow(cmd));
          break;
        case 'qrcode':
          bytes.addAll(_handleQrcode(cmd));
          break;
        case 'barcode':
          bytes.addAll(_handleBarcode(cmd));
          break;
        case 'image':
          bytes.addAll(await _handleImage(cmd));
          break;
        case 'feed':
          bytes.addAll(generator.feed(cmd['lines'] ?? 1));
          break;
        case 'divider':
          bytes.addAll(_handleDivider(cmd));
          break;
        case 'cut':
          bytes.addAll(_handleCut(cmd));
          break;
        case 'raw':
          bytes.addAll(_handleRaw(cmd));
          break;
        case 'init':
          bytes.addAll(generator.reset());
          break;
      }
    }

    return bytes;
  }

  List<int> _handleCut(Map<String, dynamic> cmd) {
    final mode = cmd['mode'] ?? 'full';
    final cutMode = _mapCutMode(mode);
    return generator.cut(mode: cutMode);
  }

  List<int> _handleDivider(Map<String, dynamic> cmd) {
    final text = cmd['text'] ?? '-';
    return generator.hr(ch: text);
  }

  // --- Handlers ---

  PosStyles _getTextStyle(Map<String, dynamic> cmd) {

    final align = _mapAlign(cmd['align']);
    final bold = cmd['bold'] ?? false;
    final reverse = cmd['reverse'] ?? false;
    final underline = cmd['underline'] ?? false;
    final italic = cmd['italic'] ?? false;
    final font = cmd['font'] ?? 'A';
    final size = double.parse("${cmd['size'] ?? 1}");
    final codeTable = cmd['codeTable'];

    return PosStyles(
      align: align,
      bold: bold,
      reverse: reverse,
      underline: underline,
      fontType: font == 'B' ? PosFontType.fontB : PosFontType.fontA,
      height: PosTextSize.custom(size),
      width: PosTextSize.custom(size),
      codeTable: codeTable,
    );
  }

  List<int> _handleText(Map<String, dynamic> cmd) {
    final text = cmd['data'] ?? '';
    final encoding = cmd['encoding'] ?? 'ascii';
    final styles = _getTextStyle(cmd);

    List<int> encoded;
    switch (encoding) {
      case 'latin1':
        encoded = latin1.encode(text);
        break;
      case 'utf8':
        encoded = utf8.encode(text);
        break;
      default:
        encoded = ascii.encode(text);
    }

    return generator.textEncoded(Uint8List.fromList(encoded), styles: styles);
  }

  Future<List<int>> _handleRow(Map<String, dynamic> cmd) async {
    final cols = cmd['columns'] as List<dynamic>;
    List<PosColumn> posCols = [];

    for (var c in cols) {
      final type = c['type'] ?? 'text';
      final width = c['width'] ?? 4;
      switch (type) {
        case 'text':
          logger.w(c);
          posCols.add(PosColumn(
            text: c['text'] ?? '',
            width: width,
            styles: _getTextStyle(c) ,
          ));
          break;

        case 'image':
          final path = c['path'];
          final url = c['url'];
          img.Image? image;
          if (path != null) {
            image = await loadAndCompressImageFromPath(path);
          } else if (url != null) {
            image = await loadAndCompressImageFromUrl(url);
          }
          posCols.add(PosColumn(
            text: '',
            width: width,
            styles:  _getTextStyle(c),
            textEncoded: image != null
                ? Uint8List.fromList(generator.image(image))
                : null,
          ));
          break;
        case 'barcode':
          posCols.add(PosColumn(
            text: '',
            width: width,
            styles:  _getTextStyle(c),
            textEncoded: Uint8List.fromList(_handleBarcode(c)),
          ));
          break;
        case 'qrcode':
          final data = c['data'] ?? '';
          posCols.add(PosColumn(
            text: '',
            width: width,
            styles:  _getTextStyle(c),
            textEncoded: Uint8List.fromList(_handleQrcode(c)),
          ));
          break;
        case 'raw':
          posCols.add(PosColumn(
            text: '',
            width: width,
            styles:  _getTextStyle(c),
            textEncoded: Uint8List.fromList(_handleRaw(c)),
          ));
          break;
      }
    }

    return generator.row(posCols);
  }

  List<int> _handleQrcode(Map<String, dynamic> cmd) {
    final data = cmd['data'] ?? '';
    final size = cmd['size'] ?? 6;
    return generator.qrcode(data, size: _mapQrcodeSize(size));
  }

  List<int> _handleBarcode(Map<String, dynamic> cmd) {
    final data = cmd['data'] ?? '';
    final format = cmd['format'] ?? 'code128';
    final height = cmd['height'] ?? 162;
    final width = cmd['width'] ?? 10;
    final textPos = cmd['textPos'] ?? 'below';

    final Barcode barcode = _mapBarcode(format, data.toString().split(''));

    return generator.barcode(
      barcode,
      height: height,
      width: width,
      textPos: _mapBarcodeTextPos(textPos),
    );
  }

  Future<img.Image?> loadAndCompressImageFromPath(
    String path, {
    int maxWidth = 384,
    int? maxHeight,
  }) async {
    final file = File(path);
    if (!file.existsSync()) return null;

    final bytes = await file.readAsBytes();
    return _processImage(bytes, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  Future<img.Image?> loadAndCompressImageFromUrl(
    String url, {
    int maxWidth = 384,
    int? maxHeight,
  }) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final bytes = response.bodyBytes;
    return _processImage(bytes, maxWidth: maxWidth, maxHeight: maxHeight);
  }

  Future<img.Image?> _processImage(
    Uint8List bytes, {
    int maxWidth = 384,
    int? maxHeight,
  }) async {
    final image = img.decodeImage(bytes);
    if (image == null) return null;

    img.Image resized;
    if (maxHeight != null) {
      // Resize to exact width and height
      resized = img.copyResize(image, width: maxWidth, height: maxHeight);
    } else {
      // Resize proportionally based on width
      resized = img.copyResize(image, width: maxWidth);
    }
    final gray = img.grayscale(resized);
    for (int y = 0; y < gray.height; y++) {
      for (int x = 0; x < gray.width; x++) {
        final pixel = gray.getPixel(x, y);
        final bw = pixel.r > 128 ? 255 : 0;
        gray.setPixelRgba(x, y, bw, bw, bw, 255);
      }
    }
    return gray;
  }

  Future<List<int>> _handleImage(Map<String, dynamic> cmd) async {
    final path = cmd['path'];
    final url = cmd['url'];
    final String? base64Str = cmd['base64'];
    final width = cmd['width'] ?? 384;
    final height = cmd['height'];

    img.Image? image;
    if (path != null && File(path).existsSync()) {
      image = await loadAndCompressImageFromPath(path,
          maxWidth: width, maxHeight: height);
    } else if (url != null) {
      image = await loadAndCompressImageFromUrl(url,
          maxWidth: width, maxHeight: height);
    } else if (base64Str != null) {
      try {
        final bytes = base64Decode(base64Str.split('base64,').last);
        image = img.decodeImage(bytes);
        if (image != null) {
          image = img.copyResize(image,
              width: width, height: height ?? image.height);
        }
      } catch (e) {
        logger.e(e);
      }
    }
    if (image != null) {
      return generator.image(image);
    }
    return [];
  }

  List<int> _handleRaw(Map<String, dynamic> cmd) {
    final raw = cmd['bytes'] as List;
    final List<int> out = [];
    for (var item in raw) {
      if (item is String && item.startsWith("0x")) {
        out.add(int.parse(item.substring(2), radix: 16));
      } else if (item is String) {
        out.addAll(ascii.encode(item));
      } else if (item is int) {
        out.add(item);
      }
    }
    return out;
  }

  // --- Mappers ---

  PosAlign _mapAlign(String? align) {
    switch (align) {
      case 'center':
        return PosAlign.center;
      case 'right':
        return PosAlign.right;
      default:
        return PosAlign.left;
    }
  }

  Barcode _mapBarcode(String format, List<dynamic> data) {
    switch (format.toLowerCase()) {
      case 'ean8':
        return Barcode.ean8(data);
      case 'ean13':
        return Barcode.ean13(data);
      case 'code39':
        return Barcode.code39(data);
      case 'code93':
        return Barcode.codabar(data);
      case 'code128':
        return Barcode.code128(data);
      case 'upca':
        return Barcode.upcA(data);
      default:
        return Barcode.code128(data);
    }
  }

  BarcodeText _mapBarcodeTextPos(String pos) {
    switch (pos) {
      case 'none':
        return BarcodeText.none;
      case 'above':
        return BarcodeText.above;
      case 'both':
        return BarcodeText.both;
      default:
        return BarcodeText.below;
    }
  }

  PosCutMode _mapCutMode(String mode) {
    switch (mode) {
      case 'partial':
        return PosCutMode.partial;
      default:
        return PosCutMode.full;
    }
  }

  QRSize _mapQrcodeSize(int pos) {
    switch (pos) {
      case 1:
        return QRSize.size1;
      case 2:
        return QRSize.size2;
      case 3:
        return QRSize.size3;
      case 4:
        return QRSize.size4;
      case 5:
        return QRSize.size5;
      case 6:
        return QRSize.size6;
      case 7:
        return QRSize.size7;
      case 8:
        return QRSize.size8;
      default:
        return QRSize.size1;
    }
  }
}
