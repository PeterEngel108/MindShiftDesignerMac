import SwiftUI

struct WizardView: View {
    @Environment(AppState.self) private var appState
    @State private var vm = WizardViewModel()

    var body: some View {
        VStack(spacing: 0) {
            stepHeader
            Divider()
            HStack(spacing: 0) {
                stepContent.frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                previewPanel.frame(width: 300)
            }
            Divider()
            navigationBar
        }
    }

    // ── Schritt-Kopfzeile ─────────────────────────────────────────────────────

    private var stepHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(vm.currentStepTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "#5C6BC0"))

            HStack(spacing: 0) {
                ForEach(WizardStep.allCases, id: \.rawValue) { step in
                    HStack(spacing: 8) {
                        if step.rawValue > 0 {
                            Rectangle().fill(Color(hex: "#E5E7EB")).frame(width: 24, height: 2)
                        }
                        ZStack {
                            Circle()
                                .fill(stepColor(step))
                                .frame(width: 28, height: 28)
                            Text("\(step.rawValue + 1)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        }
                        Text(stepLabel(step))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(hex: "#1A1A2E"))
                    }
                    if step != WizardStep.allCases.last { Spacer() }
                }
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 14)
        .background(.white)
    }

    private func stepColor(_ step: WizardStep) -> Color {
        if vm.currentStep == step  { return Color(hex: "#5C6BC0") }
        if vm.currentStep.rawValue > step.rawValue { return Color(hex: "#10B981") }
        return Color(hex: "#D1D5DB")
    }

    private func stepLabel(_ step: WizardStep) -> String {
        switch step {
        case .programName: return "Programmname"
        case .sections:    return "Abschnitte"
        case .content:     return "Inhalte"
        case .summary:     return "Fertig"
        }
    }

    // ── Hauptinhalt ───────────────────────────────────────────────────────────

    @ViewBuilder
    private var stepContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                switch vm.currentStep {
                case .programName: step1
                case .sections:    step2
                case .content:     step3
                case .summary:     step4
                }

                if vm.hasError {
                    HStack(spacing: 8) {
                        Text("⚠  ").foregroundColor(Color(hex: "#EF4444"))
                        Text(vm.errorMessage).foregroundColor(Color(hex: "#EF4444")).font(.system(size: 14))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(hex: "#FEF2F2"))
                    .cornerRadius(8)
                    .padding(.top, 16)
                }
            }
            .padding(EdgeInsets(top: 28, leading: 40, bottom: 24, trailing: 24))
        }
    }

    // ── Schritt 1: Programmname ───────────────────────────────────────────────

    private var step1: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("📋  Name des Programms")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A2E"))

            infoBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡  Was ist ein Programm?")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "#5C6BC0"))
                    Text("Ein Programm ist Ihre persönliche Hör-Einheit – ähnlich wie eine Playlist. Es enthält mehrere Abschnitte, die nacheinander abgespielt werden.")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "#1A1A2E")).lineSpacing(4)
                    Text("Gute Namen beschreiben WANN oder WOFÜR Sie es hören:\n»Morgen-Ritual«  ·  »Vor dem Einschlafen«  ·  »Selbstvertrauen stärken«")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280")).lineSpacing(3)
                }
            }

            Text("Wie soll Ihr Programm heißen?")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "#1A1A2E"))

            TextField("z.B. Morgen-Ritual", text: $vm.programName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 18))
                .frame(maxWidth: 480)

            Text("Beispiele: Morgen-Ritual · Abend-Entspannung · Mittagspause · Schlaf gut")
                .font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))
        }
    }

    // ── Schritt 2: Abschnitte ─────────────────────────────────────────────────

    private var step2: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text("📂  Abschnitte für »") + Text(vm.programName).foregroundColor(Color(hex: "#5C6BC0")) + Text("«")
            }
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(Color(hex: "#1A1A2E"))

            Text("Abschnitte unterteilen das Programm in thematische Phasen.")
                .font(.system(size: 14)).foregroundColor(Color(hex: "#6B7280"))

            infoBox {
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡  Was ist ein Abschnitt?")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                    Text("Jeder Abschnitt wird nacheinander abgespielt und kann eine eigene Hintergrundmusik haben. Typisch: Einleitung → Hauptteil → Abschluss")
                        .font(.system(size: 14)).foregroundColor(Color(hex: "#1A1A2E")).lineSpacing(4)
                    Text("Für ein 20-Minuten-Programm reichen meist 2–3 Abschnitte.")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))
                }
            }

            Text("Wie viele Abschnitte soll das Programm haben?")
                .font(.system(size: 16, weight: .semibold)).foregroundColor(Color(hex: "#1A1A2E"))

            HStack(spacing: 10) {
                Button("−") { vm.decreaseSections() }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(width: 46, height: 46)
                Text("\(vm.sectionCount)")
                    .font(.system(size: 26, weight: .bold)).foregroundColor(Color(hex: "#5C6BC0"))
                    .frame(width: 60)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#EEF2FF")).cornerRadius(8)
                Button("+") { vm.increaseSections() }
                    .buttonStyle(SecondaryButtonStyle())
                    .frame(width: 46, height: 46)
                Text("(1 bis 10 Abschnitte)")
                    .font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))
            }

            Text("Namen der Abschnitte:").font(.system(size: 16, weight: .semibold)).foregroundColor(Color(hex: "#1A1A2E"))
            Text("Diese Namen können Sie jederzeit ändern.").font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))

            VStack(spacing: 10) {
                ForEach(vm.sections) { section in
                    @Bindable var section = section
                    HStack(spacing: 8) {
                        Text("📂").font(.system(size: 18))
                        TextField("Abschnittsname", text: $section.title)
                            .textFieldStyle(.roundedBorder).font(.system(size: 14))
                    }
                }
            }
            .frame(maxWidth: 500, alignment: .leading)
        }
    }

    // ── Schritt 3: Inhalte ────────────────────────────────────────────────────

    private var step3: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text("📦  Inhalte für »") + Text(vm.programName).foregroundColor(Color(hex: "#5C6BC0")) + Text("«")
            }
            .font(.system(size: 22, weight: .bold)).foregroundColor(Color(hex: "#1A1A2E"))

            Text("Fügen Sie jedem Abschnitt Blöcke und Suggestionen hinzu.")
                .font(.system(size: 14)).foregroundColor(Color(hex: "#6B7280"))

            infoBox {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("📦  Block").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                            Text("Eine thematische Gruppe von Suggestionen.\nBeispiel: »Entspannung« oder »Selbstliebe«")
                                .font(.system(size: 12)).foregroundColor(Color(hex: "#1A1A2E")).lineSpacing(3)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🎵  Suggestion").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                            Text("Ein einzelner Satz, der als Audio gesprochen wird.\nBeispiel: »Ich bin ruhig und entspannt.«")
                                .font(.system(size: 12)).foregroundColor(Color(hex: "#1A1A2E")).lineSpacing(3)
                        }
                    }
                    Divider()
                    HStack(spacing: 6) {
                        Text("🔊  TTS-Audio: Klicken Sie bei jeder Suggestion auf")
                            .font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280"))
                        Text("🔊 TTS").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                            .padding(.horizontal, 6).padding(.vertical, 2).background(Color(hex: "#E8EAF6")).cornerRadius(4)
                        Text("oder").font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280"))
                        Text("📁 Datei").font(.system(size: 11, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                            .padding(.horizontal, 6).padding(.vertical, 2).background(Color(hex: "#E8EAF6")).cornerRadius(4)
                        Text("um Audio hinzuzufügen.").font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280"))
                    }
                }
            }

            ForEach(vm.sections) { section in
                sectionBlock(section)
            }
        }
    }

    private func sectionBlock(_ section: SectionEntry) -> some View {
        @Bindable var section = section
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("📂").font(.system(size: 18))
                Text(section.title).font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "#1A1A2E"))
            }

            ForEach(section.blocks) { block in
                blockCard(block)
            }

            if section.isAddingBlock {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Neuen Block anlegen:").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                    TextField("Name des Blocks (z.B. »Entspannung«)", text: $section.newBlockTitle)
                        .textFieldStyle(.roundedBorder).font(.system(size: 14))
                    Text("Name des Blocks (z.B. »Entspannung«, »Selbstvertrauen«, »Positive Gedanken«)")
                        .font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280"))
                    HStack(spacing: 8) {
                        Button("✓  Block anlegen") { vm.confirmAddBlock(in: section) }
                            .buttonStyle(PrimaryButtonStyle())
                        Button("Abbrechen") { vm.cancelAddBlock(in: section) }
                            .buttonStyle(GhostButtonStyle())
                    }
                }
                .padding(16)
                .background(.white).cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#5C6BC0"), lineWidth: 1.5))
            } else {
                Button(action: { vm.startAddBlock(in: section) }) {
                    HStack(spacing: 6) {
                        Text("+").font(.system(size: 18, weight: .bold))
                        Text("Block hinzufügen").font(.system(size: 14))
                    }
                }
                .buttonStyle(AddButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(hex: "#F0F4FF"))
        .cornerRadius(10)
    }

    private func blockCard(_ block: BlockEntry) -> some View {
        @Bindable var block = block
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("📦").font(.system(size: 16))
                Text(block.title).font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#1A1A2E"))
                Text("\(block.suggestions.count) Suggestion(en)")
                    .font(.system(size: 11)).foregroundColor(Color(hex: "#5C6BC0"))
                    .padding(.horizontal, 8).padding(.vertical, 2).background(Color(hex: "#EEF2FF")).cornerRadius(10)
                Spacer()
                Button(action: { vm.toggleBlock(block) }) {
                    Text(block.isExpanded ? "▾" : "▸").font(.system(size: 14))
                }
                .buttonStyle(IconButtonStyle())
                Button(action: { vm.removeBlock(block) }) {
                    Text("🗑").font(.system(size: 13))
                }
                .buttonStyle(IconButtonStyle())
                .foregroundColor(Color(hex: "#EF4444"))
            }

            if block.isExpanded {
                ForEach(block.suggestions) { suggestion in
                    suggestionRow(suggestion)
                }

                if block.isAddingSuggestion {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Neue Suggestion hinzufügen:").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                        TextField("Kurztitel (z.B. »Ruhe«, »Stärke«)", text: $block.newSuggestionTitle)
                            .textFieldStyle(.roundedBorder).font(.system(size: 14))
                        Text("Kurztitel (z.B. »Ruhe«, »Selbstvertrauen«)").font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280"))
                        TextEditor(text: $block.newSuggestionText)
                            .font(.system(size: 14))
                            .frame(minHeight: 64)
                            .padding(4)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
                        Text("Text, der später gesprochen wird (z.B. »Ich bin ruhig und entspannt in jeder Situation.«)")
                            .font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280")).lineSpacing(3)
                        HStack(spacing: 8) {
                            Button("✓  Hinzufügen") { vm.confirmAddSuggestion(in: block) }
                                .buttonStyle(PrimaryButtonStyle())
                            Button("Abbrechen") { vm.cancelAddSuggestion(in: block) }
                                .buttonStyle(GhostButtonStyle())
                        }
                    }
                    .padding(12)
                    .background(Color(hex: "#EEF2FF")).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#5C6BC0"), lineWidth: 1.5))
                } else {
                    Button(action: { vm.startAddSuggestion(in: block) }) {
                        HStack(spacing: 4) {
                            Text("+").font(.system(size: 15, weight: .bold))
                            Text("Suggestion hinzufügen").font(.system(size: 12))
                        }
                    }
                    .buttonStyle(GhostButtonStyle())
                }
            }
        }
        .padding(14)
        .background(.white).cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: "#E5E7EB"), lineWidth: 1))
    }

    private func suggestionRow(_ sugg: SuggestionEntry) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text("🎵").font(.system(size: 13))
                    Text(sugg.title).font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#1A1A2E"))
                }
                if !sugg.text.isEmpty {
                    Text(sugg.text).font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))
                        .padding(.leading, 20).lineSpacing(3)
                }
                HStack(spacing: 4) {
                    Button(action: { Task { await vm.generateTts(for: sugg) } }) {
                        Text("🔊 TTS").font(.system(size: 11))
                    }
                    .buttonStyle(GhostButtonStyle())
                    .disabled(sugg.isGeneratingAudio)
                    .padding(.leading, 16)

                    Button(action: { Task { await vm.pickAudioFile(for: sugg) } }) {
                        Text("📁 Datei").font(.system(size: 11))
                    }
                    .buttonStyle(GhostButtonStyle())

                    if !sugg.audioStatus.isEmpty {
                        Text(sugg.audioStatus).font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280"))
                    }
                    if sugg.hasAudio {
                        Button(action: { vm.clearAudio(for: sugg) }) {
                            Text("✕").font(.system(size: 10))
                        }
                        .buttonStyle(IconButtonStyle())
                        .frame(width: 20, height: 20)
                    }
                }
            }
            Spacer()
            Button(action: { vm.removeSuggestion(sugg) }) {
                Text("✕").font(.system(size: 11))
            }
            .buttonStyle(IconButtonStyle())
            .foregroundColor(Color(hex: "#EF4444"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(hex: "#F0F4FF"))
        .cornerRadius(6)
    }

    // ── Schritt 4: Zusammenfassung ────────────────────────────────────────────

    private var step4: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("🎉  Ihr Programm ist fertig!")
                .font(.system(size: 22, weight: .bold)).foregroundColor(Color(hex: "#1A1A2E"))

            HStack(spacing: 4) {
                Text("Klicken Sie auf ")
                Text("»Exportieren«").fontWeight(.semibold).foregroundColor(Color(hex: "#5C6BC0"))
                Text("um die .mindshift-Datei zu speichern.")
            }
            .font(.system(size: 14)).foregroundColor(Color(hex: "#6B7280"))

            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Text("📋").font(.system(size: 18))
                    Text(vm.programName).font(.system(size: 16, weight: .bold)).foregroundColor(Color(hex: "#5C6BC0"))
                }
                ForEach(vm.sections) { section in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) { Text("📂").font(.system(size: 15)); Text(section.title).font(.system(size: 14, weight: .semibold)) }
                        ForEach(section.blocks) { block in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) { Text("📦").font(.system(size: 13)); Text(block.title).font(.system(size: 14)) }
                                ForEach(block.suggestions) { sugg in
                                    HStack(spacing: 6) { Text("🎵").font(.system(size: 11)); Text(sugg.title).font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280")) }
                                        .padding(.leading, 20)
                                }
                            }
                            .padding(.leading, 20)
                        }
                    }
                    .padding(.leading, 16)
                }
                HStack(spacing: 4) {
                    Text("\(vm.sections.count) Abschnitt(e)  ·  \(vm.totalBlocks) Block(s)  ·  \(vm.totalSuggestions) Suggestion(en)")
                        .font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))
                }
                .padding(.horizontal, 14).padding(.vertical, 10).background(Color(hex: "#EEF2FF")).cornerRadius(8)
            }
            .padding(20).background(.white).cornerRadius(12).shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

            infoBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("📱  So übertragen Sie die Datei auf Ihr iPhone/Android:")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#5C6BC0"))
                    HStack(alignment: .top, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            transferStep("1", "Auf »Exportieren« klicken")
                            transferStep("2", "Datei per AirDrop / E-Mail senden")
                        }
                        VStack(alignment: .leading, spacing: 6) {
                            transferStep("3", "Datei auf Gerät öffnen")
                            transferStep("✓", "In MindShift abspielen!", color: Color(hex: "#10B981"))
                        }
                    }
                }
            }
        }
    }

    private func transferStep(_ number: String, _ text: String, color: Color = Color(hex: "#5C6BC0")) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle().fill(color).frame(width: 20, height: 20)
                Text(number).font(.system(size: 10, weight: .bold)).foregroundColor(.white)
            }
            Text(text).font(.system(size: 14)).foregroundColor(number == "✓" ? color : Color(hex: "#1A1A2E"))
                .fontWeight(number == "✓" ? .semibold : .regular)
        }
    }

    // ── Vorschau-Panel ────────────────────────────────────────────────────────

    private var previewPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("VORSCHAU").font(.system(size: 11, weight: .bold)).foregroundColor(Color(hex: "#6B7280"))
            Text("So sieht Ihr Programm aus:").font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280"))

            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("📋").font(.system(size: 14))
                        Text(vm.programName).font(.system(size: 14, weight: .bold)).foregroundColor(Color(hex: "#5C6BC0"))
                    }
                    ForEach(vm.sections) { section in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 4) { Text("📂").font(.system(size: 13)); Text(section.title).font(.system(size: 13, weight: .semibold)) }
                            ForEach(section.blocks) { block in
                                VStack(alignment: .leading, spacing: 1) {
                                    HStack(spacing: 4) { Text("📦").font(.system(size: 12)); Text(block.title).font(.system(size: 12)) }
                                    ForEach(block.suggestions) { sugg in
                                        HStack(spacing: 4) { Text("🎵").font(.system(size: 11)); Text(sugg.title).font(.system(size: 11)).foregroundColor(Color(hex: "#6B7280")) }
                                            .padding(.leading, 14)
                                    }
                                }
                                .padding(.leading, 12)
                            }
                        }
                        .padding(.leading, 10)
                    }
                    if vm.isStep0 {
                        Text("Die Vorschau aktualisiert sich während Sie die Inhalte eingeben.")
                            .font(.system(size: 12)).foregroundColor(Color(hex: "#6B7280")).italic().lineSpacing(3)
                    }
                }
            }
        }
        .padding(20)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(.white)
    }

    // ── Navigationsleiste ─────────────────────────────────────────────────────

    private var navigationBar: some View {
        HStack {
            if vm.canGoBack {
                Button("← Zurück") { vm.goBack() }.buttonStyle(SecondaryButtonStyle())
            } else {
                Button("← Abbrechen") { appState.currentView = .home }.buttonStyle(GhostButtonStyle())
            }
            Spacer()
            Button(action: {
                Task {
                    let done = await vm.goNext()
                    if done { appState.currentView = .home }
                }
            }) {
                Text(vm.nextButtonText).font(.system(size: 14))
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(minWidth: 160)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 14)
        .background(.white)
    }

    // ── Hilfsmethode: Info-Box ────────────────────────────────────────────────

    private func infoBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "#EEF2FF"))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#E8EAF6"), lineWidth: 1))
    }
}
