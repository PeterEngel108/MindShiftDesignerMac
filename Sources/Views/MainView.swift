import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct MainView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var appState = appState
        VStack(spacing: 0) {
            headerBar
            Divider()

            Group {
                if appState.currentView == .home {
                    HomeView()
                } else {
                    WizardView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.15), value: appState.currentView)

            Divider()
            statusBar
        }
        .background(Color(hex: "#F5F6FA"))
        .alert(appState.alertTitle, isPresented: $appState.showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(appState.alertMessage)
        }
    }

    // ── Header ────────────────────────────────────────────────────────────────

    private var headerBar: some View {
        HStack {
            Text("🧠").font(.system(size: 22))
            Text("MindShift Designer")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Text("– Autosuggestionen einfach erstellen")
                .font(.system(size: 13))
                .foregroundColor(Color(hex: "#B0BEF8"))

            Spacer()

            Button("Neue Datei öffnen") { Task { await importFile() } }
                .buttonStyle(GhostHeaderButtonStyle())

            Button("⚙  Einstellungen") { openPreferences() }
                .buttonStyle(GhostHeaderButtonStyle())
        }
        .padding(.horizontal, 24)
        .frame(height: 60)
        .background(Color(hex: "#5C6BC0"))
    }

    // ── Statuszeile ───────────────────────────────────────────────────────────

    private var statusBar: some View {
        HStack {
            Text(appState.statusMessage)
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#6B7280"))
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 6)
        .background(.white)
    }

    // ── Datei öffnen ──────────────────────────────────────────────────────────

    @MainActor
    private func importFile() async {
        let panel = NSOpenPanel()
        panel.title = "MindShift-Datei öffnen"
        if let type = UTType(filenameExtension: "mindshift") { panel.allowedContentTypes = [type] }
        panel.allowsMultipleSelection = false
        guard let window = NSApp.keyWindow else { return }
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return }
        do {
            let before = AppData.shared.programs.count
            try FileService.importFile(from: url, into: AppData.shared)
            let added = AppData.shared.programs.count - before
            appState.statusMessage = "Importiert: \(url.lastPathComponent)"
            appState.currentView   = .home
            appState.showInfo(title: "Import erfolgreich",
                              message: "✓  Datei erfolgreich importiert!\n\n\(added) Programm(e) hinzugefügt – jetzt insgesamt \(AppData.shared.programs.count) Programm(e) geladen.\n\nSie können die Programme auf der Startseite exportieren.")
        } catch {
            appState.showError("Fehler beim Öffnen der Datei:\n\(error.localizedDescription)")
        }
    }

    private func openPreferences() {
        if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}

// ── Button-Styles ──────────────────────────────────────────────────────────────

struct GhostHeaderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(configuration.isPressed ? Color.white.opacity(0.2) : Color.clear)
            .cornerRadius(6)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var background: Color = Color(hex: "#5C6BC0")
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(configuration.isPressed ? Color(hex: "#3949AB") : background)
            .cornerRadius(8)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(hex: "#5C6BC0"))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(configuration.isPressed ? Color(hex: "#EEF2FF") : Color.clear)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#5C6BC0"), lineWidth: 2))
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14))
            .foregroundColor(configuration.isPressed ? Color(hex: "#5C6BC0") : Color(hex: "#6B7280"))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(configuration.isPressed ? Color(hex: "#E8EAF6") : Color.clear)
            .cornerRadius(6)
    }
}

struct AddButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(hex: "#5C6BC0"))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(configuration.isPressed ? Color(hex: "#EEF2FF") : Color.clear)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#5C6BC0"), lineWidth: 2))
    }
}

struct IconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 30, height: 30)
            .background(configuration.isPressed ? Color(hex: "#E8EAF6") : Color.clear)
            .cornerRadius(6)
    }
}

// ── Hilfsmethoden ─────────────────────────────────────────────────────────────

extension Color {
    init(hex: String) {
        var h = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        if h.count == 6 { h += "FF" }
        let val = UInt64(h, radix: 16) ?? 0xFFFFFFFF
        self.init(red:   Double((val >> 24) & 0xFF) / 255,
                  green: Double((val >> 16) & 0xFF) / 255,
                  blue:  Double((val >>  8) & 0xFF) / 255,
                  opacity: Double(val & 0xFF) / 255)
    }
}
