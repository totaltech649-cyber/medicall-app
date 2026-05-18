# MédiCall — Application Flutter

Application de téléconsultation médicale pour le Bénin.

## 📱 Fonctionnalités

- **Connexion / Inscription** — Mode Patient ou Médecin
- **Accueil Patient** — Liste des médecins disponibles, filtres par spécialité
- **Paiement** — MTN Mobile Money, Moov Money, Carte bancaire
- **Consultation Chat** — Messagerie temps réel avec ordonnance téléchargeable
- **Tableau de bord Médecin** — File d'attente, gains, toggle disponibilité
- **Profil** — Gestion du compte, déconnexion

---

## 🚀 Instructions pour générer l'APK

### Prérequis

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install  
   Version recommandée : Flutter 3.16+
2. **Android Studio** — https://developer.android.com/studio
3. **Java JDK 17+**

---

### Étape 1 — Configurer local.properties

Créez un fichier `android/local.properties` avec :

```
sdk.dir=/chemin/vers/votre/Android/sdk
flutter.sdk=/chemin/vers/votre/flutter
flutter.buildMode=release
flutter.versionCode=1
flutter.versionName=1.0.0
```

**Exemple sur Mac :**
```
sdk.dir=/Users/votre_nom/Library/Android/sdk
flutter.sdk=/Users/votre_nom/flutter
```

**Exemple sur Windows :**
```
sdk.dir=C:\\Users\\votre_nom\\AppData\\Local\\Android\\sdk
flutter.sdk=C:\\src\\flutter
```

---

### Étape 2 — Installer les dépendances

```bash
flutter pub get
```

---

### Étape 3 — Générer l'APK

**APK de debug (plus rapide, pour tester) :**
```bash
flutter build apk --debug
```

**APK de release :**
```bash
flutter build apk --release
```

L'APK sera généré dans :
```
build/app/outputs/flutter-apk/app-release.apk
```

---

### Étape 4 — Ouvrir dans Android Studio

1. Ouvrez Android Studio
2. **File → Open** → sélectionnez le dossier `medicall_flutter`
3. Attendez la synchronisation Gradle
4. **Build → Build Bundle(s)/APK(s) → Build APK(s)**

---

## 🔐 Astuce Connexion (Mode Demo)

| Identifiant contient | Mode |
|---|---|
| `dr.` / `doctor` / `medecin` | Tableau de bord Médecin |
| Tout autre texte | Tableau de bord Patient |

Mot de passe : n'importe quoi (6+ caractères)

---

## 📁 Structure du projet

```
medicall_flutter/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── theme/
│   │   └── app_theme.dart           # Couleurs & thème
│   ├── models/
│   │   └── doctor.dart              # Modèle Médecin
│   ├── widgets/
│   │   ├── common_widgets.dart      # Widgets réutilisables
│   │   └── doctor_card.dart         # Carte médecin
│   └── screens/
│       ├── login_screen.dart        # Connexion / Inscription
│       ├── patient_home_screen.dart # Accueil patient
│       ├── doctor_home_screen.dart  # Dashboard médecin
│       ├── payment_screen.dart      # Paiement
│       ├── chat_screen.dart         # Consultation chat
│       └── profile_screen.dart     # Profil
├── android/                         # Config Android complète
├── ios/                             # Config iOS complète
├── assets/images/                   # Images de l'app
└── pubspec.yaml                     # Dépendances Flutter
```

---

## 🎨 Design

- **Couleur principale :** #1D9E75 (vert médical)
- **Police :** Sora (Google Fonts)
- **Style :** Material 3 avec thème personnalisé

---

*MédiCall v1.0.0 · Bénin 🇧🇯*
