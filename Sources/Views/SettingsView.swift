import SwiftUI

struct SettingsView: View {
    @State private var apiKey:  String = AppSettings.shared.elevenLabsApiKey
    @State private var voiceId: String = AppSettings.shared.elevenLabsVoiceId
    @State private var speed:   Double = AppSettings.shared.ttsSpeed
    @State private var saved    = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Titel
            Text("🔊  ElevenLabs TTS-Einstellungen")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#1A1A2E"))
                .padding(.bottom, 8)

            Text("Tragen Sie Ihren ElevenLabs API-Key und die Voice-ID ein, um automatisch Audio für Ihre Suggestionen zu generieren.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "#6B7280"))
                .lineSpacing(3)
                .padding(.bottom, 24)

            // Info-Box
            HStack(alignment: .top, spacing: 6) {
                Text("ℹ️").font(.system(size: 14))
                Text("API-Key und Voice-ID finden Sie unter ")
                + Text("elevenlabs.io → Profile → API Keys").bold()
                + Text(" bzw. ")
                + Text("Voices → Voice-ID").bold()
                + Text(". Die Daten werden lokal gespeichert.")
            }
            .font(.system(size: 12))
            .foregroundColor(Color(hex: "#1A1A2E"))
            .padding(16)
            .background(Color(hex: "#EEF2FF"))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#E8EAF6"), lineWidth: 1))
            .padding(.bottom, 24)

            // API Key
            label("API-Key")
            TextField("sk_...", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))
                .padding(.bottom, 4)
            hint("Beginnt mit \"sk_...\"")
                .padding(.bottom, 16)

            // Voice ID
            label("Voice-ID")
            TextField("Alphanumerische ID", text: $voiceId)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 14))
                .padding(.bottom, 4)
            hint("Alphanumerische ID aus Ihrem ElevenLabs-Account")
                .padding(.bottom, 16)

            // Sprechgeschwindigkeit
            HStack {
                label("Sprechgeschwindigkeit: ")
                Text(String(format: "%.2f×", speed))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "#5C6BC0"))
            }
            .padding(.bottom, 8)

            Slider(value: $speed, in: 0.5...2.0, step: 0.05)
                .padding(.bottom, 4)

            HStack {
                Text("Langsam (0.5×)").font(.system(size: 10)).foregroundColor(Color(hex: "#6B7280"))
                Spacer()
                Text("Normal (1.0×)").font(.system(size: 10)).foregroundColor(Color(hex: "#6B7280"))
                Spacer()
                Text("Schnell (2.0×)").font(.system(size: 10)).foregroundColor(Color(hex: "#6B7280"))
            }
            .padding(.bottom, 28)

            // Buttons
            HStack {
                Spacer()
                if saved {
                    Text("✓ Gespeichert").font(.system(size: 14, weight: .semibold)).foregroundColor(Color(hex: "#10B981"))
                        .transition(.opacity)
                }
                Button("Speichern") { save() }
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .padding(32)
        .background(Color(hex: "#F5F6FA"))
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(hex: "#1A1A2E"))
    }

    private func hint(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(Color(hex: "#6B7280"))
    }

    private func save() {
        AppSettings.shared.elevenLabsApiKey  = apiKey.trimmingCharacters(in: .whitespaces)
        AppSettings.shared.elevenLabsVoiceId = voiceId.trimmingCharacters(in: .whitespaces)
        AppSettings.shared.ttsSpeed          = speed
        withAnimation { saved = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { saved = false }
        }
    }
}
