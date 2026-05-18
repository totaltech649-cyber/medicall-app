@echo off
REM =====================================================
REM MédiCall Flutter — Configuration automatique Windows
REM =====================================================
REM Usage: Double-cliquez sur setup.bat
REM =====================================================

echo.
echo    MédiCall Flutter — Configuration automatique
echo    =============================================
echo.

REM 1. Verifier Flutter
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Flutter n'est pas installe ou pas dans le PATH.
    echo Installez Flutter : https://docs.flutter.dev/get-started/install
    pause
    exit /b 1
)

echo OK: Flutter detecte
for /f "tokens=*" %%i in ('where flutter') do set FLUTTER_EXE=%%i
set FLUTTER_PATH=%FLUTTER_EXE:\bin\flutter.bat=%

REM 2. Detecter SDK Android
set ANDROID_SDK=
if defined ANDROID_HOME set ANDROID_SDK=%ANDROID_HOME%
if not defined ANDROID_SDK (
    if exist "%LOCALAPPDATA%\Android\Sdk" set ANDROID_SDK=%LOCALAPPDATA%\Android\Sdk
)
if not defined ANDROID_SDK (
    echo.
    echo AVERTISSEMENT: SDK Android non detecte automatiquement.
    echo Entrez le chemin complet de votre SDK Android (ex: C:\Users\Nom\AppData\Local\Android\Sdk):
    set /p ANDROID_SDK=
)

echo OK: SDK Android = %ANDROID_SDK%

REM 3. Creer local.properties
echo.
echo Creation de android\local.properties...
(
echo sdk.dir=%ANDROID_SDK:\=\\%
echo flutter.sdk=%FLUTTER_PATH:\=\\%
echo flutter.buildMode=release
echo flutter.versionCode=1
echo flutter.versionName=1.0.0
) > android\local.properties
echo OK: android\local.properties cree

REM 4. flutter pub get
echo.
echo Installation des dependances Flutter...
flutter pub get
echo OK: Dependances installees

REM 5. Build APK
echo.
echo Generation de l'APK Release...
flutter build apk --release

echo.
echo ==============================================
echo OK: APK genere avec succes !
echo.
echo Fichier APK :
echo    build\app\outputs\flutter-apk\app-release.apk
echo ==============================================
pause
