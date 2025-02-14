# Image Viewer Web Application

A Flutter web application that allows users to view images from URLs with fullscreen capabilities. Built with Flutter web and GetX state management.

## Features

- URL input for loading and displaying images
- HTML-based image rendering for optimal web performance
- Double-click to toggle fullscreen mode
- Floating menu with fullscreen controls
- Error handling for invalid image URLs
- Responsive design with blur overlay effects

## Setup Instructions

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Git

### Installation

1. Clone the repository:
```bash
git clone [your-repository-url]
cd image-viewer
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the web application locally:
```bash
flutter run -d chrome
```

### Deployment

To deploy to GitHub Pages:

1. Build the web version:
```bash
flutter build web --release --base-href "/image-viewer/"
```

2. Copy the contents of `build/web` to your GitHub Pages branch

## Usage Instructions

1. Launch the application in your web browser
2. Enter an image URL in the input field
3. Click "Load Image" or press Enter to display the image
4. Interact with the image:
   - Double-click the image to enter fullscreen mode
   - Click the "+" button in the bottom-right corner for additional controls
   - Use the floating menu buttons to toggle fullscreen mode
   - Click outside the menu to close it

## Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  flutter_web_plugins:
    sdk: flutter
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
