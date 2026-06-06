import Foundation
import AppKit
import UniformTypeIdentifiers

enum WizardStep: Int, CaseIterable {
    case programName = 0, sections = 1, content = 2, summary = 3
}

@Observable
class WizardViewModel {
    var currentStep: WizardStep = .programName
    var programName: String = ""
    var sectionCount: Int = 3 { didSet { syncSections() } }
    var sections: [SectionEntry] = []
    var errorMessage: String = ""

    var hasError: Bool   { !errorMessage.isEmpty }
    var canGoBack: Bool  { currentStep.rawValue > 0 }
    var isStep0: Bool    { currentStep == .programName }
    var isStep1: Bool    { currentStep == .sections }
    var isStep2: Bool    { currentStep == .content }
    var isStep3: Bool    { currentStep == .summary }
    var nextButtonText: String { currentStep == .summary ? "💾  Exportieren" : "Weiter  →" }

    var currentStepTitle: String {
        switch currentStep {
        case .programName: return "Schritt 1 von 4 – Programmname"
        case .sections:    return "Schritt 2 von 4 – Abschnitte festlegen"
        case .content:     return "Schritt 3 von 4 – Blöcke & Suggestionen hinzufügen"
        case .summary:     return "Schritt 4 von 4 – Zusammenfassung & Export"
        }
    }

    var totalBlocks: Int       { sections.reduce(0) { $0 + $1.blocks.count } }
    var totalSuggestions: Int  { sections.flatMap(\.blocks).reduce(0) { $0 + $1.suggestions.count } }

    init() { syncSections() }

    // ── Navigation ────────────────────────────────────────────────────────────

    func goBack() {
        guard canGoBack else { return }
        currentStep = WizardStep(rawValue: currentStep.rawValue - 1)!
        errorMessage = ""
    }

    @MainActor
    func goNext() async -> Bool {
        errorMessage = ""
        guard validate() else { return false }
        if currentStep == .summary {
            return await exportFile()
        }
        currentStep = WizardStep(rawValue: currentStep.rawValue + 1)!
        return false
    }

    // ── Abschnitte ────────────────────────────────────────────────────────────

    private func syncSections() {
        let count = max(1, min(10, sectionCount))
        while sections.count < count {
            sections.append(SectionEntry(title: "Abschnitt \(sections.count + 1)"))
        }
        while sections.count > count { sections.removeLast() }
    }

    func increaseSections() { if sectionCount < 10 { sectionCount += 1 } }
    func decreaseSections() { if sectionCount > 1  { sectionCount -= 1 } }

    // ── Blöcke ────────────────────────────────────────────────────────────────

    func startAddBlock(in section: SectionEntry) {
        section.newBlockTitle = ""
        section.isAddingBlock = true
    }

    func confirmAddBlock(in section: SectionEntry) {
        let title = section.newBlockTitle.trimmingCharacters(in: .whitespaces)
        if !title.isEmpty { section.blocks.append(BlockEntry()) ; section.blocks.last!.title = title }
        section.isAddingBlock = false
        section.newBlockTitle = ""
    }

    func cancelAddBlock(in section: SectionEntry) {
        section.isAddingBlock = false
        section.newBlockTitle = ""
    }

    func removeBlock(_ block: BlockEntry) {
        for section in sections { section.blocks.removeAll { $0.id == block.id } }
    }

    func toggleBlock(_ block: BlockEntry) { block.isExpanded.toggle() }

    // ── Suggestionen ──────────────────────────────────────────────────────────

    func startAddSuggestion(in block: BlockEntry) {
        block.newSuggestionTitle = ""
        block.newSuggestionText  = ""
        block.isAddingSuggestion = true
    }

    func confirmAddSuggestion(in block: BlockEntry) {
        let title = block.newSuggestionTitle.trimmingCharacters(in: .whitespaces)
        if !title.isEmpty {
            let s = SuggestionEntry()
            s.title = title
            s.text  = block.newSuggestionText.trimmingCharacters(in: .whitespaces)
            block.suggestions.append(s)
        }
        block.isAddingSuggestion = false
        block.newSuggestionTitle = ""
        block.newSuggestionText  = ""
    }

    func cancelAddSuggestion(in block: BlockEntry) { block.isAddingSuggestion = false }

    func removeSuggestion(_ suggestion: SuggestionEntry) {
        for section in sections {
            for block in section.blocks { block.suggestions.removeAll { $0.id == suggestion.id } }
        }
    }

    // ── Audio ─────────────────────────────────────────────────────────────────

    @MainActor
    func generateTts(for sugg: SuggestionEntry) async {
        let settings = AppSettings.shared
        guard !settings.elevenLabsApiKey.isEmpty, !settings.elevenLabsVoiceId.isEmpty else {
            sugg.audioStatus = "⚠  API-Key / Voice-ID fehlt – Einstellungen öffnen."
            return
        }
        sugg.isGeneratingAudio = true
        sugg.audioStatus = "Wird generiert..."
        do {
            let text = sugg.text.isEmpty ? sugg.title : sugg.text
            let data = try await TtsService.generate(text: text, apiKey: settings.elevenLabsApiKey,
                                                     voiceId: settings.elevenLabsVoiceId,
                                                     speed: settings.ttsSpeed)
            sugg.audioData     = data
            sugg.audioFileName = "\(FileService.sanitizeFileName(sugg.title)).mp3"
            sugg.audioStatus   = "✓  \(data.count / 1024) KB"
        } catch {
            sugg.audioStatus = "Fehler: \(error.localizedDescription.prefix(100))"
        }
        sugg.isGeneratingAudio = false
    }

    @MainActor
    func pickAudioFile(for sugg: SuggestionEntry) async {
        let panel = NSOpenPanel()
        panel.title = "Audio-Datei auswählen"
        panel.allowedContentTypes = [.audio, .mp3]
        panel.allowsMultipleSelection = false
        guard let window = NSApp.keyWindow else { return }
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return }
        sugg.audioData     = try? Data(contentsOf: url)
        sugg.audioFileName = url.lastPathComponent
        sugg.audioStatus   = "✓  \(url.lastPathComponent)"
    }

    func clearAudio(for sugg: SuggestionEntry) {
        sugg.audioData     = nil
        sugg.audioFileName = nil
        sugg.audioStatus   = ""
    }

    // ── Export ────────────────────────────────────────────────────────────────

    @MainActor
    private func exportFile() async -> Bool {
        let panel = NSSavePanel()
        panel.title = "Programm speichern als .mindshift-Datei"
        panel.nameFieldStringValue = FileService.sanitizeFileName(programName) + ".mindshift"
        if let type = UTType(filenameExtension: "mindshift") { panel.allowedContentTypes = [type] }
        guard let window = NSApp.keyWindow else { return false }
        let response = await panel.beginSheetModal(for: window)
        guard response == .OK, let url = panel.url else { return false }
        do {
            try FileService.exportWizardProgram(title: programName, sections: sections, to: url)
            let alert = NSAlert()
            alert.messageText = "Erfolgreich gespeichert"
            alert.informativeText = "✓  Das Programm \"\(programName)\" wurde gespeichert!\n\nDatei: \(url.path)\n\nSie können diese Datei jetzt auf Ihr Smartphone senden und in der MindShift-App importieren."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return true
        } catch {
            errorMessage = "Fehler beim Speichern: \(error.localizedDescription)"
            return false
        }
    }

    // ── Validierung ───────────────────────────────────────────────────────────

    private func validate() -> Bool {
        switch currentStep {
        case .programName:
            if programName.trimmingCharacters(in: .whitespaces).isEmpty {
                errorMessage = "Bitte geben Sie einen Namen für Ihr Programm ein."
                return false
            }
        case .sections:
            if sections.contains(where: { $0.title.trimmingCharacters(in: .whitespaces).isEmpty }) {
                errorMessage = "Bitte geben Sie für jeden Abschnitt einen Namen ein."
                return false
            }
        default: break
        }
        return true
    }
}
