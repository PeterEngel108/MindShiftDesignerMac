import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showClearConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                heroCard
                actionCards
                if !AppData.shared.programs.isEmpty { programsList }
                infoCard
                transferCard
            }
            .padding(40)
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Color(hex: "#F5F6FA"))
        .confirmationDialog("Alle löschen", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Alles löschen", role: .destructive) { clearAll() }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Alle geladenen Programme und Daten entfernen?")
        }
    }

    // ── Hero Card ─────────────────────────────────────────────────────────────

    private var heroCard: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Willkommen beim MindShift Designer!")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A2E"))
                Text("Erstellen Sie Ihre persönlichen Autosuggestionen am Computer\nund übertragen Sie sie auf Ihr Smartphone.")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#6B7280"))
                    .lineSpacing(4)
            }
            Spacer()
            Text("🧠").font(.system(size: 72)).opacity(0.15)
        }
        .padding(20)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // ── Aktionskarten ─────────────────────────────────────────────────────────

    private var actionCards: some View {
        HStack(spacing: 16) {
            // Neu erstellen
            Button(action: { appState.currentView = .wizard }) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("✨").font(.system(size: 36))
                    Text("Neues Programm erstellen")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Schritt für Schritt werden Sie durch die Erstellung geführt. Kein Vorwissen nötig!")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#C5CCF7"))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("→ Jetzt starten")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#5C6BC0"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.white)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(Color(hex: "#5C6BC0"))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)

            // Datei öffnen
            Button(action: { Task { await importFile() } }) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("📂").font(.system(size: 36))
                    Text("Vorhandene Datei öffnen")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                    Text("Öffnen Sie eine bestehende .mindshift-Datei, um sie zu bearbeiten oder zu ergänzen.")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#6B7280"))
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("📂 Datei öffnen")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#5C6BC0"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "#EEF2FF"))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)
        }
    }

    // ── Geladene Programme ────────────────────────────────────────────────────

    private var programsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("📋  Geladene Programme")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "#1A1A2E"))
                Text("\(AppData.shared.programs.count)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "#5C6BC0"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: "#EEF2FF"))
                    .cornerRadius(10)
                Spacer()
                Button("Alle löschen") { showClearConfirm = true }
                    .buttonStyle(GhostButtonStyle())
                    .foregroundColor(Color(hex: "#6B7280"))
            }

            ForEach(AppData.shared.programs) { program in
                HStack {
                    Text("📋 ").font(.system(size: 16))
                    Text(program.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#1A1A2E"))
                    Spacer()
                    Button("💾  Exportieren") { Task { await exportProgram(program) } }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.vertical, -4)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(hex: "#FAFBFF"))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    // ── Info-Karte ────────────────────────────────────────────────────────────

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ℹ️  Was ist MindShift?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A2E"))

            Text("MindShift ist eine Smartphone-App, die Ihnen dabei hilft, positive Gedanken und Überzeugungen als Audiodateien zu hören – zum Beispiel während Sie einschlafen oder meditieren.")
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#6B7280"))
                .lineSpacing(4)

            HStack(spacing: 16) {
                infoChip(icon: "🎵", title: "Suggestion", text: "Ein einzelner Satz, der gesprochen wird.")
                infoChip(icon: "📦", title: "Block",      text: "Eine Gruppe von Suggestionen zum gleichen Thema.")
                infoChip(icon: "📂", title: "Abschnitt",  text: "Eine Phase in Ihrem Programm.")
                infoChip(icon: "📋", title: "Programm",   text: "Ihre komplette Hör-Einheit mit allen Abschnitten.")
            }

            HStack(spacing: 4) {
                Text("Typischer Ablauf:").font(.system(size: 14, weight: .semibold))
                Text("Suggestion → Block → Abschnitt → Programm → auf Smartphone importieren → hören ✓")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#6B7280"))
            }
        }
        .padding(20)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }

    private func infoChip(icon: String, title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(icon) \(title)").font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: "#5C6BC0"))
            Text(text).font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280")).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#EEF2FF"))
        .cornerRadius(8)
    }

    // ── Transfer-Karte ────────────────────────────────────────────────────────

    private var transferCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("📱").font(.system(size: 20))
            VStack(alignment: .leading, spacing: 4) {
                Text("So kommen die Daten aufs Handy:").font(.system(size: 14, weight: .semibold))
                Text("Speichern Sie Ihr Programm als .mindshift-Datei → senden Sie diese an Ihr Handy (E-Mail, AirDrop, USB …) → öffnen Sie die Datei in der MindShift-App → fertig!")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#1A1A2E"))
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .background(Color(hex: "#EEF2FF"))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#E8EAF6"), lineWidth: 1))
    }

    // ── Aktionen ──────────────────────────────────────────────────────────────

    @MainActor
    private func importFile() async {
        let panel = NSOpenPanel()
        panel.title = "MindShift-Datei öffnen"
        if let type = UTType(filenameExtension: "mindshift") { panel.allowedContentTypes = [type] }
        guard let window = NSApp.keyWindow else { return }
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return }
        do {
            let before = AppData.shared.programs.count
            try FileService.importFile(from: url, into: AppData.shared)
            let added = AppData.shared.programs.count - before
            appState.statusMessage = "Importiert: \(url.lastPathComponent)"
            appState.showInfo(title: "Import erfolgreich",
                              message: "✓  \(added) Programm(e) hinzugefügt – insgesamt \(AppData.shared.programs.count) Programm(e) geladen.")
        } catch {
            appState.showError("Fehler beim Öffnen:\n\(error.localizedDescription)")
        }
    }

    @MainActor
    private func exportProgram(_ program: MsProgram) async {
        let panel = NSSavePanel()
        panel.title = "Programm exportieren als .mindshift-Datei"
        panel.nameFieldStringValue = FileService.sanitizeFileName(program.title) + ".mindshift"
        if let type = UTType(filenameExtension: "mindshift") { panel.allowedContentTypes = [type] }
        guard let window = NSApp.keyWindow else { return }
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return }
        do {
            try FileService.exportProgram(program, from: AppData.shared, to: url)
            appState.showInfo(title: "Erfolgreich exportiert",
                              message: "✓  »\(program.title)« wurde gespeichert!\n\nDatei: \(url.path)")
        } catch {
            appState.showError("Fehler beim Exportieren:\n\(error.localizedDescription)")
        }
    }

    private func clearAll() {
        AppData.shared.programs.removeAll()
        AppData.shared.sections.removeAll()
        AppData.shared.blocks.removeAll()
        AppData.shared.suggestions.removeAll()
        AppData.shared.programSections.removeAll()
        AppData.shared.programSectionBlocks.removeAll()
        appState.statusMessage = "Alle Daten gelöscht."
    }
}
