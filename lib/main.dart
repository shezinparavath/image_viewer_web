/// A web application that allows users to view images from URLs with fullscreen capabilities.
///
/// Features:
/// - URL input for loading images
/// - HTML-based image rendering
/// - Double-click fullscreen toggle
/// - Floating menu for fullscreen controls
library;

import 'dart:ui';
import 'dart:ui_web' as ui;
import 'package:web/web.dart' as html;
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:get/get.dart';

/// Initializes the application with web-specific configurations.
void main() {
  // Use path URL strategy for cleaner web URLs
  setUrlStrategy(PathUrlStrategy());

  // Register the default HTML view factory
  ui.platformViewRegistry.registerViewFactory(
    'custom-html-view',
    (int viewId) => html.document.createElement('div')
      ..innerHTML = '<h1>Hello from Web!</h1>'.toJS,
  );

  runApp(const MyApp());
}

/// JavaScript interop for fullscreen functionality.
@JS('toggleFullscreen')
external void requestFullscreen();

/// JavaScript interop for exiting fullscreen mode.
@JS('exitFullscreen')
external void exitFullscreen();

/// Controller managing the application's state using GetX.
///
/// Handles:
/// - Image URL management
/// - Error state tracking
/// - Menu visibility state
class ImageViewerController extends GetxController {
  /// Current image URL being displayed
  final imageUrl = ''.obs;

  /// Tracks if the current image URL is invalid or failed to load
  final hasError = false.obs;

  /// Controls the visibility of the floating menu
  final isMenuOpen = false.obs;

  /// Controller for the URL input field
  final TextEditingController urlController = TextEditingController();

  /// Updates the image URL and resets error state
  void setImageUrl(String url) {
    imageUrl.value = url;
    hasError.value = false;
  }

  /// Toggles the floating menu visibility
  void toggleMenu() {
    isMenuOpen.value = !isMenuOpen.value;
  }

  /// Updates the error state for image loading
  void setError(bool value) {
    hasError.value = value;
  }

  /// Closes the floating menu
  void closeMenu() {
    isMenuOpen.value = false;
  }
}

/// Root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const ImageViewerScreen(),
    );
  }
}

/// Main screen of the image viewer application.
///
/// Contains:
/// - URL input field
/// - Image display area
/// - Floating menu for fullscreen controls
class ImageViewerScreen extends StatelessWidget {
  /// Creates an instance of [ImageViewerScreen].
  const ImageViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImageViewerController());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          ),
        ),
        child: Stack(
          children: [
            _buildMainContent(controller),
            _buildFloatingMenuWithOverlay(controller),
          ],
        ),
      ),
    );
  }

  /// Builds the main content area including title, input field, and image display.
  Widget _buildMainContent(ImageViewerController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(),
          _buildUrlInput(controller),
          _buildLoadButton(controller),
          _buildImageDisplay(controller),
        ],
      ),
    );
  }

  /// Builds the application title widget.
  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Text(
        'Image Viewer',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      ),
    );
  }

  /// Builds the URL input field.
  Widget _buildUrlInput(ImageViewerController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: TextField(
        controller: controller.urlController,
        onSubmitted: (value) => controller.setImageUrl(value),
        decoration: InputDecoration(
          labelText: 'Enter Image URL',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.link, color: Colors.indigo),
        ),
      ),
    );
  }

  /// Builds the load button for fetching images.
  Widget _buildLoadButton(ImageViewerController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: ElevatedButton.icon(
        onPressed: () => controller.setImageUrl(controller.urlController.text),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.image_search),
        label: const Text(
          'Load Image',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  /// Builds the image display area with error handling.
  Widget _buildImageDisplay(ImageViewerController controller) {
    return Obx(() {
      if (controller.imageUrl.isEmpty) return const SizedBox();

      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: GestureDetector(
          onDoubleTap: () => requestFullscreen(),
          child: controller.hasError.value
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Invalid Image URL',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                )
              : htmlElementView(controller),
        ),
      );
    });
  }

  /// Builds the floating menu with overlay and animation.
  Widget _buildFloatingMenuWithOverlay(ImageViewerController controller) {
    return Obx(() => Stack(
          children: [
            if (controller.isMenuOpen.value)
              GestureDetector(
                onTap: () => controller.closeMenu(),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            Positioned(
              bottom: 80,
              right: 20,
              child: AnimatedSlide(
                offset: controller.isMenuOpen.value
                    ? Offset.zero
                    : const Offset(1.5, 0),
                duration: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    _buildFloatingButton(
                      'Enter Fullscreen',
                      Icons.fullscreen,
                      () {
                        requestFullscreen();
                        controller.closeMenu();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFloatingButton(
                      'Exit Fullscreen',
                      Icons.fullscreen_exit,
                      () {
                        exitFullscreen();
                        controller.closeMenu();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () => controller.toggleMenu(),
                elevation: 4,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        ));
  }

  /// Builds a floating button with an icon and label.
  Widget _buildFloatingButton(
      String label, IconData icon, VoidCallback onPressed) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      elevation: 4,
    );
  }

  /// Creates an HTML image element view for displaying the image.
  ///
  /// Uses platform view registry to create a native HTML image element
  /// that supports double-click fullscreen functionality.
  Widget htmlElementView(ImageViewerController controller) {
    final viewType =
        'image-view-${controller.imageUrl.value}-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final imgElement = html.HTMLImageElement()
        ..src = controller.imageUrl.value
        ..style.width = '100%'
        ..style.height = 'auto'
        ..style.cursor = 'pointer'
        ..onError.listen((_) {
          controller.setError(true);
        })
        ..onLoad.listen((_) {
          controller.setError(false);
        })
        ..onDoubleClick.listen((_) => requestFullscreen());

      return imgElement;
    });

    return SizedBox(
      width: 300,
      height: 300,
      child: HtmlElementView(viewType: viewType),
    );
  }
}
