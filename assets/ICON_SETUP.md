# App Icon Setup Instructions

## Step 1: Save the Logo
1. Save the attached circular logo image as `app_icon.png` in the `assets/` folder
2. Make sure the image is at least 1024x1024 pixels for best quality
3. The image should be in PNG format

## Step 2: Generate Icons
Run the following commands:

```bash
flutter pub get
flutter pub run flutter_launcher_icons:main
```

## Step 3: Verify Icons
The script will automatically generate:
- Android icons in various densities (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi)
- iOS icons in all required sizes
- Web icons and favicon

## Current Icon Features:
- Beautiful gradient from blue to green
- Clean checkmark with leaf design
- Icons for calendar, settings, and habits
- Circular progress indicator
- Professional app branding

## Sizes Generated:
- Android: 48dp, 72dp, 96dp, 144dp, 192dp
- iOS: 20pt-1024pt in all required variants
- Web: 192px, 512px, favicon