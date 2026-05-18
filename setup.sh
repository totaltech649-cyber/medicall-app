#!/bin/bash
# =====================================================
# MédiCall Flutter — Script de configuration automatique
# =====================================================
# Usage: bash setup.sh
# =====================================================

set -e

echo ""
echo "🏥  MédiCall Flutter — Configuration automatique"
echo "================================================="
echo ""

# 1. Vérifier Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌  Flutter n'est pas installé ou pas dans le PATH."
    echo "    Installez Flutter : https://docs.flutter.dev/get-started/install"
    exit 1
fi

FLUTTER_PATH=$(which flutter | sed 's|/bin/flutter||')
FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
echo "✅  Flutter détecté : $FLUTTER_VERSION"
echo "    Chemin Flutter : $FLUTTER_PATH"

# 2. Détecter le SDK Android
ANDROID_SDK=""
if [ -n "$ANDROID_HOME" ]; then
    ANDROID_SDK="$ANDROID_HOME"
elif [ -d "$HOME/Library/Android/sdk" ]; then
    ANDROID_SDK="$HOME/Library/Android/sdk"
elif [ -d "$HOME/Android/Sdk" ]; then
    ANDROID_SDK="$HOME/Android/Sdk"
elif [ -d "/usr/local/lib/android/sdk" ]; then
    ANDROID_SDK="/usr/local/lib/android/sdk"
fi

if [ -z "$ANDROID_SDK" ]; then
    echo ""
    echo "⚠️  SDK Android non détecté automatiquement."
    echo "    Entrez le chemin complet de votre SDK Android :"
    read -r ANDROID_SDK
fi

echo "✅  SDK Android : $ANDROID_SDK"

# 3. Créer local.properties
echo ""
echo "📝  Création de android/local.properties..."
cat > android/local.properties << EOF
sdk.dir=$ANDROID_SDK
flutter.sdk=$FLUTTER_PATH
flutter.buildMode=release
flutter.versionCode=1
flutter.versionName=1.0.0
EOF
echo "✅  android/local.properties créé"

# 4. flutter pub get
echo ""
echo "📦  Installation des dépendances Flutter..."
flutter pub get
echo "✅  Dépendances installées"

# 5. Build APK
echo ""
echo "🔨  Génération de l'APK Release..."
flutter build apk --release

echo ""
echo "================================================="
echo "✅  APK généré avec succès !"
echo ""
echo "📱  Fichier APK :"
echo "    build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "📲  Pour installer sur un appareil Android connecté :"
echo "    flutter install"
echo "================================================="
