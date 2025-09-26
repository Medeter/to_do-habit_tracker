@echo off
echo Generating App Icons for To-Do & Habit Tracker...
echo.
echo Step 1: Installing dependencies...
flutter pub get
echo.
echo Step 2: Generating app icons...
flutter pub run flutter_launcher_icons:main
echo.
echo Done! Your app icons have been generated.
echo Check the following folders for the new icons:
echo - android/app/src/main/res/mipmap-*/
echo - ios/Runner/Assets.xcassets/AppIcon.appiconset/
echo - web/icons/
echo.
pause