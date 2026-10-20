# fitness7

## Gemini API configuration

Food analysis requires a Gemini API key. Provide it at build or run time rather
than adding it to source control:

```powershell
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

The quote app in `quote/` uses the same setting; run the command from that
directory. Dart defines are embedded in the built client, so use a backend
proxy and restrict the key for production use.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
