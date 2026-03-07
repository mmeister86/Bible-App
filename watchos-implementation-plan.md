# DailyVerse – Apple Watch App Implementation Plan

## Projektübersicht

Erweiterung der bestehenden iOS-App **DailyVerse Daily Bible Verses** um eine native Apple Watch Companion App. Die Watch-App soll den Vers des Tages direkt am Handgelenk anzeigen, Favoriten synchronisieren und über Complications auf dem Zifferblatt verfügbar sein.

**Ziel-OS:** watchOS 10+  
**UI-Framework:** SwiftUI (ausschließlich)  
**Kommunikation:** WatchConnectivity  
**Geschätzter Aufwand:** ~2–4 Wochen (je nach Feature-Umfang)

---

## Phase 1: Projekt-Setup

### 1.1 Watch-App-Target erstellen

- In Xcode: **File → New → Target → watchOS App**
- Als Companion zur bestehenden DailyVerse iOS-App konfigurieren
- Deployment Target auf watchOS 10.0 setzen
- Sicherstellen, dass das Watch-Target dem gleichen App-Group und Team zugeordnet ist
- Bundle Identifier Convention: `dev.matthiasmeister.dailyverse.watchkitapp`

### 1.2 Gemeinsame Ressourcen vorbereiten

- Shared Swift Package oder Framework für gemeinsame Modelle erstellen (z.B. `DailyVerseCore`)
- Datenmodelle definieren, die beide Targets nutzen:
  - `Verse` (Referenz, Text, Übersetzung)
  - `DailyVerse` (Vers + Datum)
  - `Favorite` (Vers + Timestamp)
- Bibeltext-Daten (WEB, KJV, BBE, OEB) als JSON-Bundles für beide Targets bereitstellen
- App Icon für watchOS erstellen (kreisrundes Design, 1024×1024 als Basis)

### 1.3 Datenstrategie festlegen

- **Empfehlung:** Bibeltexte direkt ins Watch-App-Bundle packen (~wenige MB pro Übersetzung)
- Vorteil: Watch-App funktioniert auch ohne iPhone-Verbindung
- Tagesvers-Logik und Favoriten über WatchConnectivity synchronisieren
- Kein CloudKit/Account nötig → passt zum Privacy-First-Ansatz

---

## Phase 2: Kernfunktionen

### 2.1 Vers des Tages (Hauptansicht)

**Beschreibung:** Beim Öffnen der Watch-App wird der aktuelle Tagesvers angezeigt.

**Umsetzung:**

- `ContentView` als `NavigationStack` mit dem Tagesvers als Hauptinhalt
- Vers-Text scrollbar per Digital Crown (`.digitalCrownRotation`)
- Referenz (z.B. „Johannes 3:16") als Titel/Header
- Übersetzungskürzel dezent anzeigen (z.B. „WEB")
- Schriftgröße an Watch-Display anpassen (Dynamic Type berücksichtigen)
- Gleiche Tagesvers-Logik wie in der iOS-App verwenden (deterministisch nach Datum)

**Dateien:**

- `DailyVerseWatchApp.swift` – App Entry Point
- `ContentView.swift` – Hauptansicht mit Tagesvers
- `VerseCardView.swift` – Wiederverwendbare Vers-Darstellung
- `DailyVerseProvider.swift` – Tagesvers-Logik (shared mit iOS)

### 2.2 Random Verse

**Beschreibung:** Zufälliger Bibelvers per Button-Tap.

**Umsetzung:**

- Eigener Tab oder Button in der Navigation
- Animation beim Laden eines neuen Verses (z.B. sanfter Übergang)
- Gleiche `VerseCardView` wie beim Tagesvers verwenden
- Möglichkeit, den Vers direkt zu den Favoriten hinzuzufügen

**Dateien:**

- `RandomVerseView.swift`

### 2.3 Favoriten

**Beschreibung:** Gespeicherte Lieblingsverse auf der Watch anzeigen und verwalten.

**Umsetzung:**

- `List`-basierte Ansicht mit allen Favoriten
- Tap auf einen Favoriten zeigt den vollständigen Vers
- Swipe-to-Delete zum Entfernen
- Favoriten-Änderungen bidirektional mit iPhone synchronisieren
- Herz-Icon / Toggle zum Hinzufügen/Entfernen in der Vers-Ansicht

**Dateien:**

- `FavoritesListView.swift`
- `FavoritesManager.swift` (shared Logik)

---

## Phase 3: WatchConnectivity

### 3.1 Session-Setup

**Beschreibung:** Kommunikationskanal zwischen iPhone und Apple Watch einrichten.

**Umsetzung:**

- `WCSessionManager` als Singleton auf beiden Seiten (iOS + watchOS)
- `WCSession.default` aktivieren in `didFinishLaunching` (iOS) bzw. App-Init (watchOS)
- `WCSessionDelegate` implementieren

**Dateien:**

- `WCSessionManager.swift` (je eine Version für iOS und watchOS Target)

### 3.2 Daten-Synchronisation

**Synchronisierte Daten:**

| Daten | Methode | Richtung |
|-------|---------|----------|
| Aktueller Tagesvers | `updateApplicationContext` | iPhone → Watch |
| Favoriten-Liste | `updateApplicationContext` | Bidirektional |
| Favorit hinzufügen/entfernen | `sendMessage` (wenn aktiv) oder `transferUserInfo` | Bidirektional |
| Gewählte Übersetzung | `updateApplicationContext` | iPhone → Watch |

**Ablauf:**

1. Beim Start der iOS-App: aktuellen Tagesvers + Favoriten + Einstellungen an Watch senden
2. Bei Favoritenänderung auf iPhone: sofort `sendMessage`, Fallback auf `transferUserInfo`
3. Bei Favoritenänderung auf Watch: `sendMessage` an iPhone, Fallback auf `transferUserInfo`
4. Watch speichert empfangene Daten lokal in UserDefaults (Watch-seitig)

### 3.3 Offline-Fähigkeit

- Bibeltexte sind im Watch-Bundle → Tagesvers funktioniert immer
- Favoriten werden lokal auf der Watch gecached
- Bei Reconnect: Abgleich der Favoriten-Listen (Timestamp-basiert, neuerer Eintrag gewinnt)

---

## Phase 4: Complications (WidgetKit)

### 4.1 Complication-Setup

**Beschreibung:** Vers des Tages direkt auf dem Zifferblatt anzeigen.

**Umsetzung:**

- WidgetKit-Target zum Watch-App-Target hinzufügen
- `TimelineProvider` implementieren mit täglichem Update
- `TimelineReloadPolicy.after(nextMidnight)` für automatisches Refresh um Mitternacht

**Unterstützte Widget-Familien:**

| Familie | Inhalt |
|---------|--------|
| `.accessoryInline` | Nur Versreferenz, z.B. „Psalm 23:1" |
| `.accessoryCircular` | Vers-Icon + kurzer Text |
| `.accessoryRectangular` | Referenz + gekürzte erste Zeile des Verstextes |
| `.accessoryCorner` | Vers-Icon (optional) |

**Dateien:**

- `DailyVerseWidget.swift` – Widget-Definition
- `DailyVerseTimelineProvider.swift` – Timeline-Logik
- `ComplicationViews.swift` – Views pro Widget-Familie

### 4.2 Complication-Daten

- Tagesvers-Daten aus dem gleichen `DailyVerseProvider` wie die Hauptapp
- Bei Tap auf Complication → Watch-App öffnet sich mit dem Tagesvers
- `WidgetCenter.shared.reloadAllTimelines()` aufrufen, wenn ein neuer Tagesvers gesetzt wird

---

## Phase 5: Notifications

### 5.1 Tägliche Erinnerung auf der Watch

**Beschreibung:** Die bestehenden lokalen Notifications der iOS-App erscheinen auch auf der Watch, optimiert dargestellt.

**Umsetzung:**

- Custom `WKNotificationScene` in der Watch-App registrieren
- `NotificationView.swift` erstellen mit schöner Vers-Darstellung
- Notification-Kategorie muss identisch sein mit der iOS-App
- Der Vers-Text wird im Notification-Payload als UserInfo mitgeschickt

**Dateien:**

- `NotificationView.swift`
- `NotificationController.swift`

### 5.2 Notification Actions

- **Favorit-Button:** Vers direkt aus der Notification zu Favoriten hinzufügen
- **Öffnen-Button:** Vers in der Watch-App anzeigen

---

## Phase 6: UI / Design

### 6.1 Navigation

```
TabView (watchOS-Style)
├── Tab 1: Vers des Tages
├── Tab 2: Random Verse
└── Tab 3: Favoriten (List)
```

- `TabView` mit `.tabViewStyle(.verticalPage)` für watchOS
- Klare, fokussierte Screens ohne Überladung
- Maximal 3 Tabs für schnellen Zugriff

### 6.2 Design-Richtlinien

- Schriftgröße: Mindestens 16pt für Fließtext auf der Watch
- Kontrastreiche Farben (helle Schrift auf dunklem Hintergrund)
- Farbschema konsistent mit der iOS-App
- Minimaler Text pro Screen – bei langen Versen scrollbar machen
- Versreferenz visuell abgesetzt (z.B. kleinere Schrift, andere Farbe)
- Ladeanimationen vermeiden → Daten sind lokal, alles muss sofort da sein

### 6.3 Accessibility

- Dynamic Type unterstützen
- VoiceOver-Labels für alle interaktiven Elemente
- Ausreichende Touch-Target-Größen (mindestens 44×44pt Äquivalent)

---

## Phase 7: Testing

### 7.1 Simulator-Tests

- Tagesvers-Anzeige und Navigation
- Random Verse Logik
- Favoriten hinzufügen / entfernen
- Widget-Vorschau in verschiedenen Familien
- Layout auf verschiedenen Watch-Größen (41mm, 45mm, 49mm Ultra)

### 7.2 Geräte-Tests (zwingend erforderlich)

- WatchConnectivity End-to-End (Favoriten-Sync iPhone ↔ Watch)
- Complication-Updates über Mitternacht hinweg
- Notification-Darstellung auf der Watch
- Performance und Akkuverbrauch
- Offline-Verhalten (iPhone nicht in Reichweite)
- Erstinstallation und Daten-Migration

### 7.3 Edge Cases

- Watch-App wird gestartet, bevor jemals die iOS-App geöffnet wurde
- Favoriten-Konflikt (gleichzeitig auf iPhone und Watch geändert)
- Sehr lange Bibelverse (Darstellung und Scrolling)
- Wechsel der Bibelübersetzung auf dem iPhone → Watch-Update

---

## Phase 8: App Store Deployment

### 8.1 Vorbereitung

- Watch-App-Screenshots erstellen (alle relevanten Watch-Größen)
- App-Beschreibung in App Store Connect um Watch-Features ergänzen
- Watch-App wird als Teil des bestehenden iOS-App-Bundles eingereicht
- Kein separater App Store Eintrag nötig

### 8.2 Einreichung

- Neues Build mit Watch-Target in Xcode archivieren
- In App Store Connect unter der bestehenden App hochladen
- Watch-Screenshots unter dem watchOS-Reiter hinzufügen
- Review Notes: Hinweis auf neue Watch-App-Funktionalität
- Privacy-Angaben prüfen (sollten sich nicht ändern, da weiterhin keine Daten gesammelt werden)

### 8.3 Kompatibilität

- iOS Minimum: 17.0 (bereits bestehend)
- watchOS Minimum: 10.0
- Unterstützte Geräte: Apple Watch Series 6 und neuer

---

## Phase 9: Post-Launch / Zukünftige Features

Mögliche Erweiterungen nach dem initialen Release:

- **Discover by Mood:** Mood-Kategorien als kompakte Liste auf der Watch, Tap zeigt passenden Vers
- **Verse Sharing:** Vers per Tap teilen (AirDrop, Messages)
- **Haptic Feedback:** Sanfte Vibration bei neuem Tagesvers (Morning Reminder)
- **Siri-Integration:** „Hey Siri, lies mir den Vers des Tages vor" via App Intents
- **Live Activities / Smart Stack:** Tagesvers als Live Activity im watchOS Smart Stack
- **Mehrsprachigkeit:** Wenn die iOS-App weitere Sprachen unterstützt, auch auf der Watch

---

## Dateistruktur (Vorschlag)

```
DailyVerse/
├── DailyVerse (iOS)/
│   ├── ... (bestehender iOS-Code)
│   └── WCSessionManager+iOS.swift
│
├── DailyVerseWatch/
│   ├── DailyVerseWatchApp.swift
│   ├── ContentView.swift
│   ├── Views/
│   │   ├── VerseCardView.swift
│   │   ├── RandomVerseView.swift
│   │   ├── FavoritesListView.swift
│   │   └── NotificationView.swift
│   ├── Managers/
│   │   ├── WCSessionManager+Watch.swift
│   │   └── FavoritesManager.swift
│   └── Assets.xcassets/
│
├── DailyVerseWidgetWatch/
│   ├── DailyVerseWidget.swift
│   ├── DailyVerseTimelineProvider.swift
│   └── ComplicationViews.swift
│
├── Shared/
│   ├── Models/
│   │   ├── Verse.swift
│   │   ├── DailyVerse.swift
│   │   └── Favorite.swift
│   ├── DailyVerseProvider.swift
│   └── Data/
│       ├── web.json
│       ├── kjv.json
│       ├── bbe.json
│       └── oeb.json
│
└── DailyVerse.xcodeproj
```

---

## Checkliste vor Release

- [ ] Watch-App-Target korrekt konfiguriert (Bundle ID, Signing, Capabilities)
- [ ] Alle 4 Übersetzungen im Watch-Bundle enthalten
- [ ] Tagesvers-Anzeige funktioniert ohne iPhone-Verbindung
- [ ] Favoriten-Sync iPhone ↔ Watch getestet
- [ ] Complications zeigen korrekten Tagesvers
- [ ] Complication-Update um Mitternacht verifiziert
- [ ] Notifications auf der Watch korrekt dargestellt
- [ ] UI auf allen Watch-Größen geprüft
- [ ] Accessibility (VoiceOver, Dynamic Type) getestet
- [ ] Screenshots für App Store erstellt
- [ ] App Store Beschreibung aktualisiert
- [ ] Privacy-Angaben unverändert (keine Datenerhebung)
- [ ] Testflight Beta-Test durchgeführt
