# App Launcher Icon

## GO ICELAND App Icon

Place the provided app icon image here as `icon.png`.

### Required:

- **File name:** `icon.png`
- **Recommended size:** 1024x1024px
- **Format:** PNG with transparency

### Icon Design:

- Blue to teal gradient background
- White map pin with mountain logo
- Aurora wave design inside pin
- "GO ICELAND" text in white

### Setup Steps:

1. **Save the icon:**

   - Save the provided icon image as `icon.png` in this folder
   - Ensure it's 1024x1024px or larger

2. **Install flutter_launcher_icons:**

   ```bash
   flutter pub get
   ```

3. **Generate launcher icons:**

   ```bash
   dart run flutter_launcher_icons
   ```

4. **Verify:**
   - Check `android/app/src/main/res/` for Android icons
   - Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/` for iOS icons

### Current Status:

✅ Configuration added to `pubspec.yaml`
✅ Directory created
⏳ **Action needed:** Place `icon.png` in this folder (1024x1024px)

### Alternative:

If you have the icon in a different format, you can convert it online at:

- https://www.img2go.com/convert-to-png
- https://www.iloveimg.com/resize-image

Then ensure it's named `icon.png` and placed here.
