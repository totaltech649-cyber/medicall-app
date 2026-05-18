# 🔥 Guide de configuration Firebase — MédiCall

## ÉTAPE 1 — Créer le projet Firebase

1. Allez sur **https://console.firebase.google.com**
2. Cliquez **"Ajouter un projet"**
3. Nom du projet : `medicall-app`
4. Désactivez Google Analytics (optionnel)
5. Cliquez **"Créer le projet"**

---

## ÉTAPE 2 — Activer les services Firebase

### Authentication
1. Dans la console Firebase → **Authentication** → **Commencer**
2. Onglet **"Méthodes de connexion"**
3. Activez **"E-mail/Mot de passe"** → Enregistrer

### Firestore Database
1. → **Firestore Database** → **Créer une base de données**
2. Choisissez **"Mode production"**
3. Région : **`europe-west1`** (ou la plus proche)
4. Cliquez **"Activer"**

### Storage
1. → **Storage** → **Commencer**
2. Mode production → Région : `europe-west1`
3. Cliquez **"Terminer"**

### Cloud Messaging (FCM)
Automatiquement activé — aucune action requise.

---

## ÉTAPE 3 — Connecter l'app Flutter

### Installer FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Configurer le projet (dans le dossier medicall_flutter/)
```bash
flutterfire configure --project=medicall-app
```

Sélectionnez **Android** et **iOS** quand demandé.

Ce fichier sera automatiquement généré/rempli :
```
lib/firebase_options.dart   ✅ configuré
android/app/google-services.json   ✅ créé
ios/Runner/GoogleService-Info.plist   ✅ créé
```

---

## ÉTAPE 4 — Configurer Android

Dans `android/app/build.gradle`, vérifiez que vous avez :
```gradle
apply plugin: 'com.google.gms.google-services'
```

Dans `android/build.gradle` (root), vérifiez :
```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

---

## ÉTAPE 5 — Déployer les règles de sécurité

### Installer Firebase CLI
```bash
npm install -g firebase-tools
firebase login
firebase init   # sélectionnez Firestore + Storage
```

### Déployer les règles
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

---

## ÉTAPE 6 — Créer les index Firestore

Dans la console Firebase → **Firestore** → **Index** → créez ces index composites :

| Collection | Champs | Ordre |
|---|---|---|
| `consultations` | `patientId` ASC, `createdAt` DESC | — |
| `consultations` | `doctorId` ASC, `status` ASC, `createdAt` ASC | — |
| `consultations` | `doctorId` ASC, `createdAt` DESC | — |
| `users` | `role` ASC, `isAvailable` ASC, `rating` DESC | — |
| `users` | `role` ASC, `speciality` ASC, `isAvailable` ASC | — |

> 💡 Flutter affichera un lien direct dans les logs la première fois qu'un index manquant est détecté — cliquez dessus pour le créer automatiquement.

---

## ÉTAPE 7 — Notifications Push (Cloud Functions)

Pour envoyer des notifications automatiques (ex: "Un médecin vous répond"), créez une Cloud Function.

### Installer
```bash
firebase init functions   # choisissez TypeScript
cd functions && npm install firebase-admin
```

### functions/src/index.ts
```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

// Notification quand un message est envoyé
export const onNewMessage = functions.firestore
  .document('consultations/{consultId}/messages/{msgId}')
  .onCreate(async (snap, context) => {
    const msg = snap.data();
    const consultId = context.params.consultId;

    // Récupérer la consultation pour avoir l'autre participant
    const consult = await admin.firestore()
      .collection('consultations').doc(consultId).get();
    const data = consult.data()!;

    // Déterminer le destinataire
    const recipientId = msg.isDoctor ? data.patientId : data.doctorId;
    const recipient = await admin.firestore()
      .collection('users').doc(recipientId).get();
    const token = recipient.data()?.fcmToken;

    if (!token) return;

    // Envoyer la notification
    await admin.messaging().send({
      token,
      notification: {
        title: msg.isDoctor ? `Dr. ${msg.senderName}` : msg.senderName,
        body: msg.type === 'ordonnance' ? '📋 Ordonnance envoyée' : msg.content,
      },
      data: { consultationId: consultId },
      android: { priority: 'high' },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    });
  });
```

### Déployer
```bash
cd functions && npm run build
firebase deploy --only functions
```

---

## Structure Firestore

```
users/
  {uid}/
    name: "Ama Kossou"
    email: "ama@example.com"
    phone: "+22961234567"
    role: "patient" | "doctor"
    photoUrl: "https://..."
    speciality: "Médecine générale"   # médecin
    isAvailable: true                  # médecin
    rating: 4.9
    reviewCount: 128
    fcmToken: "abc123..."
    createdAt: Timestamp

consultations/
  {consultId}/
    patientId: "uid_patient"
    patientName: "Ama Kossou"
    doctorId: "uid_doctor"
    doctorName: "Dr. Régina Hounkpatin"
    status: "waiting" | "active" | "completed" | "cancelled"
    reason: "Fièvre et maux de gorge"
    diagnosis: "Angine bactérienne"
    prescription: ["Paracétamol 1000mg..."]
    amount: 2500
    paymentMethod: "mtn"
    isPaid: true
    createdAt: Timestamp
    startedAt: Timestamp
    endedAt: Timestamp

    messages/
      {msgId}/
        senderId: "uid"
        senderName: "Ama Kossou"
        isDoctor: false
        content: "Bonjour docteur..."
        type: "text" | "ordonnance" | "image" | "file"
        fileUrl: "https://storage..."
        fileName: "analyse.pdf"
        prescriptionItems: ["Paracétamol..."]
        sentAt: Timestamp
        isRead: false
```

---

## Générer l'APK après configuration Firebase

```bash
flutter pub get
flutter build apk --release
```

L'APK final se trouve dans :
```
build/app/outputs/flutter-apk/app-release.apk
```

---

*MédiCall v1.0.0 · Firebase · Bénin 🇧🇯*
