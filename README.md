# MindShift Designer for macOS

Native macOS-App zum Erstellen von Autosuggestionen für die **MindShift**-Smartphone-App.  
Dies ist die Mac-Version des [MindShift Designers](https://github.com/PeterEngel108/MindShiftDesigner) (Windows/WPF).

---

## Features

- **4-Schritt-Wizard** – Programm erstellen: Name → Abschnitte → Blöcke & Suggestionen → Export
- **ElevenLabs TTS** – Automatisch Audio für Suggestionen generieren
- **Audio-Import** – Eigene MP3/WAV-Dateien einbinden
- **`.mindshift`-Export** – ZIP-Datei mit JSON + Audio, kompatibel mit der MindShift-App
- **Import** – Bestehende `.mindshift`-Dateien öffnen, bearbeiten und neu exportieren
- **Native macOS-Dialoge** – `NSOpenPanel`, `NSSavePanel`, native Einstellungen (⌘,)

---

## Voraussetzungen

| Tool | Version |
|------|---------|
| macOS | 14 (Sonoma) oder neuer |
| Xcode | 15 oder neuer |
| Swift | 5.9 oder neuer |

---

## Installation & Start

```bash
git clone https://github.com/PeterEngel108/MindShiftDesignerMac.git
```

1. Xcode öffnen
2. `File → Open` → Ordner `MindShiftDesignerMac` wählen
3. Xcode erkennt `Package.swift` automatisch
4. `ZIPFoundation` wird automatisch heruntergeladen
5. Schema **MindShiftDesignerMac** wählen → ▶ **Run**

---

## Projektstruktur

```
Sources/
├── MindShiftDesignerMacApp.swift   – @main App-Einstiegspunkt, AppState
├── Models/
│   ├── Entities.swift              – Datenmodelle (@Observable)
│   ├── AppSettings.swift           – ElevenLabs-Einstellungen (UserDefaults)
│   └── ExportDtos.swift            – JSON-DTOs (Codable)
├── Services/
│   ├── TtsService.swift            – ElevenLabs API (async/await)
│   └── FileService.swift           – ZIP Import/Export (ZIPFoundation)
├── ViewModels/
│   └── WizardViewModel.swift       – Wizard-Logik (4 Schritte)
└── Views/
    ├── MainView.swift              – Hauptfenster, Header, Button-Styles
    ├── HomeView.swift              – Startseite mit Programmliste
    ├── WizardView.swift            – Schritt-für-Schritt-Assistent
    └── SettingsView.swift          – ElevenLabs-Einstellungen
```

---

## ElevenLabs TTS einrichten

1. Account auf [elevenlabs.io](https://elevenlabs.io) erstellen
2. **API-Key** unter `Profile → API Keys` kopieren
3. **Voice-ID** unter `Voices` einer Stimme kopieren
4. In der App: Menü **MindShiftDesignerMac → Einstellungen** (⌘,) → Key + Voice-ID eintragen

---

## Workflow

```
Suggestion  →  Block  →  Abschnitt  →  Programm  →  .mindshift-Datei
    │                                                       │
    └── Text + TTS-Audio                        per AirDrop / E-Mail
                                                  auf Smartphone senden
                                                  → in MindShift-App öffnen
```

| Begriff | Bedeutung |
|---------|-----------|
| **Suggestion** | Ein einzelner Satz, der als Audio gesprochen wird |
| **Block** | Eine thematische Gruppe von Suggestionen |
| **Abschnitt** | Eine Phase im Programm (z.B. Einleitung, Hauptteil, Abschluss) |
| **Programm** | Die komplette Hör-Einheit – wie eine Playlist |

---

## Abhängigkeiten

| Paket | Zweck |
|-------|-------|
| [ZIPFoundation](https://github.com/weichsel/ZIPFoundation) | `.mindshift`-Dateien lesen/schreiben (ZIP + JSON) |

---

## Kompatibilität

Die exportierten `.mindshift`-Dateien sind vollständig kompatibel mit:
- **MindShift Designer Windows** (WPF-Version)
- **MindShift Android-App**

---

## Lizenz

MIT License – siehe [LICENSE](LICENSE)
