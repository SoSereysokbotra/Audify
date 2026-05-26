# audify

A new Flutter project.

## Cloudinary uploads

Profile image uploads should use a Cloudinary unsigned upload preset. Do not put
the Cloudinary API secret in the Flutter app because it is compiled into the
client.

Create an unsigned upload preset in Cloudinary, then run the app with:

```powershell
flutter run --dart-define=CLOUDINARY_CLOUD_NAME=dssi9zedm --dart-define=CLOUDINARY_UPLOAD_PRESET=your_unsigned_preset
```

The VS Code launch profile prompts for `CLOUDINARY_UPLOAD_PRESET` when the app
starts.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
