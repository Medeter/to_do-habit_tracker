@echo off
echo Fixing To-Do & Habit Tracker build issues...
echo.
echo Step 1: Cleaning project...
flutter clean
echo.
echo Step 2: Getting dependencies...
flutter pub get
echo.
echo Step 3: Generating app icons...
flutter pub run flutter_launcher_icons:main
echo.
echo Step 4: Building app...
flutter build apk --debug
echo.
echo Done! Your app should now build successfully with the new icon.
echo.
pause