import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

Future<String?> showBrowserQrScannerDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const _BrowserQrScannerDialog(),
  );
}

class _BrowserQrScannerDialog extends StatefulWidget {
  const _BrowserQrScannerDialog();

  @override
  State<_BrowserQrScannerDialog> createState() => _BrowserQrScannerDialogState();
}

class _BrowserQrScannerDialogState extends State<_BrowserQrScannerDialog> {
  late final web.HTMLVideoElement _videoElement;
  late final String _viewType;

  web.MediaStream? _stream;
  Object? _detector;
  Timer? _scanTimer;
  bool _scanBusy = false;
  String? _error;
  List<_CameraOption> _cameras = <_CameraOption>[];
  String? _selectedCameraId;
  bool _startingCamera = false;

  static int _viewCounter = 0;

  JSObject get _windowObject => JSObject.fromInteropObject(web.window);

  bool get _supportsQrScanner => _windowObject.has('BarcodeDetector');

  @override
  void initState() {
    super.initState();
    _viewType = 'browser-qr-scanner-${_viewCounter++}';
    _videoElement = web.HTMLVideoElement()
      ..autoplay = true
      ..muted = true
      ..playsInline = true
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..setAttribute('controls', 'false');

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int _) => _videoElement,
    );

    _startScanner();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _stopCurrentStream();
    _videoElement.srcObject = null;
    super.dispose();
  }

  Future<void> _startScanner() async {
    if (!_supportsQrScanner) {
      setState(() {
        _error = 'This browser does not support the BarcodeDetector QR API.';
      });
      return;
    }

    try {
      final JSFunction constructor =
          _windowObject['BarcodeDetector']! as JSFunction;
      final JSObject detectorOptions = JSObject()
        ..['formats'] = <JSString>['qr_code'.toJS].toJS;
      _detector = constructor.callAsConstructorVarArgs<JSObject>(
        <JSAny?>[detectorOptions],
      );

      await _startPreferredCamera();

      _scanTimer = Timer.periodic(
        const Duration(milliseconds: 300),
        (_) => _scanFrame(),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Could not access camera for QR scanning: $error';
      });
    }
  }

  Future<void> _startPreferredCamera() async {
    setState(() {
      _startingCamera = true;
    });

    await _primeCameraPermissions();
    await _loadAvailableCameras();

    final String? preferredCameraId =
        _pickPreferredCameraId(_cameras) ?? _selectedCameraId;
    if (preferredCameraId != null && preferredCameraId.isNotEmpty) {
      await _openCamera(deviceId: preferredCameraId);
    } else {
      await _openCamera();
    }

    if (mounted) {
      setState(() {
        _startingCamera = false;
      });
    }
  }

  Future<void> _loadAvailableCameras() async {
    final JSObject mediaDevices =
        JSObject.fromInteropObject(web.window.navigator.mediaDevices);
    final JSArray<JSObject> devices = await mediaDevices
        .callMethodVarArgs<JSPromise<JSArray<JSObject>>>(
          'enumerateDevices'.toJS,
          const <JSAny?>[],
        )
        .toDart;

    final List<_CameraOption> cameras = devices.toDart
        .where((JSObject device) => (device['kind'] as JSString?)?.toDart == 'videoinput')
        .map((JSObject device) {
          final String id = ((device['deviceId'] as JSString?)?.toDart ?? '').trim();
          final String label = ((device['label'] as JSString?)?.toDart ?? '').trim();
          return _CameraOption(
            id: id,
            label: label.isEmpty ? 'Camera' : label,
          );
        })
        .where((camera) => camera.id.isNotEmpty)
        .toList();

    if (!mounted) {
      return;
    }

    setState(() {
      _cameras = cameras;
      _selectedCameraId = _pickPreferredCameraId(cameras) ?? _selectedCameraId;
    });
  }

  Future<void> _primeCameraPermissions() async {
    final JSObject mediaDevices =
        JSObject.fromInteropObject(web.window.navigator.mediaDevices);
    final JSObject mediaConstraints = JSObject()
      ..['video'] = true.toJS
      ..['audio'] = false.toJS;

    web.MediaStream? permissionStream;
    try {
      permissionStream = await mediaDevices
          .callMethodVarArgs<JSPromise<web.MediaStream>>(
            'getUserMedia'.toJS,
            <JSAny?>[mediaConstraints],
          )
          .toDart;
    } finally {
      for (final web.MediaStreamTrack track
          in permissionStream?.getTracks().toDart ?? <web.MediaStreamTrack>[]) {
        track.stop();
      }
    }
  }

  Future<void> _openCamera({String? deviceId}) async {
    final JSObject mediaDevices =
        JSObject.fromInteropObject(web.window.navigator.mediaDevices);
    final JSObject videoConstraints = JSObject();

    if (deviceId != null && deviceId.isNotEmpty) {
      final JSObject exactDeviceId = JSObject()..['exact'] = deviceId.toJS;
      videoConstraints['deviceId'] = exactDeviceId;
    } else {
      final JSObject facingMode = JSObject()..['ideal'] = 'environment'.toJS;
      videoConstraints['facingMode'] = facingMode;
    }

    final JSObject mediaConstraints = JSObject()
      ..['video'] = videoConstraints
      ..['audio'] = false.toJS;

    _stopCurrentStream();
    _stream = await mediaDevices
        .callMethodVarArgs<JSPromise<web.MediaStream>>(
          'getUserMedia'.toJS,
          <JSAny?>[mediaConstraints],
        )
        .toDart;
    _videoElement.srcObject = _stream;
    await _videoElement.play().toDart;

    if (!mounted) {
      return;
    }
    setState(() {
      _selectedCameraId = deviceId ?? _selectedCameraId;
      _error = null;
    });
  }

  void _stopCurrentStream() {
    for (final web.MediaStreamTrack track
        in _stream?.getTracks().toDart ?? <web.MediaStreamTrack>[]) {
      track.stop();
    }
    _stream = null;
  }

  String? _pickPreferredCameraId(List<_CameraOption> cameras) {
    if (cameras.isEmpty) {
      return null;
    }

    final List<_CameraOption> sorted = List<_CameraOption>.from(cameras)
      ..sort((_CameraOption a, _CameraOption b) {
        return _cameraScore(b.label).compareTo(_cameraScore(a.label));
      });
    return sorted.first.id;
  }

  int _cameraScore(String label) {
    final String lower = label.toLowerCase();
    int score = 0;
    if (lower.contains('obs')) {
      score -= 100;
    }
    if (lower.contains('virtual')) {
      score -= 80;
    }
    if (lower.contains('facetime') ||
        lower.contains('built-in') ||
        lower.contains('builtin') ||
        lower.contains('integrated')) {
      score += 40;
    }
    if (lower.contains('camera')) {
      score += 10;
    }
    return score;
  }

  Future<void> _switchCamera(String? deviceId) async {
    if (deviceId == null || deviceId == _selectedCameraId) {
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _startingCamera = true;
          _error = null;
        });
      }
      await _openCamera(deviceId: deviceId);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Could not switch camera: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _startingCamera = false;
        });
      }
    }
  }

  Future<void> _scanFrame() async {
    if (_scanBusy || _detector == null || _videoElement.videoWidth == 0) {
      return;
    }

    _scanBusy = true;
    try {
      final JSArray<JSObject> barcodes = await (_detector! as JSObject)
          .callMethodVarArgs<JSPromise<JSArray<JSObject>>>(
            'detect'.toJS,
            <JSAny?>[JSObject.fromInteropObject(_videoElement)],
          )
          .toDart;
      final List<JSObject> barcodeList = barcodes.toDart;
      if (barcodeList.isNotEmpty && mounted) {
        final JSString? rawValue = barcodeList.first['rawValue'] as JSString?;
        if (rawValue != null && rawValue.toDart.isNotEmpty) {
          Navigator.of(context).pop(rawValue.toDart);
        }
      }
    } catch (_) {
      // Ignore transient decode failures while scanning live frames.
    } finally {
      _scanBusy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Scan QR Code'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _error == null
                    ? HtmlElementView(viewType: _viewType)
                    : Container(
                        color: const Color(0xFF122033),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (_cameras.length > 1) ...<Widget>[
              DropdownButtonFormField<String>(
                initialValue: _selectedCameraId,
                items: _cameras
                    .map(
                      (_CameraOption camera) => DropdownMenuItem<String>(
                        value: camera.id,
                        child: Text(camera.label),
                      ),
                    )
                    .toList(),
                onChanged: _startingCamera ? null : _switchCamera,
                decoration: const InputDecoration(
                  labelText: 'Camera',
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              _error ??
                  (_startingCamera
                      ? 'Starting camera...'
                      : 'Point the camera at a wallet import QR or a Bismuth payment QR.'),
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _CameraOption {
  final String id;
  final String label;

  const _CameraOption({
    required this.id,
    required this.label,
  });
}
