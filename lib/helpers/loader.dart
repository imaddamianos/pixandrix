import 'package:flutter/material.dart';

class GlobalLoader {
  static final GlobalLoader _instance = GlobalLoader._internal();

  factory GlobalLoader() {
    return _instance;
  }

  GlobalLoader._internal();

  static OverlayEntry? _overlayEntry;

  void showLoader(BuildContext context, {Color loaderColor = Colors.white}) {
    hideLoader(); // Close existing loader if any

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: MediaQuery.of(context).size.width * 0.4,
        child: Material(
          color: Colors.transparent,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(loaderColor),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hideLoader() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
