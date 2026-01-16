# Build Instructions for Lumina Notes

## Prerequisites
- **Flutter SDK**: Installed and on your PATH (`flutter doctor` should be clean).
- **Code Generation**: Ensure you have run the build runner if you made changes:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```

---

## 📱 Android
To build an APK for installation on physical devices:

### Debug APK (Faster, for testing)
```bash
flutter build apk --debug
```
*Output*: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (Optimized, signed with debug key for now)
```bash
flutter build apk --release
```
*Output*: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (For Play Store)
```bash
flutter build appbundle
```

---

## 🌐 Web
To build a production-ready web version:

1. **Build the project**:
   ```bash
   flutter build web --release
   ```
   *Output*: `build/web/`

2. **Important Note**:
   The `build/web` folder is a static site. You can deploy this directory to GitHub Pages, Firebase Hosting, or Vercel.
   Ensure `sqlite3.wasm` is present in the `web/` folder (already handled in setup), as it's required for the local database.

---

## 💻 Windows
To build a native Windows executable:

```bash
flutter build windows
```
*Output*: `build/windows/runner/Release/`
* The generated `.exe` and surrounding DLLs in this folder should be distributed together.

---

## 🏃‍♂️ How to Run (Development)
- **Chrome**: `flutter run -d chrome`
- **Windows**: `flutter run -d windows`
- **Android**: `flutter run -d <device_id>` (run `flutter devices` to list IDs)
